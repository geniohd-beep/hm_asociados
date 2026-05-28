import 'package:flutter/material.dart';

class BlogPost {
  final String title;
  final String excerpt;
  final String content;
  final String author;
  final String date;
  final String category;
  final IconData icon;

  const BlogPost({
    required this.title,
    required this.excerpt,
    required this.content,
    required this.author,
    required this.date,
    required this.category,
    required this.icon,
  });
}
