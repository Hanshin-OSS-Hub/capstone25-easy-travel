// 이 파일은 게시글 상세 페이지입니다.
// CommunityPage에서 게시글을 탭했을 때 Navigator.push로 이동하는 페이지입니다.
// 게시글의 제목, 카테고리, 작성자, 본문을 상세히 표시합니다.

import 'package:flutter/material.dart';
import 'community_page.dart';

class PostDetailPage extends StatelessWidget {
  final Post post;

  const PostDetailPage({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 태그
            _buildCategoryTag(),
            const SizedBox(height: 16),
            
            // 제목
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // 작성자 및 작성일
            _buildAuthorInfo(),
            const Divider(),
            const SizedBox(height: 16),
            
            // 본문
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 카테고리 태그
  Widget _buildCategoryTag() {
    Color categoryColor;
    switch (post.category) {
      case 'Q&A':
        categoryColor = Colors.blue;
        break;
      case '후기':
        categoryColor = Colors.green;
        break;
      case '동행구하기':
        categoryColor = Colors.orange;
        break;
      default:
        categoryColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: categoryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        post.category,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 작성자 정보
  Widget _buildAuthorInfo() {
    return Row(
      children: [
        const Icon(Icons.person, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          post.author,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        const Icon(Icons.access_time, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          _formatDate(post.createdAt),
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
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
}

