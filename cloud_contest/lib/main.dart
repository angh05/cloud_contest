import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 추가
import 'firebase_options.dart';
import 'screen_tab/control.dart';
import 'const/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 위젯 바인딩 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Firebase 초기화
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '약국ㄱㄱㄱㄱㄱ',
      theme: ThemeData(
        primaryColor: mainColor, // mainColor로 변경
        fontFamily: 'Roboto', // 앱에 적용할 기본 폰트
      ),
      home: Control(), // Control 위젯을 초기 화면으로 설정
    );
  }
}
class FirebaseInitializer extends StatefulWidget {
  @override
  _FirebaseInitializerState createState() => _FirebaseInitializerState();
}

class _FirebaseInitializerState extends State<FirebaseInitializer> {
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      // Firebase 초기화 실패 화면
      return Scaffold(
        body: Center(
          child: Text(
            'Firebase 초기화 중 오류가 발생했습니다.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    if (!_isInitialized) {
      // Firebase 초기화 중 로딩 화면
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Firebase 초기화 완료 후 Control 화면 표시
    return Control();
  }
}