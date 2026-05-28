import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/models/blog_data.dart';
import 'package:hm_asociados/models/blog_post.dart';
import 'package:hm_asociados/screens/blog_detail_screen.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLOG JURÍDICO')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: blogPosts.length,
        itemBuilder: (context, index) {
          final post = blogPosts[index];
          return _BlogCard(post: post);
        },
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  final BlogPost post;

  const _BlogCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlogDetailScreen(post: post),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(post.icon, color: AppTheme.primaryGold, size: 20),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryGold),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      post.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryGold,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.excerpt,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${post.author} · ${post.date}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                  const Icon(Icons.arrow_forward, color: AppTheme.primaryGold, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
