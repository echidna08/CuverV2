import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

// NotificationService: 로컬 푸시 알림을 관리하는 싱글톤 클래스
class NotificationService {
  // 싱글톤 패턴 구현을 위한 private 인스턴스
  static final NotificationService _instance = NotificationService._();
  
  // 싱글톤 인스턴스를 반환하는 factory 생성자
  factory NotificationService() => _instance;
  
  // private 생성자
  NotificationService._();

  // 알림 기능을 제공하는 플러그인 인스턴스
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // 알림 서비스 초기화 메서드
  Future<void> initialize() async {
    print('알림 서비스 초기화 시작');

    // Android 알림 설정 초기화 
    // @mipmap/ic_launcher: 앱 아이콘을 알림 아이콘으로 사용
    const androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS 알림 설정 초기화
    // 알림, 배지, 사운드 권한 요청 및 기본 설정
    DarwinInitializationSettings iosInitializationSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true
    );


    // Android와 iOS 설정을 결합한 초기화 설정 생성
    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitializationSettings,
    );

    // 알림 플러그인 초기화 및 알림 응답 핸들러 설정
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('알림 응답 받음: ${response.payload}');
      },
    );

    print('알림 서비스 초기화 완료');
  }

  // 테스트 알림을 표시하는 메서드
  Future<void> showTestNotification({
    required String title,  // title 파라미터 추가
    required String body,   // body 파라미터 추가
  }) async {
    try {
      await _notifications.show(
        0,  // notification id
        title,  // notification title
        body,   // notification body
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_notification_channel',
            'Test Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
      print('알림 전송 성공');
    } catch (e) {
      print('알림 전송 실패: $e');
    }
  }
}
