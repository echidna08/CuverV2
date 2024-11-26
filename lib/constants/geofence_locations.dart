import '../models/geofence_data.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 기본 지오펜스 위치 목록
/// 새로운 지오펜스를 추가하려면 이 리스트에 추가하면 됨
final List<GeofenceData> defaultGeofences = [
  GeofenceData(
    id: 'geofence_1',
    center: const NLatLng(35.3215, 129.1756),  // 정관 동원로얄듀크2차 좌표
    radius: 50.0,  // 반경 50미터
    name: '정관 동원로얄듀크2차',
  ),
  GeofenceData(
    id: 'geofence_2',
    center: const NLatLng(35.2431, 129.0922),  // 금정구청 좌표
    radius: 30.0,  // 반경 30미터
    name: '금정구청',
  ),
  GeofenceData(
    id: 'geofence_3',
    center: const NLatLng(35.242113, 129.092565),  // 금정구 보건소 좌표
    radius: 30.0,  // 반경 30미터
    name: '금정구 보건소',
  ),

  // 여기에 새로운 지오펜스를 추가할 수 있습니다.
];
