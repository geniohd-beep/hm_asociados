import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/models/blog_post.dart';

class BlogDetailScreen extends StatelessWidget {
  final BlogPost post;

  const BlogDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLOG JURÍDICO')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(post.icon, color: AppTheme.primaryGold, size: 24),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primaryGold),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    post.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryGold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              post.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${post.author} · ${post.date}',
              style: const TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 60, height: 2, color: AppTheme.primaryGold),
            const SizedBox(height: 24),
            Text(
              post.content,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textDark,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
