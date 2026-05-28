import 'package:flutter/material.dart';
import 'package:hm_asociados/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Carlos López');
  final _emailController = TextEditingController(text: 'carlos.lopez@email.com');
  final _phoneController = TextEditingController(text: '+51 999 888 777');
  final _rucController = TextEditingController(text: '20456789012');

  String _selectedRole = 'Cliente';

  final List<String> _roles = ['Cliente', 'Abogado', 'Empresa'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MI PERFIL')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppTheme.primaryGold,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt, size: 18),
              label: const Text('Cambiar foto'),
            ),
            const SizedBox(height: 32),
            _buildField('Nombre completo', _nameController),
            const SizedBox(height: 16),
            _buildField('Correo electrónico', _emailController),
            const SizedBox(height: 16),
            _buildField('Teléfono', _phoneController),
            const SizedBox(height: 16),
            _buildField('RUC', _rucController),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Tipo de usuario',
                border: OutlineInputBorder(),
              ),
              items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Perfil actualizado correctamente')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'GUARDAR CAMBIOS',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cerrar sesión'),
                    content: const Text('¿Está seguro de que desea cerrar sesión?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                'CERRAR SESIÓN',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
