import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/admin_provider.dart';

class AdminClienteCreateView extends ConsumerStatefulWidget {
  const AdminClienteCreateView({super.key});

  @override
  ConsumerState<AdminClienteCreateView> createState() => _AdminClienteCreateViewState();
}

class _AdminClienteCreateViewState extends ConsumerState<AdminClienteCreateView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores Generales
  final _nombresCtrl = TextEditingController();
  final _apePatCtrl = TextEditingController();
  final _apeMatCtrl = TextEditingController();
  final _curpCtrl = TextEditingController();
  final _duiCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  
  String? _sexo;
  String? _estadoNacimiento;

  // Controladores Dirección
  final _calleCtrl = TextEditingController();
  final _numExtCtrl = TextEditingController();
  final _coloniaCtrl = TextEditingController();

  // Controladores Aval
  final _avalNombreCtrl = TextEditingController();
  final _avalParentescoCtrl = TextEditingController();
  final _avalTelefonoCtrl = TextEditingController();
  final _avalCalleCtrl = TextEditingController();
  final _avalNumExtCtrl = TextEditingController();
  final _avalColoniaCtrl = TextEditingController();

  // Fotos (Archivos Locales)
  File? _fotoPerfil;
  File? _fotoIneFrente;
  File? _fotoIneReverso;
  File? _fotoFachada;
  File? _fotoAval;
  File? _fotoComprobanteAval;
  File? _avalIneFrente;
  File? _avalIneReverso;
  File? _fotoFirma;
  File? _fotoContrato;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apePatCtrl.dispose();
    _apeMatCtrl.dispose();
    _curpCtrl.dispose();
    _duiCtrl.dispose();
    _telefonoCtrl.dispose();
    _calleCtrl.dispose();
    _numExtCtrl.dispose();
    _coloniaCtrl.dispose();
    _avalNombreCtrl.dispose();
    _avalParentescoCtrl.dispose();
    _avalTelefonoCtrl.dispose();
    _avalCalleCtrl.dispose();
    _avalNumExtCtrl.dispose();
    _avalColoniaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(Function(File?) onPicked) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (image != null) {
        setState(() {
          onPicked(File(image.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al abrir cámara: $e')));
    }
  }

  Future<String?> _uploadImage(File file, String folder, String fileName) async {
    try {
      final path = '$folder/\${DateTime.now().millisecondsSinceEpoch}_\$fileName';
      await SupabaseConfig.client.storage.from('clientes_archivos').upload(path, file);
      return SupabaseConfig.client.storage.from('clientes_archivos').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error subiendo imagen $fileName: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor completa todos los campos requeridos'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Subir fotos si existen
      String? urlPerfil, urlIneF, urlIneR, urlFachada, urlAval, urlCompAval, urlAvalIneF, urlAvalIneR, urlFirma, urlContrato;

      if (_fotoPerfil != null) urlPerfil = await _uploadImage(_fotoPerfil!, 'perfiles', 'perfil.jpg');
      if (_fotoIneFrente != null) urlIneF = await _uploadImage(_fotoIneFrente!, 'ine', 'ine_f.jpg');
      if (_fotoIneReverso != null) urlIneR = await _uploadImage(_fotoIneReverso!, 'ine', 'ine_r.jpg');
      if (_fotoFachada != null) urlFachada = await _uploadImage(_fotoFachada!, 'fachadas', 'fachada.jpg');
      if (_fotoAval != null) urlAval = await _uploadImage(_fotoAval!, 'aval', 'aval_foto.jpg');
      if (_fotoComprobanteAval != null) urlCompAval = await _uploadImage(_fotoComprobanteAval!, 'aval', 'comp_aval.jpg');
      if (_avalIneFrente != null) urlAvalIneF = await _uploadImage(_avalIneFrente!, 'ine', 'aval_ine_f.jpg');
      if (_avalIneReverso != null) urlAvalIneR = await _uploadImage(_avalIneReverso!, 'ine', 'aval_ine_r.jpg');
      if (_fotoFirma != null) urlFirma = await _uploadImage(_fotoFirma!, 'firmas', 'firma.jpg');
      if (_fotoContrato != null) urlContrato = await _uploadImage(_fotoContrato!, 'contratos', 'contrato.jpg');

      // 2. Construir campos compuestos para retrocompatibilidad
      final fullName = '\${_nombresCtrl.text.trim()} \${_apePatCtrl.text.trim()} \${_apeMatCtrl.text.trim()}'.trim();
      final fullAddress = '\${_calleCtrl.text.trim()} \${_numExtCtrl.text.trim()}, \${_coloniaCtrl.text.trim()}'.trim();

      // 3. Insertar el cliente completo
      await SupabaseConfig.client.from('clientes').insert({
        'nombre': fullName,
        'nombres': _nombresCtrl.text.trim(),
        'apellido_paterno': _apePatCtrl.text.trim(),
        'apellido_materno': _apeMatCtrl.text.trim(),
        'sexo': _sexo,
        'estado_nacimiento': _estadoNacimiento,
        'dui': _duiCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        'direccion': fullAddress,
        'calle': _calleCtrl.text.trim(),
        'numero_exterior': _numExtCtrl.text.trim(),
        'colonia': _coloniaCtrl.text.trim(),
        'curp': _curpCtrl.text.trim(),
        'activo': true,
        'aval_nombre': _avalNombreCtrl.text.trim(),
        'aval_parentesco': _avalParentescoCtrl.text.trim(),
        'aval_telefono': _avalTelefonoCtrl.text.trim(),
        'aval_calle': _avalCalleCtrl.text.trim(),
        'aval_numero_exterior': _avalNumExtCtrl.text.trim(),
        'aval_colonia': _avalColoniaCtrl.text.trim(),
        'foto_perfil_url': urlPerfil,
        'foto_ine_frente_url': urlIneF,
        'foto_ine_reverso_url': urlIneR,
        'foto_fachada_url': urlFachada,
        'foto_aval_url': urlAval,
        'foto_comprobante_aval_url': urlCompAval,
        'aval_ine_frente_url': urlAvalIneF,
        'aval_ine_reverso_url': urlAvalIneR,
        'foto_firma_url': urlFirma,
        'foto_contrato_url': urlContrato,
      });

      // 4. Actualizar estado y cerrar
      if (!mounted) return;
      ref.read(adminProvider.notifier).refresh();

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente guardado exitosamente'), backgroundColor: AppColors.ok));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar cliente: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPhotoField(String title, File? currentFile, Function(File?) onPicked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: currentFile != null ? AppColors.ok : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: currentFile != null ? AppColors.okSurface : AppColors.background,
              borderRadius: BorderRadius.circular(8),
              image: currentFile != null ? DecorationImage(image: FileImage(currentFile), fit: BoxFit.cover) : null,
            ),
            child: currentFile == null ? const Icon(Icons.camera_alt, color: AppColors.ink4) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                Text(currentFile != null ? 'Capturada' : 'Tocar para tomar foto', style: TextStyle(fontSize: 10, color: currentFile != null ? AppColors.ok : AppColors.ink4)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(currentFile != null ? Icons.check_circle : Icons.add_circle, color: currentFile != null ? AppColors.ok : AppColors.admin),
            onPressed: () => _pickImage(onPicked),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(title.toUpperCase(), style: AppTypography.label.copyWith(fontSize: 11, color: AppColors.admin, letterSpacing: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrar Cliente'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        titleTextStyle: AppTypography.headingPrincipal.copyWith(fontSize: 18),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionTitle('Datos Personales'),
                  CustomInput(controller: _nombresCtrl, label: 'Nombres'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _apePatCtrl, label: 'Apellido Paterno'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _apeMatCtrl, label: 'Apellido Materno'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _sexo,
                    decoration: InputDecoration(labelText: 'Sexo', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border))),
                    items: const [DropdownMenuItem(value: 'Hombre', child: Text('Hombre')), DropdownMenuItem(value: 'Mujer', child: Text('Mujer'))],
                    onChanged: (val) => setState(() => _sexo = val),
                  ),
                  const SizedBox(height: 12),
                  CustomInput(controller: _telefonoCtrl, label: 'Teléfono', keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  CustomInput(controller: _curpCtrl, label: 'CURP'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _duiCtrl, label: 'DUI / INE'),

                  _buildSectionTitle('Fotografías del Cliente'),
                  _buildPhotoField('Foto de Perfil', _fotoPerfil, (f) => _fotoPerfil = f),
                  _buildPhotoField('INE Frente', _fotoIneFrente, (f) => _fotoIneFrente = f),
                  _buildPhotoField('INE Reverso', _fotoIneReverso, (f) => _fotoIneReverso = f),

                  _buildSectionTitle('Dirección Completa'),
                  CustomInput(controller: _calleCtrl, label: 'Calle'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _numExtCtrl, label: 'Número Exterior / Interior'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _coloniaCtrl, label: 'Colonia'),
                  const SizedBox(height: 12),
                  _buildPhotoField('Foto de Fachada', _fotoFachada, (f) => _fotoFachada = f),

                  _buildSectionTitle('Datos del Aval'),
                  CustomInput(controller: _avalNombreCtrl, label: 'Nombre Completo del Aval'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalParentescoCtrl, label: 'Parentesco'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalTelefonoCtrl, label: 'Teléfono del Aval', keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalCalleCtrl, label: 'Calle del Aval'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalNumExtCtrl, label: 'Número del Aval'),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalColoniaCtrl, label: 'Colonia del Aval'),

                  _buildSectionTitle('Fotografías del Aval y Docs'),
                  _buildPhotoField('Foto del Aval', _fotoAval, (f) => _fotoAval = f),
                  _buildPhotoField('INE Aval Frente', _avalIneFrente, (f) => _avalIneFrente = f),
                  _buildPhotoField('INE Aval Reverso', _avalIneReverso, (f) => _avalIneReverso = f),
                  _buildPhotoField('Comprobante Domicilio Aval', _fotoComprobanteAval, (f) => _fotoComprobanteAval = f),
                  _buildPhotoField('Firma del Titular', _fotoFirma, (f) => _fotoFirma = f),
                  _buildPhotoField('Foto del Contrato Firmado', _fotoContrato, (f) => _fotoContrato = f),

                  const SizedBox(height: 48),
                  CustomButton(
                    type: ButtonType.admin,
                    text: 'Guardar Cliente Completo',
                    icon: Icons.check_circle_outline,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
    );
  }
}
