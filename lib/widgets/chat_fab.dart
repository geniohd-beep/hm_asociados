import 'package:flutter/material.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/widgets/chat_bot.dart';
import 'package:hm_asociados/services/ai_service.dart';

class ChatFAB extends StatelessWidget {
  final AIService? aiService;

  const ChatFAB({super.key, this.aiService});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openChat(context),
      backgroundColor: AppTheme.primaryGold,
      child: const Icon(Icons.chat, color: Colors.white),
    );
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy, color: AppTheme.primaryGold, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Asistente HM',
                      style: TextStyle(
                        color: AppTheme.primaryGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: ChatBot(aiService: aiService),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
