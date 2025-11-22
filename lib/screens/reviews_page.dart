// 이 파일은 여행지 리뷰 페이지입니다.
// 더미 리뷰 목록을 표시하고, 앱 실행 중에만 유지되는 리뷰 작성 기능을 제공합니다.
// setState를 사용하여 리뷰 리스트를 상태로 관리합니다.

import 'package:flutter/material.dart';

// 리뷰 데이터 모델 (간단한 구조)
class Review {
  final String placeName;
  final int rating;
  final String content;
  final String author;

  Review({
    required this.placeName,
    required this.rating,
    required this.content,
    required this.author,
  });
}

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  // 리뷰 리스트를 상태로 관리
  // 초기에는 더미 데이터 3개를 포함
  List<Review> _reviews = [
    Review(
      placeName: '경복궁',
      rating: 5,
      content: '한국의 역사를 느낄 수 있는 아름다운 곳입니다!',
      author: 'Traveler123',
    ),
    Review(
      placeName: '명동 거리',
      rating: 4,
      content: '쇼핑하기 좋지만 사람이 많아요.',
      author: 'KoreaLover',
    ),
    Review(
      placeName: '한강 공원',
      rating: 5,
      content: '저녁에 산책하기 완벽한 장소입니다.',
      author: 'SeoulExplorer',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단 설명 섹션
          _buildHeader(),
          
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

  // 상단 헤더
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '여행지 리뷰',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '다른 여행자들의 리뷰를 확인하고 나만의 리뷰를 작성해보세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // 리뷰 목록
  Widget _buildReviewList() {
    if (_reviews.isEmpty) {
      return Center(
        child: Text(
          '아직 리뷰가 없습니다.\n첫 리뷰를 작성해보세요!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        return _buildReviewCard(_reviews[index]);
      },
    );
  }

  // 리뷰 카드
  Widget _buildReviewCard(Review review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 여행지 이름과 별점
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.placeName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                // 별점 표시 (1~5개 별 아이콘)
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 리뷰 내용
            Text(
              review.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // 작성자 정보
            Text(
              '작성자: ${review.author}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // 리뷰 작성 다이얼로그 표시
  void _showAddReviewDialog() {
    // 입력값을 저장할 변수들
    final placeNameController = TextEditingController();
    final contentController = TextEditingController();
    int selectedRating = 5; // 기본값 5점

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
                  
                  // 여행지 이름 입력
                  TextField(
                    controller: placeNameController,
                    decoration: const InputDecoration(
                      labelText: '여행지 이름',
                      hintText: '예: 경복궁',
                      border: OutlineInputBorder(),
                    ),
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
                          // setModalState를 사용하여 bottom sheet 내부 상태 업데이트
                          setModalState(() {
                            selectedRating = index + 1;
                          });
                        },
                      );
                    }),
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
                      if (placeNameController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('모든 항목을 입력해주세요.'),
                          ),
                        );
                        return;
                      }

                      // setState를 호출하여 리뷰 리스트에 새 리뷰 추가
                      setState(() {
                        _reviews.insert(
                          0,
                          Review(
                            placeName: placeNameController.text,
                            rating: selectedRating,
                            content: contentController.text,
                            author: 'User${_reviews.length + 1}', // 더미 작성자명
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

