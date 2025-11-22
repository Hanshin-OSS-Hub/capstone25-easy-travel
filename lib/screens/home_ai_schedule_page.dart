// 이 파일은 AI 일정 추천 메인 화면입니다.
// 사용자가 여행 조건(도시, 날짜, 관심사)을 입력하면 더미 일정을 생성하여 보여줍니다.
// setState를 사용하여 입력값과 일정 리스트를 상태로 관리합니다.

import 'package:flutter/material.dart';

class HomeAISchedulePage extends StatefulWidget {
  const HomeAISchedulePage({super.key});

  @override
  State<HomeAISchedulePage> createState() => _HomeAISchedulePageState();
}

class _HomeAISchedulePageState extends State<HomeAISchedulePage> {
  // 여행 도시 입력을 위한 TextEditingController
  // TextField의 값을 읽기 위해 사용합니다.
  final TextEditingController _cityController = TextEditingController();
  
  // 여행 날짜 입력을 위한 TextEditingController
  final TextEditingController _dateController = TextEditingController();

  // 선택 가능한 관심사 목록
  final List<String> _interests = ['K-pop', 'Food', 'History', 'Cafe', 'Shopping'];
  
  // 현재 선택된 관심사 목록 (복수 선택 가능)
  final List<String> _selectedInterests = [];

  // 생성된 일정 리스트 (Day별로 그룹화)
  List<Map<String, dynamic>> _schedules = [];

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 Controller 해제
    _cityController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // AI 일정 추천 버튼을 눌렀을 때 호출되는 메서드
  void _generateSchedule() {
    // 입력값 검증
    if (_cityController.text.isEmpty || _dateController.text.isEmpty) {
      // 입력값이 없으면 스낵바로 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('도시와 날짜를 입력해주세요.')),
      );
      return;
    }

    // setState를 호출하여 화면을 다시 그립니다.
    // 이 안에서 상태 변수를 변경하면 자동으로 UI가 업데이트됩니다.
    setState(() {
      // 더미 일정 데이터 생성
      _schedules = _createDummySchedules();
    });
  }

  // 더미 일정 데이터를 생성하는 메서드
  List<Map<String, dynamic>> _createDummySchedules() {
    final city = _cityController.text;
    final selectedInterests = _selectedInterests.isEmpty 
        ? _interests.take(2).toList() 
        : _selectedInterests;

    // 3일치 일정 생성
    return [
      {
        'day': 1,
        'items': [
          {'time': '10:00', 'activity': '$city - 경복궁 방문'},
          {'time': '13:00', 'activity': '근처 전통 맛집 점심'},
          {'time': '15:00', 'activity': '인사동 거리 쇼핑'},
          {'time': '18:00', 'activity': '한강 공원 산책'},
        ],
      },
      {
        'day': 2,
        'items': [
          {'time': '09:00', 'activity': '${selectedInterests[0]} 관련 체험'},
          {'time': '12:00', 'activity': '로컬 카페 방문'},
          {'time': '14:00', 'activity': '명동 쇼핑'},
          {'time': '19:00', 'activity': 'K-pop 콘서트 또는 공연 관람'},
        ],
      },
      {
        'day': 3,
        'items': [
          {'time': '10:00', 'activity': '한국 전통 문화 체험'},
          {'time': '13:00', 'activity': '한식 레스토랑 점심'},
          {'time': '16:00', 'activity': '도심 관광 및 사진 촬영'},
          {'time': '20:00', 'activity': '야경 명소 방문'},
        ],
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 설명 텍스트
          _buildDescription(),
          const SizedBox(height: 24),
          
          // 여행 도시 입력 필드
          _buildCityInput(),
          const SizedBox(height: 16),
          
          // 여행 날짜 입력 필드
          _buildDateInput(),
          const SizedBox(height: 16),
          
          // 관심사 선택 섹션
          _buildInterestsSection(),
          const SizedBox(height: 24),
          
          // AI 일정 추천 버튼
          _buildGenerateButton(),
          const SizedBox(height: 24),
          
          // 생성된 일정 리스트
          if (_schedules.isNotEmpty) _buildScheduleList(),
        ],
      ),
    );
  }

  // 상단 설명 위젯
  Widget _buildDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '여행 조건을 입력하면 AI가 일정을 추천해 줍니다.\n현재는 더미 데이터입니다.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  // 도시 입력 필드
  Widget _buildCityInput() {
    return TextField(
      controller: _cityController,
      decoration: const InputDecoration(
        labelText: '여행 도시',
        hintText: '예: Seoul, Busan',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.location_city),
      ),
    );
  }

  // 날짜 입력 필드
  Widget _buildDateInput() {
    return TextField(
      controller: _dateController,
      decoration: const InputDecoration(
        labelText: '여행 날짜',
        hintText: '예: 2024-01-15 ~ 2024-01-17',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
    );
  }

  // 관심사 선택 섹션
  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관심사 선택 (복수 선택 가능)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _interests.map((interest) {
            // 각 관심사를 ChoiceChip으로 표시
            // 선택 여부는 _selectedInterests 리스트에 포함되어 있는지로 판단
            final isSelected = _selectedInterests.contains(interest);
            return ChoiceChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    // 선택된 경우 리스트에 추가
                    _selectedInterests.add(interest);
                  } else {
                    // 선택 해제된 경우 리스트에서 제거
                    _selectedInterests.remove(interest);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // AI 일정 추천 버튼
  Widget _buildGenerateButton() {
    return ElevatedButton.icon(
      onPressed: _generateSchedule,
      icon: const Icon(Icons.auto_awesome),
      label: const Text('AI 일정 추천 받기'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  // 생성된 일정 리스트
  Widget _buildScheduleList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '추천 일정',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        // 각 Day별로 일정을 카드 형태로 표시
        ..._schedules.map((schedule) => _buildDaySchedule(schedule)),
      ],
    );
  }

  // Day별 일정 카드
  Widget _buildDaySchedule(Map<String, dynamic> schedule) {
    final day = schedule['day'] as int;
    final items = schedule['items'] as List<Map<String, dynamic>>;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day 헤더
            Text(
              'Day $day',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            // 일정 항목 리스트
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      // 시간 표시
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['time'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 활동 내용
                      Expanded(
                        child: Text(item['activity']),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

