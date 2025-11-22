// 이 파일은 게시판(커뮤니티) 페이지입니다.
// 게시글 목록을 표시하고, 글 작성 및 상세 보기 기능을 제공합니다.
// DB 없이 앱 실행 중 메모리에서만 데이터를 관리합니다.

import 'package:flutter/material.dart';
import 'post_detail_page.dart';

// 게시글 데이터 모델
class Post {
  final String id;
  final String title;
  final String category;
  final String content;
  final String author;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.author,
    required this.createdAt,
  });
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // 게시글 리스트를 상태로 관리
  // 초기에는 더미 게시글 3개를 포함
  List<Post> _posts = [
    Post(
      id: '1',
      title: '서울 여행 일정 추천 부탁드려요!',
      category: 'Q&A',
      content: '3일간 서울을 여행하려고 하는데 추천 일정이 있을까요?',
      author: 'Traveler123',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Post(
      id: '2',
      title: '부산 해운대 후기',
      category: '후기',
      content: '해운대 해수욕장이 정말 아름다웠습니다. 특히 일몰이 장관이었어요!',
      author: 'BeachLover',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Post(
      id: '3',
      title: '제주도 동행 구합니다',
      category: '동행구하기',
      content: '다음 주말에 제주도 여행 가실 분 있나요?',
      author: 'JejuExplorer',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // 게시글 카테고리 목록
  final List<String> _categories = ['Q&A', '후기', '동행구하기'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단 헤더
          _buildHeader(),
          
          // 게시글 목록
          Expanded(
            child: _buildPostList(),
          ),
        ],
      ),
      // 오른쪽 아래 플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPostDialog,
        child: const Icon(Icons.add),
        tooltip: '글 작성',
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
            '여행 커뮤니티',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '다른 여행자들과 정보를 공유하고 소통해보세요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // 게시글 목록
  Widget _buildPostList() {
    if (_posts.isEmpty) {
      return Center(
        child: Text(
          '아직 게시글이 없습니다.\n첫 게시글을 작성해보세요!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_posts[index]);
      },
    );
  }

  // 게시글 카드
  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigator.push를 사용하여 상세 페이지로 이동
          // MaterialPageRoute를 통해 화면 전환 애니메이션과 함께 새 페이지를 표시
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리와 제목
              Row(
                children: [
                  // 카테고리 태그
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(post.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 제목
                  Expanded(
                    child: Text(
                      post.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 미리보기 내용
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // 작성자 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '작성자: ${post.author}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Text(
                    _formatDate(post.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 카테고리별 색상 반환
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Q&A':
        return Colors.blue;
      case '후기':
        return Colors.green;
      case '동행구하기':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 날짜 포맷팅
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

  // 게시글 작성 다이얼로그 표시
  void _showAddPostDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String selectedCategory = _categories[0];

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
                        '게시글 작성',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // 제목 입력
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: '제목',
                      hintText: '게시글 제목을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 카테고리 선택
                  Text(
                    '카테고리',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 본문 입력
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: '본문',
                      hintText: '게시글 내용을 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 6,
                  ),
                  const SizedBox(height: 24),
                  
                  // 등록 버튼
                  ElevatedButton(
                    onPressed: () {
                      // 입력값 검증
                      if (titleController.text.isEmpty ||
                          contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('제목과 본문을 모두 입력해주세요.'),
                          ),
                        );
                        return;
                      }

                      // setState를 호출하여 게시글 리스트에 새 게시글 추가
                      // insert(0, ...)로 최신 글이 맨 위에 오도록 함
                      setState(() {
                        _posts.insert(
                          0,
                          Post(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleController.text,
                            category: selectedCategory,
                            content: contentController.text,
                            author: 'User${_posts.length + 1}',
                            createdAt: DateTime.now(),
                          ),
                        );
                      });

                      // 다이얼로그 닫기
                      Navigator.pop(context);

                      // 성공 메시지
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('게시글이 등록되었습니다.'),
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

