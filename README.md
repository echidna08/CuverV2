# 🌍 Cuver V2 - 지오펜싱 기반 위치 알림 서비스

## 📱 프로젝트 소개
Cuver V2는 Flutter로 개발된 지오펜싱 기반 위치 알림 서비스입니다. 사용자가 지정된 영역에 진입하거나 이탈할 때 자동으로 알림을 제공합니다.

## ✨ 주요 기능
- 🗺️ 네이버 지도 기반 실시간 위치 추적
- 🎯 다중 지오펜스 영역 설정 및 관리
- 🔔 영역 진입/이탈 시 자동 알림
- 🔒 카카오 소셜 로그인 지원
- 📍 현재 위치 중심 지도 이동

## 🛠️ 기술 스택
- **프레임워크**: Flutter
- **언어**: Dart
- **지도**: Naver Maps API
- **위치 서비스**: Geolocator
- **알림**: Flutter Local Notifications
- **인증**: Kakao Login SDK

## 📍 지원 지역
현재 다음 지역에 대한 지오펜스가 설정되어 있습니다:
1. 정관 동원로얄듀크2차 (반경 50m)
2. 금정구청 (반경 30m)

## 📱 스크린샷
[스크린샷 추가 예정]

## 🚀 시작하기
1. 프로젝트 클론
git clone https://github.com/echidna08/CuverV2.git
2. 의존성 설치
flutter pub get
3. 앱 실행
flutter run

## 📝 필요한 권한
- 위치 권한 (항상 허용/앱 사용 중에만 허용)
- 알림 권한
- 백그라운드 위치 추적 권한 (Android)

## 🔑 필요한 API 키
- Naver Maps Client ID
- Kakao Developer API Key

## 👥 개발자
- [echidna08](https://github.com/echidna08)

## 📄 라이선스
이 프로젝트는 MIT 라이선스 하에 있습니다.

## 🔄 버전 정보
- 현재 버전: 2.0.0
- 최근 업데이트: 2024.11.25
  - 금정구청 지오펜스 추가
  - 지오펜스 시각화 기능 개선
  - 알림 서비스 안정성 향상

## 📞 문의
문제가 발생하거나 제안사항이 있으시다면 [Issues](https://github.com/echidna08/CuverV2/issues)에 등록해 주세요.
