import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/widgets/chat_bot.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          color: AppTheme.surfaceDark,
          child: Column(
            children: [
              Text(
                'CONTACTO',
                style: GoogleFonts.cinzel(
                  fontSize: 28,
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 60, height: 2, color: AppTheme.primaryGold),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Chatee con nuestro asistente virtual',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              SizedBox(
                height: 400,
                child: Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ChatBot(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              _ContactItem(
                icon: Icons.location_on,
                text: 'Juliaca calle apurimas nro. 1234',
              ),
              const SizedBox(height: 12),
              _ContactItem(
                icon: Icons.phone,
                text: '+51 (1) 555-1234',
              ),
              const SizedBox(height: 12),
              _ContactItem(
                icon: Icons.email,
                text: 'contacto@hm-asociados.pe',
              ),
              const SizedBox(height: 16),
              Text(
                'Horario: Lunes a Viernes 9:00 - 18:00 hrs',
                style: GoogleFonts.inter(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 24),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: AppTheme.textDark,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
