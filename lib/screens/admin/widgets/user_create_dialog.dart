import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/admin_provider.dart';

class UserCreateDialog extends ConsumerStatefulWidget {
  const UserCreateDialog({super.key});

  @override
  ConsumerState<UserCreateDialog> createState() => _UserCreateDialogState();
}

class _UserCreateDialogState extends ConsumerState<UserCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  String _selectedRole = 'cliente';
  bool _isLoading = false;

  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _usuarioCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _inicialesCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _usuarioCtrl.dispose();
    _passwordCtrl.dispose();
    _inicialesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nombreCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es requerido', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.error));
      return;
    }
    if (_selectedRole != 'cliente' && (_usuarioCtrl.text.isEmpty || _passwordCtrl.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario y contraseña requeridos', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.error));
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (_selectedRole == 'cliente') {
        await SupabaseConfig.client.from('clientes').insert({
          'nombre': _nombreCtrl.text.trim(),
          'telefono': _telefonoCtrl.text.trim(),
          'activo': true,
        });
      } else {
        await SupabaseConfig.client.from('usuarios').insert({
          'nombre': _nombreCtrl.text.trim(),
          'usuario': _usuarioCtrl.text.trim(),
          'password': _passwordCtrl.text.trim(),
          'rol': _selectedRole,
          'iniciales': _inicialesCtrl.text.trim().toUpperCase(),
          'activo': true,
        });
      }

      ref.read(adminProvider.notifier).refresh();
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado exitosamente', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.ok),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Registrar Usuario', style: AppTypography.headingPrincipal.copyWith(fontSize: 20)),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.ink3),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Usuario',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                    DropdownMenuItem(value: 'cobrador', child: Text('Cobrador')),
                    DropdownMenuItem(value: 'asesor', child: Text('Asesor')),
                    DropdownMenuItem(value: 'prestamista', child: Text('Prestamista')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 16),
                
                CustomInput(
                  controller: _nombreCtrl,
                  label: 'Nombre Completo',
                  prefix: const Icon(Icons.badge, color: AppColors.ink3),
                ),
                const SizedBox(height: 16),

                if (_selectedRole == 'cliente') ...[
                  CustomInput(
                    controller: _telefonoCtrl,
                    label: 'Teléfono',
                    prefix: const Icon(Icons.phone, color: AppColors.ink3),
                    keyboardType: TextInputType.phone,
                  ),
                ],

                if (_selectedRole != 'cliente') ...[
                  CustomInput(
                    controller: _usuarioCtrl,
                    label: 'Usuario de Ingreso',
                    prefix: const Icon(Icons.tag, color: AppColors.ink3),
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _passwordCtrl,
                    label: 'Contraseña',
                    prefix: const Icon(Icons.lock, color: AppColors.ink3),
                    obscureText: true,
                  ),
                  if (_selectedRole == 'cobrador') ...[
                    const SizedBox(height: 16),
                    CustomInput(
                      controller: _inicialesCtrl,
                      label: 'Iniciales (2-3 letras)',
                      prefix: const Icon(Icons.text_fields, color: AppColors.ink3),
                    ),
                  ]
                ],
                
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        type: ButtonType.admin,
                        text: 'Registrar',
                        onPressed: _submit,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
