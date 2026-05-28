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
    setState(() => _clients.add(client));
  }

  void _deleteClient(String id) {
    setState(() => _clients.removeWhere((c) => c.id == id));
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  '${_clients.length} cliente${_clients.length == 1 ? '' : 's'}',
                  style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMuted),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('REGISTRARSE COMO CLIENTE'),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: _clients.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 16),
                        Text('No hay clientes registrados',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _showAddDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Registrarse como cliente'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _clients.length,
                    itemBuilder: (_, i) => _ClientCard(
                      client: _clients[i],
                      onDelete: () => _deleteClient(_clients[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final Client client;
  final VoidCallback onDelete;

  const _ClientCard({required this.client, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppTheme.primaryGold, size: 20),
                const SizedBox(width: 8),
                Text(client.name,
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            ),
            const Divider(height: 12),
            if (client.phone.isNotEmpty) ...[
              _InfoRow(icon: Icons.phone, text: client.phone),
              const SizedBox(height: 4),
            ],
            if (client.address.isNotEmpty) ...[
              _InfoRow(icon: Icons.location_on, text: client.address),
              const SizedBox(height: 4),
            ],
            if (client.cases.isNotEmpty) ...[
              _InfoRow(icon: Icons.folder, text: client.cases),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark)),
        ),
      ],
    );
  }
}
