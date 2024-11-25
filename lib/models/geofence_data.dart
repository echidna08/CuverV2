import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 지오펜스의 기본 정보를 담는 데이터 모델 클래스
class GeofenceData {
  /// 지오펜스의 고유 식별자
  final String id;
  
  /// 지오펜스의 중심 좌표 (위도, 경도)
  final NLatLng center;
  
  /// 지오펜스의 반경 (미터 단위)
  final double radius;
  
  /// 지오펜스의 표시 이름
  final String name;

  /// 지오펜스 데이터 생성자
  /// 
  /// [id]: 고유 식별자
  /// [center]: 중심 좌표
  /// [radius]: 반경 (미터)
  /// [name]: 표시될 이름
  GeofenceData({
    required this.id,
    required this.center,
    required this.radius,
    required this.name,
  });
}
