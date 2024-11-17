import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:async';

class HospitalMapScreen extends StatefulWidget {
  @override
  _HospitalMapScreenState createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(35.179661, 129.074774), // 부산시청
    zoom: 14,
  );

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  List<Map<String, dynamic>> _hospitalsInRange = [];
  LatLng _currentCenter = LatLng(35.179661, 129.074774);
  GoogleMapController? _mapController;

  String _selectedCategory = '병원'; // 기본 카테고리
  final List<String> _categories = [
    '상급종합', '종합병원', '병원', '요양병원', '정신병원', '의원', '치과병원', '치과의원',
    '보건소', '보건지소', '보건진료소', '한방병원', '한의원'
  ];

  Timer? _debounce;
  double _currentRange = 1000.0; // 초기 반경 (1km)

  @override
  void initState() {
    super.initState();
    _loadUserRange(); // 사용자 반경 정보 불러오기
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // in meters
    double dLat = (end.latitude - start.latitude) * (pi / 180);
    double dLng = (end.longitude - start.longitude) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(start.latitude * (pi / 180)) * cos(end.latitude * (pi / 180)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _loadUserRange() async {
    // Firestore에서 사용자의 `range` 값 가져오기
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('myInfo')
          .doc('userID') // 사용자 고유 ID에 맞게 변경
          .get();

      if (snapshot.exists) {
        var userInfo = snapshot.data() as Map<String, dynamic>;
        double rangeFromFirestore = (userInfo['range'] ?? 1.0) * 1000; // km -> m 변환
        setState(() {
          _currentRange = rangeFromFirestore;
        });
      }

      // 병원 데이터를 반경에 맞게 로드
      _loadHospitalMarkers();
    } catch (e) {
      print('Error loading user range: $e');
    }
  }

  Future<void> _loadHospitalMarkers() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('hospital').get();
      List<Map<String, dynamic>> hospitals = [];
      Set<Marker> newMarkers = {};
      Set<Circle> newCircles = {};

      // 반경 표시
      newCircles.add(Circle(
        circleId: CircleId('range_circle'),
        center: _currentCenter,
        radius: _currentRange,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        double latitude =
            double.tryParse(data['latitude'].toString()) ?? 35.179661;
        double longitude =
            double.tryParse(data['longitude'].toString()) ?? 129.074774;

        if (latitude != null && longitude != null && data['name'] != null) {
          LatLng hospitalLocation = LatLng(latitude, longitude);
          double distance = _calculateDistance(_currentCenter, hospitalLocation);

          if ((_selectedCategory == null || data['category'] == _selectedCategory) &&
              distance <= _currentRange) {
            hospitals.add(data);
            newMarkers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: hospitalLocation,
                infoWindow: InfoWindow(
                  title: data['name'],
                  snippet: data['address'],
                ),
              ),
            );
          }
        }
      }

      setState(() {
        _hospitalsInRange = hospitals;
        _markers = newMarkers;
        _circles = newCircles;
      });
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onCameraMove(CameraPosition position) {
    _currentCenter = position.target;

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      _loadHospitalMarkers();
    });
  }

  void _selectCategory(String? category) {
    setState(() {
      _selectedCategory = category ?? '병원';
    });
    _loadHospitalMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('병원 지도'),
      ),
      body: Column(
        children: [
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (isSelected) {
                      _selectCategory(isSelected ? category : null);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              mapType: MapType.normal,
              markers: _markers,
              circles: _circles,
              onMapCreated: (controller) {
                _mapController = controller;
                _loadHospitalMarkers();
              },
              onCameraMove: _onCameraMove,
            ),
          ),
          Expanded(
            child: _hospitalsInRange.isEmpty
                ? Center(
              child: Text(
                '선택된 카테고리에 해당하는 병원이 없습니다.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _hospitalsInRange.length,
              itemBuilder: (context, index) {
                var data = _hospitalsInRange[index];
                return Card(
                  margin: EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      data['name'] ?? '알 수 없는 이름',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('주소: ${data['address'] ?? '알 수 없음'}'),
                        Text('전화번호: ${data['number'] ?? '알 수 없음'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
