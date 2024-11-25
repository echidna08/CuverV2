import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoggedIn;
  final String? userId;

  AuthState({
    this.isLoggedIn = false,
    this.userId,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userId,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void setLoggedIn(String userId) {
    state = state.copyWith(
      isLoggedIn: true,
      userId: userId,
    );
  }

  void setLoggedOut() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
}); 