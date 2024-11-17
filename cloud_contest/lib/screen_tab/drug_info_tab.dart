import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const/colors.dart';

class DrugInfoTab extends StatefulWidget {
  @override
  _DrugInfoTabState createState() => _DrugInfoTabState();
}

class _DrugInfoTabState extends State<DrugInfoTab> {
  bool _isLoading = false;
  bool _hasMore = true; // To track if more data is available
  List<DocumentSnapshot> _drugDocuments = [];
  List<DocumentSnapshot> _filteredDocuments = [];
  String _searchQuery = '';
  TextEditingController _searchController = TextEditingController();

  // 즐겨찾기 상태를 저장할 맵
  Map<String, bool> _favoriteStatus = {};

  // For pagination
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Fetch initial data
  }

  Future<void> _fetchData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('yak')
        .orderBy('ITEM_NAME')
        .limit(20); // Fetch only 20 documents

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    QuerySnapshot querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _drugDocuments.addAll(querySnapshot.docs);
        _lastDocument = querySnapshot.docs.last;
        if (querySnapshot.docs.length < 20) {
          _hasMore = false; // No more documents to fetch
        }
      });
    }

    _filterData(); // Re-filter after fetching more data

    setState(() {
      _isLoading = false;
    });
  }

  // 검색어가 변경될 때마다 데이터 필터링
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterData(); // Filter when search query changes
  }

  // 데이터 필터링 함수
  void _filterData() {
    if (_searchQuery.isEmpty) {
      _filteredDocuments = List.from(_drugDocuments);
    } else {
      _filteredDocuments = _drugDocuments.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return data['ITEM_NAME']
            .toString()
            .toLowerCase()
            .contains(_searchQuery.toLowerCase());
      }).toList();
    }
    setState(() {});
  }

  // 즐겨찾기 상태를 'star' 컬렉션에 저장
  void _toggleFavorite(String drugId, bool isFavorite, Map<String, dynamic> drugData) async {
    var docRef = FirebaseFirestore.instance.collection('star').doc(drugId);

    setState(() {
      _favoriteStatus[drugId] = !isFavorite; // 아이콘 상태 업데이트
    });

    if (isFavorite) {
      // 즐겨찾기에서 제거
      await docRef.delete();
    } else {
      // 즐겨찾기에 추가
      await docRef.set({
        'drugId': drugId,
        'isFavorite': true,
        'ITEM_NAME': drugData['ITEM_NAME'],
        'ENTP_NAME': drugData['ENTP_NAME'],
        'ETC_OTC_CODE': drugData['ETC_OTC_CODE'],
        'CHART': drugData['CHART'],
        'UD_DOC_ID': drugData['UD_DOC_ID'],
      });
    }
  }

  // 즐겨찾기 상태를 'star' 컬렉션에서 가져오기
  Future<bool> _isFavorite(String drugId) async {
    // 캐시된 상태에서 즐겨찾기 여부 확인
    if (_favoriteStatus.containsKey(drugId)) {
      return _favoriteStatus[drugId]!;
    }

    var docRef = FirebaseFirestore.instance.collection('star').doc(drugId);
    var docSnapshot = await docRef.get();
    return docSnapshot.exists && docSnapshot['isFavorite'] == true;
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication); // 외부 브라우저에서 링크 열기
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '약 정보',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                Icon(
                  Icons.medical_services, // favorite 아이콘
                  color: mainColor, // 아이콘 색상 지정
                  size: 20, // 아이콘 크기
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredDocuments.length + (_hasMore ? 1 : 0), // Add "Load More" button
                itemBuilder: (context, index) {
                  if (index < _filteredDocuments.length) {
                    var data = _filteredDocuments[index].data() as Map<String, dynamic>;
                    String drugId = _filteredDocuments[index].id;

                    return FutureBuilder<bool>(
                      future: _isFavorite(drugId),
                      builder: (context, snapshot) {
                        bool isFavorite = snapshot.data ?? false;

                        return Card(
                          color: Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(
                              data['ITEM_NAME'] ?? '알 수 없는 이름',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  '제조사: ${data['ENTP_NAME'] ?? '알 수 없음'}',
                                  style: TextStyle(color: secondColor),
                                ),
                                Text(
                                  '분류: ${data['ETC_OTC_CODE'] ?? '알 수 없음'}',
                                  style: TextStyle(color: secondColor),
                                ),
                                Text(
                                  '생김새: ${data['CHART'] ?? '알 수 없음'}',
                                  style: TextStyle(color: secondColor),
                                ),
                                SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      String? url = data['UD_DOC_ID'];
                                      if (url != null && url.isNotEmpty) {
                                        _launchURL(url);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('유효한 링크가 없습니다.')),
                                        );
                                      }
                                    },
                                    child: Text(
                                      '복용 방법 보기',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                                color: isFavorite ? Colors.yellow : Colors.grey,
                              ),
                              onPressed: () {
                                _toggleFavorite(drugId, isFavorite, data);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // Display "Load More" button
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _fetchData,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('더 보기'),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
