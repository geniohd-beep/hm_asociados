import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/widgets/service_card.dart';
import 'package:hm_asociados/widgets/chat_bot.dart';
import 'package:hm_asociados/models/services_data.dart';
import 'package:hm_asociados/screens/blog_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final servicesKey = GlobalKey();
    final contactKey = GlobalKey();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(servicesKey: servicesKey, contactKey: contactKey),
            _AboutSection(),
            _ServicesSection(key: servicesKey),
            _StatsSection(),
            _ContactSection(key: contactKey),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final GlobalKey servicesKey;
  final GlobalKey contactKey;

  const _HeroSection({required this.servicesKey, required this.contactKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primaryDarkLight],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryGold, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'HM & ASOCIADOS',
              style: GoogleFonts.cinzel(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
                letterSpacing: 6,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ESTUDIO JURÍDICO',
            style: GoogleFonts.cinzel(
              fontSize: 16,
              color: AppTheme.accentGold,
              letterSpacing: 12,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Excelencia legal con visión global.\nMás de 30 años defendiendo los intereses\nde nuestros clientes.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textLight,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _HeroButton(
                label: 'NUESTROS SERVICIOS',
                onTap: () => _scrollTo(context, servicesKey),
              ),
              _HeroButton(
                label: 'CONTACTO',
                onTap: () => _scrollTo(context, contactKey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _scrollTo(BuildContext context, GlobalKey key) {
    final context_ = key.currentContext;
    if (context_ != null) {
      Scrollable.ensureVisible(
        context_,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
}

class _HeroButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HeroButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.primaryGold,
        side: const BorderSide(color: AppTheme.primaryGold),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, letterSpacing: 2)),
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      color: AppTheme.surfaceDark,
      child: Column(
        children: [
          Text(
            'NUESTRO DESPACHO',
            style: GoogleFonts.cinzel(
              fontSize: 28,
              color: AppTheme.primaryGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(width: 60, height: 2, color: AppTheme.primaryGold),
          const SizedBox(height: 24),
          Text(
            'Somos un despacho jurídico de primer nivel con presencia en todo el Perú. '
            'Nuestro equipo está conformado por más de 50 abogados especializados en las '
            'distintas ramas del derecho, egresados de las mejores universidades del país '
            'y con experiencia en los casos más complejos y relevantes del ámbito nacional.\n\n'
            'En HM & Asociados combinamos la tradición jurídica con la innovación tecnológica '
            'para ofrecer soluciones legales integrales que anticipan las necesidades de '
            'nuestros clientes en un entorno cada vez más dinámico y exigente.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textDark,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 40, 0, 24),
      child: Column(
        children: [
          Text(
            'ÁREAS DE PRÁCTICA',
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Soluciones legales integrales para cada necesidad',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...services.map(
            (s) => ServiceCard(
              title: s.title,
              description: s.description,
              icon: s.icon,
              details: s.details,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlogScreen()),
              ),
              icon: const Icon(Icons.article),
              label: const Text('VER BLOG'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGold,
                side: const BorderSide(color: AppTheme.primaryGold),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDarkLight, AppTheme.primaryDark],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(number: '50+', label: 'ABOGADOS'),
          _StatItem(number: '30+', label: 'AÑOS DE\nEXPERIENCIA'),
          _StatItem(number: '5K+', label: 'CASOS\nEXITOSOS'),
          _StatItem(number: '15', label: 'PAÍSES CON\nPRESENCIA'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String number;
  final String label;

  const _StatItem({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: GoogleFonts.playfairDisplay(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.textLight,
              letterSpacing: 1,
            ),
        ),
      ],
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            text: 'Av. Paseo de la República 3587\nSan Isidro, Lima 15047',
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
