import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hm_asociados/theme/app_theme.dart';
import 'package:hm_asociados/models/client.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final List<Client> _clients = [];
  int _nextId = 1;

  void _addClient(Client client) {
    _clients.add(client);
  }

  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addrCtrl = TextEditingController();
    final casesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registrarse como Cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Nombre completo', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Celular', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: casesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Casos',
                  hintText: 'Ej: Laboral, Corporativo...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              _addClient(Client(
                id: (_nextId++).toString(),
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                address: addrCtrl.text.trim(),
                cases: casesCtrl.text.trim(),
              ));
              Navigator.pop(ctx);
              _showSuccessDialog();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Registro exitoso'),
        content: const Text('El cliente se ha registrado correctamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continuar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showAddDialog();
            },
            child: const Text('Registrar a otro usuario'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: AppTheme.primaryGold.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              'Registro de Clientes',
              style: GoogleFonts.cinzel(
                fontSize: 22,
                color: AppTheme.primaryGold,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 60, height: 2, color: AppTheme.primaryGold),
            const SizedBox(height: 16),
            Text(
              'Gestión interna de clientes',
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.person_add, size: 20),
              label: const Text('REGISTRARSE COMO CLIENTE'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


