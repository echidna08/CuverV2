import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';  // iOS 스타일 위젯용
import '../services/notification_service.dart';
import '../services/geofence_service.dart';
import '../constants/geofence_locations.dart';
import '../models/geofence_data.dart';
import '../services/busan_health_service.dart';

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
      print('치 서비스가 비활성화되어 있니다.');
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
      
      // 오버레이 클릭 리스너 설정
      overlay.setOnTapListener((overlay) {
        _showGeofenceDetails(geofence);
      });
      
      _mapController?.addOverlay(overlay);
      print('지오펜스 원 추가: ${geofence.name}');
    }
  }

  // 지오펜스 상세정보를 보여주는 바텀 시트
  void _showGeofenceDetails(GeofenceData geofence) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          if (geofence.id == 'geofence_3') {
            return Column(
              children: [
                // 상단 드래그 핸들
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // 제목 부분
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        geofence.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '검사 항 및 비용 안내',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // API 데이터 목록
                Expanded(
                  child: FutureBuilder<List<Map<String, String>>>(
                    future: BusanHealthService().getHealthcareInfo(
                      latitude: geofence.center.latitude,
                      longitude: geofence.center.longitude,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('검사 정보를 불러오는 중...'),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, 
                                size: 48, 
                                color: Colors.red[300]
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '정보를 불러올 수 없습니다',
                                style: TextStyle(color: Colors.red[300]),
                              ),
                            ],
                          ),
                        );
                      }

                      final examList = snapshot.data!;
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: examList.length,
                        itemBuilder: (context, index) {
                          final exam = examList[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                colorScheme: Theme.of(context).colorScheme.copyWith(
                                  primary: Colors.white,
                                  secondary: Colors.white,
                                  surfaceTint: Colors.white,
                                ),
                              ),
                              child: ExpansionTile(
                                backgroundColor: Colors.white,
                                collapsedBackgroundColor: Colors.white,
                                tilePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                iconColor: Colors.grey[700],
                                collapsedIconColor: Colors.grey[700],
                                title: Text(
                                  exam['testName'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  exam['testKind'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(12),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow(
                                          '검사 비용',
                                          exam['testPrice'] ?? '-',
                                          Icons.attach_money,
                                        ),
                                        const SizedBox(height: 8),
                                        _buildInfoRow(
                                          '기준일',
                                          exam['dataDay'] ?? '-',
                                          Icons.calendar_today,
                                        ),
                                        if (exam['testKind'] != null) ...[
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            '검사 종류',
                                            exam['testKind']!,
                                            Icons.medical_services,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            // 다른 지오펜스들의 기본 정보 표시 부분
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                // 좌우 패딩을 24로 늘림
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 드래그 핸들 추가
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      geofence.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 정보 표시를 카드 형태로 변경
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('위도', '${geofence.center.latitude}', Icons.location_on),
                            const SizedBox(height: 12),
                            _buildInfoRow('경도', '${geofence.center.longitude}', Icons.location_on),
                            const SizedBox(height: 12),
                            _buildInfoRow('반경', '${geofence.radius}m', Icons.radio_button_unchecked),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue[700],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
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