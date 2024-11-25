import 'package:flutter/material.dart';
import 'map_screen.dart';  // map_screen.dart import 추가
import '../services/notification_service.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'CUver',
          style: TextStyle(
            fontSize: 24,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.menu, color: Colors.black, size: 24),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Container(
        color: Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 상단 카드형 버튼
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 140,
                    padding: EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '내 주변 탐색하기',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '가까운 공공시설을 찾아보세요',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[600],
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Color(0xFF0BC473),
                            borderRadius: BorderRadius.circular(27),
                          ),
                          child: Icon(
                            Icons.map_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 하단 메뉴 그리드
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMenuCard(
                      title: '설정',
                      icon: Icons.settings_outlined,
                      onTap: () {},
                    ),
                    _buildMenuCard(
                      title: '즐겨찾기',
                      icon: Icons.star_outline,
                      onTap: () {},
                    ),
                    _buildMenuCard(
                      title: '알림',
                      icon: Icons.notifications_outlined,
                      onTap: () async {
                        try {
                          await NotificationService().showTestNotification(
                            title: '알림 테스트',
                            body: '알림이 정상적으로 작동합니다.',
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('테스트 알림이 전송되었습니다.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          print('알림 전송 실패: $e');
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('알림 전송에 실패했습니다: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                    _buildMenuCard(
                      title: '프로필',
                      icon: Icons.person_outline,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFF0BC473),
            unselectedItemColor: Colors.grey[400],
            selectedLabelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: "Pretendard",
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: "Pretendard",
            ),
            iconSize: 22,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined), label: '홈'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined), label: '알림'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline), label: '프로필'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Color(0xFF0BC473).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF0BC473),
                  size: 26,
                ),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Pretendard",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
