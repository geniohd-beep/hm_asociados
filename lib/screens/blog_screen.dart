import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/models/blog_data.dart';
import 'package:hm_asociados/models/blog_post.dart';
import 'package:hm_asociados/screens/blog_detail_screen.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  static const List<String> _categories = [
    'Tributario',
    'Laboral',
    'Corporativo',
    'Familia',
    'Penal',
    'Civil',
    'Constitucional',
    'Administrativo',
    'Propiedad Intelectual',
    'Ambiental',
    'Consumidor',
    'Digital',
  ];

  List<BlogPost> get _filteredPosts {
    return blogPosts.where((post) {
      final matchesCategory = _selectedCategory == null || post.category == _selectedCategory;
      if (!matchesCategory) return false;
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return post.title.toLowerCase().contains(query) ||
          post.excerpt.toLowerCase().contains(query) ||
          post.content.toLowerCase().contains(query) ||
          post.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPosts;

    return Material(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar artículos...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _FilterChip(
                    label: 'TODOS',
                    selected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ..._categories.map((c) => _FilterChip(
                        label: c.toUpperCase(),
                        selected: _selectedCategory == c,
                        onTap: () => setState(() => _selectedCategory = _selectedCategory == c ? null : c),
                      )),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron artículos',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _BlogCard(post: filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryGold),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? Colors.white : AppTheme.primaryGold,
            ),
          ),
        ),
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
      margin: const EdgeInsets.only(top: 16),
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
