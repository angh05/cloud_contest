import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class PharmacyMapScreen extends StatefulWidget {
  @override
  _PharmacyMapScreenState createState() => _PharmacyMapScreenState();
}

class _PharmacyMapScreenState extends State<PharmacyMapScreen> {
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(35.179661, 129.074774), // 부산시청
    zoom: 14,
  );

  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  List<Map<String, dynamic>> _pharmaciesInRange = [];
  LatLng _currentCenter = LatLng(35.179661, 129.074774);
  GoogleMapController? _mapController;
  double _currentRange = 1.0;

  @override
  void initState() {
    super.initState();
    _fetchUserRange();
    _loadPharmacyMarkers();
  }

  Future<void> _fetchUserRange() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('myInfo')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userInfo = snapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _currentRange = userInfo['range'] ?? 1.0;
        });
      }
    } catch (e) {
      print('Error fetching user range: $e');
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371000; // in meters
    double dLat = (end.latitude - start.latitude) * (pi / 180);
    double dLng = (end.longitude - start.longitude) * (pi / 180);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(start.latitude * (pi / 180)) *
            cos(end.latitude * (pi / 180)) *
            sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  Future<void> _loadPharmacyMarkers() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('Pharmacy').get();
      List<Map<String, dynamic>> pharmacies = [];
      Set<Marker> newMarkers = {};
      Set<Circle> newCircles = {};

      // 반경 설정
      newCircles.add(Circle(
        circleId: CircleId('range'),
        center: _currentCenter,
        radius: _currentRange * 1000,
        fillColor: Colors.blue.withOpacity(0.2),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        double latitude = double.tryParse(data['longitude'].toString()) ?? 0.0;
        double longitude = double.tryParse(data['latitude'].toString()) ?? 0.0;

        if (latitude != 0.0 && longitude != 0.0 && data['name'] != null) {
          LatLng pharmacyLocation = LatLng(latitude, longitude);
          double distance = _calculateDistance(_currentCenter, pharmacyLocation);

          if (distance <= _currentRange * 1000) {
            pharmacies.add(data);
            newMarkers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: pharmacyLocation,
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
        _pharmaciesInRange = pharmacies;
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
    _loadPharmacyMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('약국 지도'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              mapType: MapType.normal,
              markers: _markers,
              circles: _circles,
              onMapCreated: _onMapCreated,
              onCameraMove: _onCameraMove,
            ),
          ),
          Expanded(
            child: _pharmaciesInRange.isEmpty
                ? Center(
              child: Text(
                '반경 내 데이터가 없습니다.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
                : ListView.builder(
              itemCount: _pharmaciesInRange.length,
              itemBuilder: (context, index) {
                var data = _pharmaciesInRange[index];
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
                        Text('우편번호: ${data['office'] ?? '알 수 없음'}'),
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