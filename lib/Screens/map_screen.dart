import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/notification_service.dart';
import '../services/geofence_service.dart';
import '../constants/geofence_locations.dart';

/// 네이버 지도와 지오펜스를 표시하는 화면 위젯
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

/// MapScreen의 상태를 관리하는 클래스
class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  /// 네이버 지도 컨트롤러
  NaverMapController? _mapController;
  
  /// 지오펜스 관리 서비스
  late final GeofenceService _geofenceService;
  
  @override
  void initState() {
    super.initState();
    // 앱 생명주기 관찰자 등록
    WidgetsBinding.instance.addObserver(this);
    
    // 지오펜스 서비스 초기화
    _geofenceService = GeofenceService(
      notificationService: NotificationService(),
      geofences: defaultGeofences,
    );
    
    // 권한 체크 후 위치 추적 시작
    checkPermission().then((_) => startLocationTracking());
  }

  /// 위치 권한 확인 및 요청
  Future<void> checkPermission() async {
    try {
      print('권한 요청 시작');
      
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Android 기기에서 백그라운드 위치 권한 요청
      if (Platform.isAndroid) {
        if (await Permission.locationAlways.isDenied) {
          await Permission.locationAlways.request();
        }
      }
      
      // 권한 상태 로깅
      print('위치 권한: $permission');
      print('백그라운드 위치 권한: ${await Permission.locationAlways.status}');
      
    } catch (e) {
      print('권한 요청 중 오류 발생: $e');
    }
  }

  /// 실시간 위치 추적 시작
  Future<void> startLocationTracking() async {
    print('위치 추적 시작');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('위치 서비스 활성화 상태: $serviceEnabled');
    
    if (!serviceEnabled) {
      print('위치 서비스가 비활성화되어 있니다.');
      return;
    }

    // 실시간 위치 업데이트 수신
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,  // 높은 정확도
        distanceFilter: 10,  // 10미터마다 업데이트
      ),
    ).listen((Position position) {
      _geofenceService.checkGeofence(position);
      _updateCurrentLocationMarker(position);
    });
  }

  /// 현재 위치 마커 업데이트
  void _updateCurrentLocationMarker(Position position) {
    if (_mapController != null) {
      _mapController!.addOverlay(
        NMarker(
          id: 'current_location',
          position: NLatLng(position.latitude, position.longitude),
          caption: NOverlayCaption(text: '현재 위치'),
          iconTintColor: Colors.red,
        ),
      );
    }
  }

  /// 현재 위치 버튼 UI 구성
  Widget _buildCurrentLocationButton() {
    return Positioned(
      right: 16,
      bottom: 24,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              Position position = await Geolocator.getCurrentPosition();
              NLatLng currentPosition = NLatLng(
                position.latitude,
                position.longitude,
              );
              _mapController?.updateCamera(
                NCameraUpdate.withParams(
                  target: currentPosition,
                  zoom: 15,
                ),
              );
              _updateCurrentLocationMarker(position);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(
                  Icons.my_location_rounded,
                  size: 24,
                  color: Color(0xFF0BC473),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 지도가 준비되었을 때 호출되는 콜백
  void _onMapReady(NaverMapController controller) {
    _mapController = controller;
    
    // 모버깅을 위한 로그 추가
    print('지오펜스 개수: ${defaultGeofences.length}');
    
    // 모든 지오펜스에 대해 원형 오버레이 추가
    for (var geofence in defaultGeofences) {
      print('지오펜스 그리기 시작: ${geofence.name}');
      print('위치: ${geofence.center.latitude}, ${geofence.center.longitude}');
      print('반경: ${geofence.radius}m');
      
      final overlay = NCircleOverlay(
        id: geofence.id,
        center: geofence.center,
        radius: geofence.radius,
        color: Colors.blue.withOpacity(0.3),
        outlineColor: Colors.blue,
        outlineWidth: 2,
      );
      
      _mapController?.addOverlay(overlay);
      print('지오펜스 원 추가 완료: ${geofence.name}');
    }
  }

  @override
  void dispose() {
    // 리소스 정리
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 주변 탐색하기',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: defaultGeofences[0].center,  // 첫 번째 지오펜스 위치를 초기 위치로
                zoom: 13,
              ),
              liteModeEnable: true,
            ),
            onMapReady: _onMapReady,
          ),
          _buildCurrentLocationButton(),
        ],
      ),
    );
  }
}   