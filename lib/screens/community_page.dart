// 이 파일은 게시판(커뮤니티) 페이지입니다.
// 게시글 목록을 표시하고, 필터/검색 기능을 제공합니다.
// DB 없이 앱 실행 중 메모리에서만 데이터를 관리합니다.
// TODO: 추후 백엔드 API 연동 예정

import 'package:flutter/material.dart';
import 'community_detail_page.dart';
import 'community_write_page.dart';

// === 게시글 데이터 모델 ===
// TODO: 추후 백엔드 API에서 받아온 데이터로 교체
class Post {
  final int id;
  final String title;
  final String content;
  final String region;      // 지역 (예: 서울, 부산, 제주 등)
  final String category;   // 카테고리 (날씨, 양도, 동행, 후기, Q&A, 선택 안 함)
  final String author;      // 작성자
  final DateTime createdAt;
  final List<Comment> comments; // 댓글 리스트

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.region,
    required this.category,
    required this.author,
    required this.createdAt,
    List<Comment>? comments,
  }) : comments = comments ?? [];
}

// === 댓글 데이터 모델 ===
// TODO: 추후 백엔드 API에서 받아온 데이터로 교체
class Comment {
  final String author;      // 작성자 (지금은 "익명"으로 고정)
  final String content;     // 댓글 내용
  final DateTime createdAt; // 작성 시간

  Comment({
    required this.author,
    required this.content,
    required this.createdAt,
  });
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // TODO: 추후 실제 수집 지역과 연동
  // 선택 가능한 지역 목록
  static const List<String> _availableRegions = [
    '전체',
    '서울',
    '부산',
    '제주',
  ];

  // 필터용 카테고리 목록 (작성 시에는 '선택 안 함'도 포함)
  static const List<String> _filterCategories = [
    '전체',
    '날씨',
    '양도',
    '동행',
    '후기',
    'Q&A',
  ];

  // TODO: 추후 백엔드 API에서 게시글 리스트를 가져오도록 수정
  // 게시글 리스트를 상태로 관리 (원본 데이터)
  List<Post> _allPosts = [
    Post(
      id: 1,
      title: '서울 여행 일정 추천 부탁드려요!',
      content: '3일간 서울을 여행하려고 하는데 추천 일정이 있을까요? 경복궁, 명동, 한강 공원 정도를 가려고 하는데 시간 배분이 어렵네요.',
      region: '서울',
      category: 'Q&A',
      author: 'Traveler123',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      comments: [
        Comment(
          author: '익명1',
          content: '경복궁은 오전에 가시는 걸 추천해요!',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        Comment(
          author: '익명2',
          content: '명동은 저녁에 가면 더 분위기 좋아요.',
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        ),
      ],
    ),
    Post(
      id: 2,
      title: '부산 해운대 후기',
      content: '해운대 해수욕장이 정말 아름다웠습니다. 특히 일몰이 장관이었어요! 주변 맛집도 많아서 좋았습니다.',
      region: '부산',
      category: '후기',
      author: 'BeachLover',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      comments: [
        Comment(
          author: '익명1',
          content: '저도 가봤는데 정말 좋았어요!',
          createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        ),
      ],
    ),
    Post(
      id: 3,
      title: '제주도 동행 구합니다',
      content: '다음 주말에 제주도 여행 가실 분 있나요? 렌터카 함께 빌려서 비용 절감하고 싶어요.',
      region: '제주',
      category: '동행',
      author: 'JejuExplorer',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      comments: [],
    ),
    Post(
      id: 4,
      title: '서울 날씨 정보 공유',
      content: '오늘 서울 날씨가 정말 좋네요! 외출하기 딱 좋은 날씨입니다.',
      region: '서울',
      category: '날씨',
      author: 'WeatherWatcher',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      comments: [],
    ),
    Post(
      id: 5,
      title: '부산 자갈치 시장 맛집 추천',
      content: '자갈치 시장에서 먹은 회 정말 맛있었어요! 신선하고 가격도 합리적이었습니다.',
      region: '부산',
      category: '후기',
      author: 'Foodie',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      comments: [],
    ),
  ];

  // 필터 상태
  String _selectedRegion = '전체';
  String _selectedCategory = '전체';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 필터링된 게시글 리스트
  List<Post> get _filteredPosts {
    return _allPosts.where((post) {
      // 지역 필터
      if (_selectedRegion != '전체' && post.region != _selectedRegion) {
        return false;
      }

      // 카테고리 필터
      if (_selectedCategory != '전체' && post.category != _selectedCategory) {
        return false;
      }

      // 검색어 필터
      final searchKeyword = _searchController.text.trim().toLowerCase();
      if (searchKeyword.isNotEmpty) {
        final titleMatch = post.title.toLowerCase().contains(searchKeyword);
        final contentMatch = post.content.toLowerCase().contains(searchKeyword);
        if (!titleMatch && !contentMatch) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단 필터 & 검색 영역
          _buildFilterSection(),
          
          // 게시글 목록
          Expanded(
            child: _buildPostList(),
          ),
        ],
      ),
      // 오른쪽 아래 플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToWritePage,
        child: const Icon(Icons.edit),
        tooltip: '글쓰기',
      ),
    );
  }

  // === 필터 & 검색 영역 ===
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '여행 커뮤니티',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          
          // 지역 선택
          Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 8),
              Text(
                '지역',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedRegion,
                  isExpanded: true,
                  items: _availableRegions.map((region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedRegion = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 카테고리 선택
          Row(
            children: [
              const Icon(Icons.category, size: 20),
              const SizedBox(width: 8),
              Text(
                '카테고리',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  items: _filterCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 검색창
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '제목 또는 내용 검색',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  // === 게시글 목록 ===
  Widget _buildPostList() {
    final filteredPosts = _filteredPosts;

    if (filteredPosts.isEmpty) {
      return Center(
        child: Text(
          '게시글이 없습니다.\n첫 게시글을 작성해보세요!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey,
              ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(filteredPosts[index]);
      },
    );
  }

  // === 게시글 카드 ===
  Widget _buildPostCard(Post post) {
    final commentCount = post.comments.length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // 상세 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityDetailPage(post: post),
            ),
          ).then((_) {
            // 상세 페이지에서 돌아왔을 때 댓글이 추가되었을 수 있으므로 화면 갱신
            setState(() {});
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카테고리와 지역
              Row(
                children: [
                  // 지역 태그
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      post.region,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 카테고리 태그
                  _buildCategoryChip(post.category),
                ],
              ),
              const SizedBox(height: 8),
              
              // 제목
              Text(
                post.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // 내용 일부 (1~2줄만)
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              
              // 작성자, 작성일, 댓글 개수
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    post.author,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  Row(
                    children: [
                      // 댓글 개수 표시 (작은 글씨)
                      Text(
                        '댓글 $commentCount개',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                      ),
                      const SizedBox(width: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  // 카테고리 칩 위젯
  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getCategoryColor(category),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // 카테고리별 색상 반환
  Color _getCategoryColor(String category) {
    switch (category) {
      case '날씨':
        return Colors.lightBlue;
      case '양도':
        return Colors.orange;
      case '동행':
        return Colors.purple;
      case '후기':
        return Colors.green;
      case 'Q&A':
        return Colors.blue;
      case '선택 안 함':
        return Colors.grey;
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

  // === 글쓰기 페이지로 이동 ===
  void _navigateToWritePage() async {
    final result = await Navigator.push<Post>(
      context,
      MaterialPageRoute(
        builder: (context) => const CommunityWritePage(),
      ),
    );

    // 글쓰기 페이지에서 게시글을 작성하고 돌아왔을 때
    if (result != null) {
      setState(() {
        _allPosts.insert(0, result);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('게시글이 등록되었습니다.'),
        ),
      );
    }
  }
}

