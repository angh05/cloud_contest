import 'dart:async'; // Timer 사용
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/const/colors.dart';
import 'bmiMeasurementPage.dart';
import 'hospital_map_screen.dart';
import 'pharmacy_map_screen.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1); // 한 페이지를 꽉 채움
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll(int totalPages) {
    // 타이머 시작
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      if (_pageController.hasClients) {
        // 다음 페이지 계산 (순환 처리)
        int nextPage = (_currentPage + 1) % totalPages;

        // 페이지 넘기기
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        // 현재 페이지 업데이트
        _currentPage = nextPage;
      }
    });
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
            // 상단 제목
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '부산광역시 병원/약국',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                Icon(
                  Icons.favorite, // favorite 아이콘
                  color: mainColor, // 아이콘 색상 지정
                  size: 20, // 아이콘 크기
                ),
              ],
            ),
            SizedBox(height: 24),

            // 병원 버튼
            Column(
              children: [
                // 병원 버튼
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HospitalMapScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16.0), // 버튼 사이 간격
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor1.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '병원',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '병원 지도 펼치기',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondColor,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.local_hospital,
                          color: mainColor,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),

                // 약국 버튼
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PharmacyMapScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16.0), // 버튼 사이 간격
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor2.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '약국',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '약국 지도 펼치기',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondColor,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.local_pharmacy,
                          color: mainColor,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),

                // BMI 버튼 추가
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BMIPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.only(bottom: 16.0), // 버튼 사이 간격
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF90EE90).withOpacity(0.3),  // Green shadow for BMI button
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BMI 측정하기',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: mainColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'BMI 측정 결과 보기',
                              style: TextStyle(
                                fontSize: 14,
                                color: secondColor,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.fitness_center,
                          color: mainColor,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),


            SizedBox(height: 24),
            // "심야약국" 제목 추가
            Text(
              '심야약국',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            SizedBox(height: 16),
            // 심야약국 (가로 스크롤)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('nightpharmacy').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("심야약국 정보가 없습니다."));
                  }

                  List<Map<String, dynamic>> pharmacies = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();

                  List<List<Map<String, dynamic>>> pages = [];
                  for (int i = 0; i < pharmacies.length; i += 3) {
                    pages.add(pharmacies.sublist(
                      i,
                      i + 3 > pharmacies.length ? pharmacies.length : i + 3,
                    ));
                  }

                  // 자동 스크롤 시작
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _startAutoScroll(pages.length);
                  });

                  return PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    itemBuilder: (context, pageIndex) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: pages[pageIndex].map((pharmacy) {
                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.all(8.0),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.yellow.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pharmacy['pmcyNm'] ?? '이름 없음',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    pharmacy['lctnRoadNm'] ?? '주소 없음',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondColor,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '전화번호: ${pharmacy['telno'] ?? '없음'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: secondColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
