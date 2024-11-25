// 사용자 인증 상태를 관리하기 위한 모델 클래스
class UserModel {
  final String accessToken;    // 카카오 로그인 액세스 토큰
  final bool isLoggedIn;      // 로그인 상태

  UserModel({
    required this.accessToken,
    this.isLoggedIn = false,
  });

  // 모델 업데이트를 위한 복사 메서드
  // 일부 필드만 변경하고 싶을 때 사용
  UserModel copyWith({
    String? accessToken,
    bool? isLoggedIn,
  }) {
    return UserModel(
      accessToken: accessToken ?? this.accessToken,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
} 