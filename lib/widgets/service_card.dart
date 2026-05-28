import 'package:flutter/material.dart';
import 'package:hm_asociados/theme/app_theme.dart';

class ServiceCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<String> details;

  const ServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.details,
  });

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (val) => setState(() => _expanded = val),
        leading: Icon(widget.icon, color: AppTheme.primaryGold, size: 32),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppTheme.primaryGold,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          widget.description,
          style: const TextStyle(fontSize: 13),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                ...widget.details.map(
                  (d) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppTheme.primaryGold, size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(d, style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
