import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../const/colors.dart';

class SettingTab extends StatelessWidget {
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
                  '설정',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
                Icon(Icons.settings, color: mainColor),
              ],
            ),
            SizedBox(height: 24),

            // 사용자 정보 표시
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('myInfo')
                  .orderBy('timestamp', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text(
                    '저장된 사용자 정보가 없습니다.',
                    style: TextStyle(fontSize: 16, color: secondColor),
                  );
                }

                var userInfo =
                snapshot.data!.docs.first.data() as Map<String, dynamic>;

                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.person, color: mainColor),
                    title: Text(
                      '사용자 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('성별: ${userInfo['gender'] ?? '미정'}'),
                        Text('나이: ${userInfo['age'] ?? '미정'}'),
                        Text('키: ${userInfo['height'] ?? '미정'} cm'),
                        Text('몸무게: ${userInfo['weight'] ?? '미정'} kg'),
                        Text(
                            '반경: ${userInfo['range']?.toStringAsFixed(1) ?? '1.0'} km'),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),

            // 카드 리스트
            Expanded(
              child: ListView(
                children: [
                  _buildSettingCard(
                    title: '사용자 정보 입력',
                    icon: Icons.person,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return UserInfoDialog();
                        },
                      );
                    },
                  ),
                  _buildSettingCard(
                    title: '내 주위',
                    icon: Icons.location_on,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return LocationRangeDialog();
                        },
                      );
                    },
                  ),
                  _buildSettingCard(
                    title: '나만의 약통',
                    icon: Icons.star,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FavoriteDialog();
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: mainColor),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: mainColor,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: mainColor),
        onTap: onTap,
      ),
    );
  }
}

// 사용자 정보 입력 다이얼로그 수정
class UserInfoDialog extends StatefulWidget {
  @override
  _UserInfoDialogState createState() => _UserInfoDialogState();
}

class _UserInfoDialogState extends State<UserInfoDialog> {
  String _selectedGender = '남성';
  TextEditingController _ageController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('사용자 정보 입력',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainColor)),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('남성'),
                      value: '남성',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: Text('여성'),
                      value: '여성',
                      groupValue: _selectedGender,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildTextField('나이', _ageController),
              SizedBox(height: 16),
              _buildTextField('키 (cm)', _heightController),
              SizedBox(height: 16),
              _buildTextField('몸무게 (kg)', _weightController),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                  setState(() {
                    _isSaving = true;
                  });

                  try {
                    // 먼저 사용자 정보를 가져옵니다.
                    var userSnapshot = await FirebaseFirestore.instance
                        .collection('myInfo')
                        .doc('userID') // 사용자의 고유 ID로 변경
                        .get();

                    Map<String, dynamic> userData = {
                      'gender': _selectedGender,
                      'age': int.tryParse(_ageController.text) ?? 0,
                      'height':
                      double.tryParse(_heightController.text) ?? 0.0,
                      'weight':
                      double.tryParse(_weightController.text) ?? 0.0,
                      'timestamp': FieldValue.serverTimestamp(),
                    };

                    if (userSnapshot.exists) {
                      // 문서가 존재하면 업데이트
                      await FirebaseFirestore.instance
                          .collection('myInfo')
                          .doc('userID') // 동일한 문서 ID로 업데이트
                          .update(userData);
                    } else {
                      // 문서가 존재하지 않으면 추가
                      await FirebaseFirestore.instance
                          .collection('myInfo')
                          .doc('userID') // 고유 ID로 저장
                          .set(userData);
                    }

                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('저장 중 오류 발생: $e')),
                    );
                  } finally {
                    setState(() {
                      _isSaving = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                child: Center(
                  child: _isSaving
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('저장', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}


// 내 주위 설정 다이얼로그
class LocationRangeDialog extends StatefulWidget {
  @override
  _LocationRangeDialogState createState() => _LocationRangeDialogState();
}

class _LocationRangeDialogState extends State<LocationRangeDialog> {
  double _currentRange = 1.0; // 기본값
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentRange(); // Firestore에서 값을 가져오는 함수 호출
  }

  Future<void> _fetchCurrentRange() async {
    try {
      var userSnapshot = await FirebaseFirestore.instance
          .collection('myInfo')
          .doc('userID') // 사용자 고유 ID로 변경
          .get();

      if (userSnapshot.exists) {
        var userInfo = userSnapshot.data() as Map<String, dynamic>;
        double range = userInfo['range'] ?? 1.0; // range 필드 값
        setState(() {
          _currentRange = range;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('반경을 불러오는 중 오류 발생: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '범위 설정',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            SizedBox(height: 16),
            Text('반경: ${_currentRange.toStringAsFixed(1)} km'),
            Slider(
              value: _currentRange,
              min: 0.5,
              max: 3.0,
              divisions: 5,
              label: '${_currentRange.toStringAsFixed(1)} km',
              onChanged: (value) {
                setState(() {
                  _currentRange = value;
                });
              },
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                setState(() {
                  _isSaving = true;
                });

                try {
                  await FirebaseFirestore.instance
                      .collection('myInfo')
                      .doc('userID') // 사용자 고유 ID로 변경
                      .update({
                    'range': _currentRange,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  if (context.mounted) Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('저장 중 오류 발생: $e')),
                  );
                } finally {
                  setState(() {
                    _isSaving = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: mainColor),
              child: Center(
                child: _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('저장', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// 즐겨찾기 보기 다이얼로그
class FavoriteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('star').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '나만의 약통이 비어있습니다.',
                    style: TextStyle(fontSize: 16, color: secondColor),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // 다이얼로그 닫기
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                    child: Text('닫기', style: TextStyle(fontSize: 18)),
                  ),
                ],
              );
            }

            var favoriteDataList = snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id; // ID 추가
              return data;
            }).toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '나만의 약통',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor),

                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: favoriteDataList.length,
                    itemBuilder: (context, index) {
                      var data = favoriteDataList[index];
                      return _buildFavoriteCard(context, data);
                    },
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('닫기'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Map<String, dynamic> data) {
    bool isFavorite = true; // 즐겨찾기 상태 기본값
    String drugId = data['id'] ?? ''; // 문서 ID (Firebase에서 가져옴)

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
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication); // 외부 브라우저에서 링크 열기
    } else {
      throw 'Could not launch $url';
    }
  }

  void _toggleFavorite(String drugId, bool isFavorite, Map<String, dynamic> data) {
    var collection = FirebaseFirestore.instance.collection('star');

    if (isFavorite) {
      // 즐겨찾기 삭제
      collection.doc(drugId).delete();
    } else {
      // 즐겨찾기 추가
      collection.doc(drugId).set(data);
    }
  }
}
