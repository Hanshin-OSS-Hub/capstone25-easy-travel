// 이 파일은 여행지 리뷰 페이지입니다.
// 지도 영역과 여행지 선택 기능을 포함한 리뷰 목록 및 작성 기능을 제공합니다.
// setState를 사용하여 리뷰 리스트를 상태로 관리합니다.
// 이미지 첨부 및 추천/비추천 기능이 포함되어 있습니다.
// TODO: 추후 실제 지도 위젯, GPS 위치, 백엔드 API 연동 예정

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// === 여행지 데이터 모델 ===
// TODO: 추후 백엔드 API에서 받아온 데이터로 교체
class Place {
  final String id;
  final String name;

  Place({
    required this.id,
    required this.name,
  });
}

// === 리뷰 데이터 모델 ===
// 이미지 첨부 및 추천/비추천 기능을 포함한 확장된 구조
class Review {
  final String id;
  final String placeId;      // 어떤 여행지에 대한 리뷰인지 연결
  final String placeName;    // 여행지 이름 (표시용)
  final int rating;
  final String content;
  final String author;
  final DateTime createdAt;
  final XFile? image;        // 첨부된 이미지 파일 (null이면 이미지 없음)
  final int likeCount;       // 추천 수
  final int dislikeCount;    // 비추천 수
  final int userVote;        // 사용자의 투표 상태 (1 = 추천, -1 = 비추천, 0 = 투표 안 함)

  Review({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.rating,
    required this.content,
    required this.author,
    required this.createdAt,
    this.image,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.userVote = 0,
  });

  // 추천/비추천 상태를 업데이트한 새로운 Review 인스턴스 생성
  Review copyWith({
    String? id,
    String? placeId,
    String? placeName,
    int? rating,
    String? content,
    String? author,
    DateTime? createdAt,
    XFile? image,
    int? likeCount,
    int? dislikeCount,
    int? userVote,
  }) {
    return Review(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      image: image ?? this.image,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      userVote: userVote ?? this.userVote,
    );
  }
}

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  // ImagePicker 인스턴스 (갤러리에서 이미지 선택 시 사용)
  final ImagePicker _picker = ImagePicker();

  // TODO: 추후 백엔드 API에서 여행지 목록을 가져오도록 수정
  // 선택 가능한 여행지 목록 (더미 데이터)
  static final List<Place> _availablePlaces = [
    Place(id: 'seoul', name: '서울'),
    Place(id: 'busan', name: '부산'),
    Place(id: 'jeju', name: '제주'),
    Place(id: 'incheon', name: '인천'),
    Place(id: 'gangneung', name: '강릉'),
  ];

  // 현재 선택된 여행지 ID (null이면 전체 보기)
  String? _selectedPlaceId;

  // TODO: 추후 백엔드 API에서 리뷰 리스트를 가져오도록 수정
  // 리뷰 리스트를 상태로 관리
  // 초기에는 더미 데이터를 포함
  List<Review> _reviews = [
    Review(
      id: '1',
      placeId: 'seoul',
      placeName: '경복궁',
      rating: 5,
      content: '한국의 역사를 느낄 수 있는 아름다운 곳입니다! 조선 왕조의 대표적인 궁궐로 정말 인상적이었어요.',
      author: 'Traveler123',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      likeCount: 12,
      dislikeCount: 1,
      userVote: 0,
    ),
    Review(
      id: '2',
      placeId: 'seoul',
      placeName: '명동 거리',
      rating: 4,
      content: '쇼핑하기 좋지만 사람이 많아요. 다양한 브랜드와 맛집이 있어서 좋습니다.',
      author: 'KoreaLover',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      likeCount: 8,
      dislikeCount: 2,
      userVote: 0,
    ),
    Review(
      id: '3',
      placeId: 'seoul',
      placeName: '한강 공원',
      rating: 5,
      content: '저녁에 산책하기 완벽한 장소입니다. 야경도 아름답고 분위기가 좋아요.',
      author: 'SeoulExplorer',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likeCount: 15,
      dislikeCount: 0,
      userVote: 0,
    ),
    Review(
      id: '4',
      placeId: 'busan',
      placeName: '해운대 해수욕장',
      rating: 5,
      content: '부산의 대표 해변으로 정말 아름답습니다. 일몰이 특히 장관이에요!',
      author: 'BeachLover',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      likeCount: 20,
      dislikeCount: 1,
      userVote: 0,
    ),
    Review(
      id: '5',
      placeId: 'busan',
      placeName: '자갈치 시장',
      rating: 4,
      content: '신선한 해산물을 맛볼 수 있는 곳입니다. 활기찬 분위기가 좋아요.',
      author: 'Foodie',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      likeCount: 10,
      dislikeCount: 0,
      userVote: 0,
    ),
    Review(
      id: '6',
      placeId: 'jeju',
      placeName: '성산일출봉',
      rating: 5,
      content: '유네스코 세계자연유산으로 정말 인상적입니다. 일출을 보러 가는 것을 추천해요!',
      author: 'NatureLover',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
      likeCount: 25,
      dislikeCount: 0,
      userVote: 0,
    ),
    Review(
      id: '7',
      placeId: 'incheon',
      placeName: '인천 차이나타운',
      rating: 4,
      content: '한국 최대 차이나타운으로 중국 음식과 문화를 경험할 수 있어요.',
      author: 'CultureExplorer',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      likeCount: 7,
      dislikeCount: 1,
      userVote: 0,
    ),
    Review(
      id: '8',
      placeId: 'gangneung',
      placeName: '경포대 해수욕장',
      rating: 5,
      content: '강릉의 대표 해변으로 깨끗하고 아름다운 곳입니다. 커피거리도 가까워서 좋아요.',
      author: 'CoastalTraveler',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      likeCount: 18,
      dislikeCount: 0,
      userVote: 0,
    ),
  ];

  // 선택된 여행지에 따라 필터링된 리뷰 리스트
  List<Review> get _filteredReviews {
    if (_selectedPlaceId == null) {
      return _reviews;
    }
    return _reviews.where((review) => review.placeId == _selectedPlaceId).toList();
  }

  // 선택된 여행지 이름 가져오기
  String _getPlaceName(String? placeId) {
    if (placeId == null) return '전체';
    final place = _availablePlaces.firstWhere(
      (p) => p.id == placeId,
      orElse: () => Place(id: placeId, name: placeId),
    );
    return place.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단: 지도 영역 + 여행지 선택
          _buildTopSection(),
          
          // 리뷰 목록
          Expanded(
            child: _buildReviewList(),
          ),
        ],
      ),
      // 오른쪽 아래 플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReviewDialog,
        child: const Icon(Icons.add),
        tooltip: '리뷰 작성',
      ),
    );
  }

  // === 상단 섹션 (지도 영역 + 여행지 선택) ===
  Widget _buildTopSection() {
    return Column(
      children: [
        // 지도 영역 Placeholder
        // TODO: 추후 실제 지도 위젯(GoogleMap 등)으로 교체
        _buildMapPlaceholder(),
        
        const SizedBox(height: 16),
        
        // 여행지 선택 칩 영역
        _buildPlaceSelector(),
        
        const SizedBox(height: 8),
      ],
    );
  }

  // === 지도 영역 Placeholder ===
  // TODO: 추후 실제 지도 SDK(google_maps_flutter 등) 연동 시 이 부분을 GoogleMap 위젯으로 교체
  Widget _buildMapPlaceholder() {
    return Container(
      height: 230,
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              '지도 영역 - 나중에 실제 지도 연동 예정',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '(추후 Google Maps / Kakao Map 연동)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // === 여행지 선택 칩 영역 ===
  Widget _buildPlaceSelector() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          // 전체 보기 칩
          _buildPlaceChip(null, '전체 보기'),
          const SizedBox(width: 8),
          // 각 여행지 칩
          ..._availablePlaces.map((place) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildPlaceChip(place.id, place.name),
            );
          }),
        ],
      ),
    );
  }

  // === 여행지 선택 칩 ===
  Widget _buildPlaceChip(String? placeId, String label) {
    final isSelected = _selectedPlaceId == placeId;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPlaceId = selected ? placeId : null;
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  // === 리뷰 목록 ===
  Widget _buildReviewList() {
    final filteredReviews = _filteredReviews;

    if (filteredReviews.isEmpty) {
      return Center(
        child: Text(
          _selectedPlaceId == null
              ? '아직 리뷰가 없습니다.\n첫 리뷰를 작성해보세요!'
              : '${_getPlaceName(_selectedPlaceId)}에 대한 리뷰가 없습니다.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredReviews.length,
      itemBuilder: (context, index) {
        // 원본 리스트에서의 인덱스 찾기
        final review = filteredReviews[index];
        final originalIndex = _reviews.indexWhere((r) => r.id == review.id);
        return _buildReviewCard(review, originalIndex >= 0 ? originalIndex : index);
      },
    );
  }

  // === 리뷰 카드 ===
  Widget _buildReviewCard(Review review, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === 이미지 첨부 영역 ===
          // 이미지가 있는 경우에만 썸네일 표시
          if (review.image != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(review.image!.path),
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 여행지 이름과 별점
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 도시 태그
                          Text(
                            '[${_getPlaceName(review.placeId)}] ${review.placeName}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // 별점 표시 (1~5개 별 아이콘)
                    Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          starIndex < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 리뷰 내용 (두 줄만 표시)
                Text(
                  review.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 작성자 정보
                Row(
                  children: [
                    Text(
                      '작성자: ${review.author}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '·',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(review.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // === 추천/비추천 버튼 영역 ===
                Row(
                  children: [
                    // 추천 버튼
                    Expanded(
                      child: _buildVoteButton(
                        icon: Icons.thumb_up,
                        label: '추천',
                        count: review.likeCount,
                        isSelected: review.userVote == 1,
                        onTap: () => _toggleLike(index),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 비추천 버튼
                    Expanded(
                      child: _buildVoteButton(
                        icon: Icons.thumb_down,
                        label: '비추천',
                        count: review.dislikeCount,
                        isSelected: review.userVote == -1,
                        onTap: () => _toggleDislike(index),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // === 추천/비추천 버튼 위젯 ===
  Widget _buildVoteButton({
    required IconData icon,
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === 추천 버튼 토글 처리 ===
  void _toggleLike(int reviewIndex) {
    setState(() {
      final review = _reviews[reviewIndex];
      int newLikeCount = review.likeCount;
      int newDislikeCount = review.dislikeCount;
      int newUserVote = review.userVote;

      if (review.userVote == 0) {
        // 아무것도 선택하지 않은 상태에서 추천 클릭
        newLikeCount = review.likeCount + 1;
        newUserVote = 1;
      } else if (review.userVote == 1) {
        // 이미 추천을 눌러 둔 상태에서 추천 재클릭 (해제)
        newLikeCount = (review.likeCount - 1).clamp(0, double.infinity).toInt();
        newUserVote = 0;
      } else if (review.userVote == -1) {
        // 비추천이 선택된 상태에서 추천 클릭 (전환)
        newDislikeCount = (review.dislikeCount - 1).clamp(0, double.infinity).toInt();
        newLikeCount = review.likeCount + 1;
        newUserVote = 1;
      }

      // 리뷰 상태 업데이트
      _reviews[reviewIndex] = review.copyWith(
        likeCount: newLikeCount,
        dislikeCount: newDislikeCount,
        userVote: newUserVote,
      );
    });
  }

  // === 비추천 버튼 토글 처리 ===
  void _toggleDislike(int reviewIndex) {
    setState(() {
      final review = _reviews[reviewIndex];
      int newLikeCount = review.likeCount;
      int newDislikeCount = review.dislikeCount;
      int newUserVote = review.userVote;

      if (review.userVote == 0) {
        // 아무것도 선택하지 않은 상태에서 비추천 클릭
        newDislikeCount = review.dislikeCount + 1;
        newUserVote = -1;
      } else if (review.userVote == -1) {
        // 이미 비추천을 눌러 둔 상태에서 비추천 재클릭 (해제)
        newDislikeCount = (review.dislikeCount - 1).clamp(0, double.infinity).toInt();
        newUserVote = 0;
      } else if (review.userVote == 1) {
        // 추천이 선택된 상태에서 비추천 클릭 (전환)
        newLikeCount = (review.likeCount - 1).clamp(0, double.infinity).toInt();
        newDislikeCount = review.dislikeCount + 1;
        newUserVote = -1;
      }

      // 리뷰 상태 업데이트
      _reviews[reviewIndex] = review.copyWith(
        likeCount: newLikeCount,
        dislikeCount: newDislikeCount,
        userVote: newUserVote,
      );
    });
  }

  // === 날짜 포맷팅 ===
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  // === 리뷰 작성 다이얼로그 표시 ===
  void _showAddReviewDialog() {
    // 입력값을 저장할 변수들
    final contentController = TextEditingController();
    int selectedRating = 5; // 기본값 5점
    XFile? selectedImage; // 선택된 이미지 파일
    String? selectedPlaceId = _selectedPlaceId; // 기본값은 현재 선택된 여행지

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '리뷰 작성',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 여행지 선택 드롭다운
                  DropdownButtonFormField<String>(
                    value: selectedPlaceId,
                    decoration: const InputDecoration(
                      labelText: '여행지 선택',
                      hintText: '여행지를 선택하세요',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    items: _availablePlaces.map((place) {
                      return DropdownMenuItem<String>(
                        value: place.id,
                        child: Text(place.name),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setModalState(() {
                        selectedPlaceId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 별점 선택
                  Text(
                    '별점',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  
                  // === 이미지 선택 영역 ===
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '사진 첨부 (선택사항)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      // 선택된 이미지 미리보기
                      if (selectedImage != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(selectedImage!.path),
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // 이미지 삭제 버튼
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () {
                                      setModalState(() {
                                        selectedImage = null;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // 이미지 선택 버튼
                      OutlinedButton.icon(
                        onPressed: () async {
                          // 갤러리에서 이미지 선택
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                            maxWidth: 1024,
                            maxHeight: 1024,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            setModalState(() {
                              selectedImage = image;
                            });
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: Text(selectedImage == null ? '갤러리에서 선택' : '이미지 변경'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 리뷰 내용 입력
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: '리뷰 내용',
                      hintText: '여행지에 대한 리뷰를 작성해주세요.',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  
                  // 등록 버튼
                  ElevatedButton(
                    onPressed: () {
                      // 입력값 검증
                      if (selectedPlaceId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('여행지를 선택해주세요.'),
                          ),
                        );
                        return;
                      }

                      if (contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('리뷰 내용을 입력해주세요.'),
                          ),
                        );
                        return;
                      }

                      // 선택된 여행지 정보 가져오기
                      final selectedPlace = _availablePlaces.firstWhere(
                        (p) => p.id == selectedPlaceId,
                      );

                      // setState를 호출하여 리뷰 리스트에 새 리뷰 추가
                      setState(() {
                        _reviews.insert(
                          0,
                          Review(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            placeId: selectedPlaceId!,
                            placeName: selectedPlace.name,
                            rating: selectedRating,
                            content: contentController.text,
                            author: 'User${_reviews.length + 1}',
                            createdAt: DateTime.now(),
                            image: selectedImage,
                            likeCount: 0,
                            dislikeCount: 0,
                            userVote: 0,
                          ),
                        );
                      });

                      // 다이얼로그 닫기
                      Navigator.pop(context);

                      // 성공 메시지
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('리뷰가 등록되었습니다.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('등록'),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
