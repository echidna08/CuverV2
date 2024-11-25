import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:cuver_v2/oauth/login_page.dart';     // 로그인 페이지
import 'package:cuver_v2/Screens/main_screen.dart';  // 메인 스크린
import 'services/notification_service.dart';  // 추가
import 'package:flutter_naver_map/flutter_naver_map.dart';  // 네이버 맵 패키지

void main() async {  // async 추가
  WidgetsFlutterBinding.ensureInitialized();
  
  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '5e02af0aab7c259abc19a427f4f2bc9d',
  );

  // 알림 서비스 초기화
  await NotificationService().initialize();  // 추가
  
  // 네이버 맵 SDK 초기화
  await NaverMapSdk.instance.initialize(
    clientId: '32w5an7m3b',  // 여기에 본인의 클라이언트 ID를 넣어주세요
    onAuthFailed: (error) {
      print('네이버 맵 인증 실패: $error');
    },
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CUver',
      routes: {
        '/': (context) => LoginPage(),      // 로그인 페이지
        '/main': (context) => MainScreen(), // 메인 스크린
      },
      initialRoute: '/',
    );
  }
}
