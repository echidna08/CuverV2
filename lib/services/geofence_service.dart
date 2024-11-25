import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../models/geofence_data.dart';
import 'notification_service.dart';
import 'package:flutter/material.dart';

/// 지오펜스 기능을 관리하는 서비스 클래스
class GeofenceService {
  /// 알림 전송을 위한 알림 서비스 인스턴스
  final NotificationService _notificationService;
  
  /// 관리할 지오펜스 목록
  final List<GeofenceData> geofences;
  
  /// 각 지오펜스의 현재 상태를 저장하는 맵
  /// key: 지오펜스 ID, value: 사용자가 해당 지오펜스 내부에 있는지 여부
  final Map<String, bool> _isInsideGeofences = {};

  /// 지오펜스 서비스 생성자
  /// 
  /// [notificationService]: 알림 전송을 위한 서비스
  /// [geofences]: 관리할 지오펜스 목록
  GeofenceService({
    required NotificationService notificationService,
    required this.geofences,
  }) : _notificationService = notificationService {
    // 모든 지오펜스의 초기 상태를 false로 설정
    for (var geofence in geofences) {
      _isInsideGeofences[geofence.id] = false;
    }
  }

  /// 현재 위치를 기반으로 모든 지오펜스의 상태를 체크하는 메서드
  /// 
  /// [position]: 현재 위치 정보
  void checkGeofence(Position position) {
    for (var geofence in geofences) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        geofence.center.latitude,
        geofence.center.longitude,
      );

      bool isCurrentlyInZone = distance <= geofence.radius;
      bool wasInZone = _isInsideGeofences[geofence.id] ?? false;
      
      if (isCurrentlyInZone && !wasInZone) {
        _notificationService.showTestNotification(
          title: '${geofence.name} 진입',
          body: '지정된 영역에 들어왔습니다.',
        );
      } else if (!isCurrentlyInZone && wasInZone) {
        _notificationService.showTestNotification(
          title: '${geofence.name} 이탈',
          body: '지정된 영역을 벗어났습니다.',
        );
      }

      _isInsideGeofences[geofence.id] = isCurrentlyInZone;
    }
  }

  /// 지도에 표시할 지오펜스 원형 오버레이 목록 생성
  /// 
  /// 반환값: 지오펜스를 시각적으로 표현하는 원형 오버레이 목록
  List<NCircleOverlay> createGeofenceOverlays() {
    return geofences.map((geofence) => NCircleOverlay(
      id: geofence.id,
      center: geofence.center,
      radius: geofence.radius,
      color: Colors.blue.withOpacity(0.3),
    )).toList();
  }
}
