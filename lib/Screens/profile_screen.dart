import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? selectedType;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // SharedPreferences 초기화 및 저장된 타입 불러오기
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedType = _prefs.getString('userType');
    });
  }

  // 타입 선택 목록을 보여주는 위젯
  Widget _buildTypeSelectionList() {
    return ListView.separated(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: userTypes.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        final type = userTypes[index];
        final isSelected = selectedType == type['type'];
        
        return Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isSelected ? Color(0xFF0BC473) : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              setState(() {
                selectedType = type['type'];
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Color(0xFF0BC473).withOpacity(0.1)
                        : Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      type['icon'],
                      color: isSelected ? Color(0xFF0BC473) : Colors.grey,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type['title'],
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Color(0xFF0BC473) : Colors.grey[400],
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 카카오 프로필 정보 예시 (실제로는 로그인 시 저장된 정보를 사용해야 함)
  final Map<String, dynamic> userProfile = {
    'nickname': '홍길동',
    'profileImage': null,  // 프로필 이미지 URL이 없는 경우
    // 'profileImage': 'https://example.com/profile.jpg',  // URL이 있는 경우
  };

  final List<Map<String, dynamic>> userTypes = [
    {
      'type': 'elderly',
      'title': '어르신',
      'icon': Icons.elderly,
      'description': '65세 이상 어르신 대상 서비스',
    },
    {
      'type': 'youth',
      'title': '청소년',
      'icon': Icons.school,
      'description': '청소년 대상 서비스',
    },
    {
      'type': 'disabled',
      'title': '장애인',
      'icon': Icons.accessible,
      'description': '장애인 대상 서비스',
    },
    {
      'type': 'lowIncome',
      'title': '저소득',
      'icon': Icons.support,
      'description': '저소득층 대상 서비스',
    },
  ];

  // 선택된 타입 카드를 보여주는 위젯
  Widget _buildSelectedTypeCard() {
    final selectedTypeData = userTypes.firstWhere(
      (type) => type['type'] == selectedType,
      orElse: () => userTypes[0],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '선택된 정보 유형',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontFamily: 'Pretendard',
                ),
              ),
              TextButton(
                onPressed: () async {
                  // 수정 버튼 클릭 시 저장된 타입 삭제
                  await _prefs.remove('userType');
                  setState(() {
                    selectedType = null;
                  });
                },
                child: Text(
                  '수정',
                  style: TextStyle(
                    color: Color(0xFF0BC473),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Color(0xFF0BC473),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(0xFF0BC473).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      selectedTypeData['icon'],
                      color: Color(0xFF0BC473),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedTypeData['title'],
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedTypeData['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '프로필',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 섹션 추가
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  // 프로필 이미지
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                      image: userProfile['profileImage'] != null
                          ? DecorationImage(
                              image: NetworkImage(userProfile['profileImage']!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: userProfile['profileImage'] == null
                        ? Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // 사용자 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfile['nickname'] ?? '사용자',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'Pretendard',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '카카오계정으로 로그인',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 로필 편집 버튼
                  IconButton(
                    onPressed: () {
                      // TODO: 프로필 편집 기능 구현
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // 구분선 추가
            Container(
              height: 8,
              color: Color(0xFFF5F5F5),
            ),
            // 기존 관심 정보 설정 섹션
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '관심 정보 설정',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '받고 싶은 정보 유형을 선택해주세요',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_prefs.getString('userType') != null)
              _buildSelectedTypeCard()
            else
              _buildTypeSelectionList(),
            const SizedBox(height: 24),
            if (_prefs.getString('userType') == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: selectedType != null
                      ? () async {
                          // 선택한 타입 저장
                          await _prefs.setString('userType', selectedType!);
                          setState(() {
                            // UI 갱신을 위한 setState
                          });
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('선택이 저장되었습니다'),
                              backgroundColor: Color(0xFF0BC473),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0BC473),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  child: Text(
                    '저장하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
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
            currentIndex: 3, // 프로필 탭 선택
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
            onTap: (index) {
              if (index != 3) { // 프로필 탭이 아닌 경우에만 처리
                if (index == 0) { // 홈 탭
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                    (route) => false,
                  );
                }
                // TODO: 다른 탭에 대한 네비게이션 처리
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: '검색',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                label: '알림',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: '프로필',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
