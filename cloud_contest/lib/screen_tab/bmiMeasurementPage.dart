import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../const/colors.dart';

class BMIPage extends StatefulWidget {
  @override
  _BMIPageState createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  String gender = '';
  double height = 0.0; // 키 (cm)
  double weight = 0.0; // 몸무게 (kg)
  int age = 0;
  String bmiCategory = ''; // 비만도
  double calculatedBMI = 0.0; // 계산된 BMI 수치

  // BMI 계산 함수
  void _calculateBMI() {
    if (height > 0 && weight > 0) {
      // BMI 계산 (키는 cm 단위이므로 m로 변환)
      double bmi = weight / ((height / 100) * (height / 100));

      // 비만도 판별
      setState(() {
        calculatedBMI = bmi;
        if (bmi < 18.5) {
          bmiCategory = '저체중';
        } else if (bmi >= 18.5 && bmi < 24.9) {
          bmiCategory = '정상체중';
        } else if (bmi >= 25 && bmi < 29.9) {
          bmiCategory = '과체중';
        } else {
          bmiCategory = '비만';
        }
      });
    } else {
      setState(() {
        bmiCategory = '잘못된 데이터';
        calculatedBMI = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI 측정 페이지'),
        backgroundColor: mainColor, // 앱바 색상 변경
      ),
      backgroundColor: bgColor, // 배경색 설정
      body: Padding(
        padding: EdgeInsets.all(20.0), // 더 넉넉한 padding
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('myInfo') // 'users' 컬렉션
              .doc('userID') // 'myInfo' 문서
              .snapshots(), // 실시간 업데이트를 위한 stream
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  '저장된 사용자 정보가 없습니다.',
                  style: TextStyle(fontSize: 16, color: accentColor2), // 텍스트 색상 변경
                ),
              );
            }

            var userInfo = snapshot.data!.data() as Map<String, dynamic>;
            // 사용자 정보 업데이트
            gender = userInfo['gender'] ?? '';
            height = userInfo['height']?.toDouble() ?? 0.0;
            weight = userInfo['weight']?.toDouble() ?? 0.0;
            age = userInfo['age'] ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보 카드
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // 둥근 모서리
                  ),
                  elevation: 5, // 그림자 효과
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('성별: $gender', style: TextStyle(fontSize: 18, color: secondColor)),
                        SizedBox(height: 8),
                        Text('키: $height cm', style: TextStyle(fontSize: 18, color: secondColor)),
                        SizedBox(height: 8),
                        Text('몸무게: $weight kg', style: TextStyle(fontSize: 18, color: secondColor)),
                        SizedBox(height: 8),
                        Text('나이: $age 세', style: TextStyle(fontSize: 18, color: secondColor)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // BMI 계산 버튼
                ElevatedButton(
                  onPressed: _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor1, // 버튼 색상 변경
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 둥근 버튼
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40), // 버튼 패딩
                    elevation: 5, // 버튼 그림자 효과
                  ),
                  child: Text(
                    'BMI 계산하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),

                // BMI 수치 및 비만도 결과
                if (calculatedBMI > 0.0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // 둥근 모서리
                        ),
                        elevation: 5, // 그림자 효과
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '당신의 BMI 수치: ${calculatedBMI.toStringAsFixed(1)}',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '비만도: $bmiCategory',
                                style: TextStyle(fontSize: 18, color: secondColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
