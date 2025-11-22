// 이 파일은 지도 페이지입니다.
// 현재는 실제 지도 API 연동 없이 더미 UI만 표시합니다.
// 추후 Google Maps API 등을 연동할 수 있도록 구조를 준비합니다.

import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // 예시 여행지 더미 데이터
  final List<Map<String, String>> _places = [
    {
      'name': '경복궁',
      'description': '조선 왕조의 대표적인 궁궐',
      'category': '역사',
    },
    {
      'name': '명동 거리',
      'description': '서울의 대표적인 쇼핑 거리',
      'category': '쇼핑',
    },
    {
      'name': '한강 공원',
      'description': '서울의 대표적인 휴식 공간',
      'category': '자연',
    },
    {
      'name': '인사동',
      'description': '전통 문화와 현대가 공존하는 거리',
      'category': '문화',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 안내 텍스트
        _buildInfoSection(),
        
        // 지도 플레이스홀더
        _buildMapPlaceholder(),
        
        // 여행지 리스트
        Expanded(
          child: _buildPlacesList(),
        ),
      ],
    );
  }

  // 상단 안내 섹션
  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Text(
        '지도 기능은 추후 Google Maps API 등을 연동 예정입니다.',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  // 지도 플레이스홀더
  Widget _buildMapPlaceholder() {
    return Container(
      height: 300,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              '여기에 지도가 표시될 예정입니다',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Google Maps API 연동 예정',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 여행지 리스트
  Widget _buildPlacesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _places.length,
      itemBuilder: (context, index) {
        return _buildPlaceCard(_places[index]);
      },
    );
  }

  // 여행지 카드
  Widget _buildPlaceCard(Map<String, String> place) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        // 여행지 아이콘
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.place,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        // 여행지 이름
        title: Text(
          place['name']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        // 카테고리와 설명
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(place['description']!),
            const SizedBox(height: 4),
            // 카테고리 태그
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                place['category']!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        // 지도에서 보기 버튼
        trailing: ElevatedButton(
          onPressed: () {
            // TODO: 추후 Google Maps API 연동 시
            // 이 버튼을 눌렀을 때 해당 위치로 지도를 이동시키는 기능 구현
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${place['name']} 지도에서 보기 기능은 추후 구현 예정입니다.'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('지도에서 보기'),
        ),
      ),
    );
  }
}

// 참고: 추후 Google Maps API 연동 시
// 1. pubspec.yaml에 google_maps_flutter 패키지 추가
// 2. 이 파일에서 GoogleMap 위젯 import
// 3. _buildMapPlaceholder() 대신 GoogleMap 위젯 사용
// 4. 지도 컨트롤러를 통해 마커 추가 및 카메라 이동 구현

