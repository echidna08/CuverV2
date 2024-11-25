import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../providers/auth_provider.dart';

class KakaoOAuthService {
  Future<void> login(BuildContext context, WidgetRef ref) async {
    try {
      print('========== 카카오 로그인 시작');
      
      late OAuthToken token;
      
      // 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');
          
          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우
          if (error is PlatformException && error.code == 'CANCELED') {
            // 카카오계정으로 로그인 재시도
            print('카카오계정으로 로그인 재시도');
            token = await UserApi.instance.loginWithKakaoAccount();
          } else {
            throw error; // 다른 에러는 그대로 던지기
          }
        }
      } else {
        print('카카오톡 미설치: 카카오계정으로 로그인 시도');
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('로그인 토큰: ${token.accessToken}');

      // 사용자 정보 요청
      try {
        User user = await UserApi.instance.me();
        print('사용자 정보 요청 성공'
            '\n회원번호: ${user.id}'
            '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
            '\n이메일: ${user.kakaoAccount?.email}');

        if (!context.mounted) return;
        await _handleLoginSuccess(context, user.id.toString(), ref);
      } catch (error) {
        print('사용자 정보 요청 실패 $error');
        throw error;
      }

    } catch (error) {
      print('========== 카카오 로그인 실패 $error');
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 실패: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '다시 시도',
            textColor: Colors.white,
            onPressed: () => login(context, ref),
          ),
        ),
      );
    }
  }

  Future<void> _handleLoginSuccess(BuildContext context, String userId, WidgetRef ref) async {
    try {
      print('========== 로그인 성공 처리 시작');
      ref.read(authProvider.notifier).setLoggedIn(userId);
      
      // 메인 화면으로 이동
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/main');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인 성공!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('========== 로그인 성공 처리 중 오류: $e');
      throw e;
    }
  }
}