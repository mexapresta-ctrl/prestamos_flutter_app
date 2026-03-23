import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/asesor_provider.dart';
import '../../../core/utils/curp_generator.dart';

class AsesorClienteWizardView extends ConsumerStatefulWidget {
  const AsesorClienteWizardView({super.key});

  @override
  ConsumerState<AsesorClienteWizardView> createState() => _AsesorClienteWizardViewState();
}

class _AsesorClienteWizardViewState extends ConsumerState<AsesorClienteWizardView> {
  final _formKeyPaso1 = GlobalKey<FormState>();
  final _formKeyPaso2 = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentStep = 0;

  // -- Paso 1: Cliente --
  final _nombresCtrl = TextEditingController();
  final _apePatCtrl = TextEditingController();
  final _apeMatCtrl = TextEditingController();
  final _curpCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _oficioCtrl = TextEditingController();
  final _montoSolicitadoCtrl = TextEditingController();
  final _calleCtrl = TextEditingController();
  final _numExtCtrl = TextEditingController();
  final _coloniaCtrl = TextEditingController();

  String? _sexo = 'Hombre';
  String? _estadoNacimiento = 'DF';
  DateTime? _fechaNac;

  File? _fotoPerfil, _fotoIneFrente, _fotoIneReverso, _fotoFachada;

  // -- Paso 2: Aval --
  final _avalNombreCtrl = TextEditingController();
  final _avalParentescoCtrl = TextEditingController();
  final _avalTelefonoCtrl = TextEditingController();
  final _avalCalleCtrl = TextEditingController();
  final _avalNumExtCtrl = TextEditingController();
  final _avalColoniaCtrl = TextEditingController();

  File? _fotoAval, _fotoComprobanteAval, _avalIneFrente, _avalIneReverso, _fotoFirma, _fotoContrato;

  final ImagePicker _picker = ImagePicker();
  final _phoneMask = MaskTextInputFormatter(mask: '###-###-####', filter: {"#": RegExp(r'[0-9]')});
  final _avalPhoneMask = MaskTextInputFormatter(mask: '###-###-####', filter: {"#": RegExp(r'[0-9]')});

  final List<String> _estados = [
    'AS', 'BC', 'BS', 'CC', 'CL', 'CM', 'CS', 'CH', 'DF', 'DG', 'GT', 
    'GR', 'HG', 'JC', 'MC', 'MN', 'MS', 'NT', 'NL', 'OC', 'PL', 'QT', 
    'QR', 'SP', 'SL', 'SR', 'TC', 'TS', 'TL', 'VZ', 'YN', 'ZS', 'NE'
  ];

  @override
  void dispose() {
    _nombresCtrl.dispose(); _apePatCtrl.dispose(); _apeMatCtrl.dispose();
    _curpCtrl.dispose(); _telefonoCtrl.dispose();
    _oficioCtrl.dispose(); _montoSolicitadoCtrl.dispose();
    _calleCtrl.dispose(); _numExtCtrl.dispose(); _coloniaCtrl.dispose();
    _avalNombreCtrl.dispose(); _avalParentescoCtrl.dispose(); _avalTelefonoCtrl.dispose();
    _avalCalleCtrl.dispose(); _avalNumExtCtrl.dispose(); _avalColoniaCtrl.dispose();
    super.dispose();
  }

  void _triggerCurpMath() {
    if (_nombresCtrl.text.isNotEmpty && _apePatCtrl.text.isNotEmpty && _fechaNac != null) {
      String generated = CurpGenerator.generate(
        nombres: _nombresCtrl.text,
        apellidoPaterno: _apePatCtrl.text,
        apellidoMaterno: _apeMatCtrl.text,
        fechaNacimiento: _fechaNac,
        sexo: _sexo ?? 'H',
        claveEstado: _estadoNacimiento ?? 'DF'
      );
      setState(() {
        _curpCtrl.text = generated;
      });
    }
  }

  Future<void> _pickImage(Function(File?) onPicked) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (image != null) setState(() => onPicked(File(image.path)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error cámara: $e')));
    }
  }

  Future<String?> _uploadImage(File file, String folder, String fileName) async {
    try {
      final path = '$folder/\${DateTime.now().millisecondsSinceEpoch}_\$fileName';
      await SupabaseConfig.client.storage.from('clientes_archivos').upload(path, file);
      return SupabaseConfig.client.storage.from('clientes_archivos').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error subiendo $fileName: $e');
      return null;
    }
  }

  void _siguientePaso() {
    if (!_formKeyPaso1.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comprueba los campos requeridos del cliente'), backgroundColor: AppColors.error));
      return;
    }
    if (_fechaNac == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona la fecha de nacimiento (Requerido)'), backgroundColor: AppColors.error));
      return;
    }
    if (_fotoPerfil == null || _fotoIneFrente == null || _fotoIneReverso == null || _fotoFachada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Las 4 fotos del cliente son OBLIGATORIAS. Tómales foto.'), backgroundColor: AppColors.error));
      return;
    }
    setState(() { _currentStep = 1; });
  }

  Future<void> _finalizarGuardado() async {
    if (!_formKeyPaso2.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Comprueba los campos requeridos del aval'), backgroundColor: AppColors.error));
      return;
    }
    if (_fotoAval == null || _fotoComprobanteAval == null || _avalIneFrente == null || _avalIneReverso == null || _fotoFirma == null || _fotoContrato == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan 1 o más fotos del Aval o Firmas. Son 100% OBLIGATORIAS.'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? urlPerfil, urlIneF, urlIneR, urlFachada, urlAval, urlCompAval, urlAvalIneF, urlAvalIneR, urlFirma, urlContrato;

      if (_fotoPerfil != null) urlPerfil = await _uploadImage(_fotoPerfil!, 'perfiles', 'perfil.jpg');
      if (_fotoIneFrente != null) urlIneF = await _uploadImage(_fotoIneFrente!, 'ine', 'ine_f.jpg');
      if (_fotoIneReverso != null) urlIneR = await _uploadImage(_fotoIneReverso!, 'ine', 'ine_r.jpg');
      if (_fotoFachada != null) urlFachada = await _uploadImage(_fotoFachada!, 'fachadas', 'fachada.jpg');
      
      if (_fotoAval != null) urlAval = await _uploadImage(_fotoAval!, 'aval', 'aval.jpg');
      if (_fotoComprobanteAval != null) urlCompAval = await _uploadImage(_fotoComprobanteAval!, 'aval', 'comp.jpg');
      if (_avalIneFrente != null) urlAvalIneF = await _uploadImage(_avalIneFrente!, 'ine', 'aval_ine_f.jpg');
      if (_avalIneReverso != null) urlAvalIneR = await _uploadImage(_avalIneReverso!, 'ine', 'aval_ine_r.jpg');
      if (_fotoFirma != null) urlFirma = await _uploadImage(_fotoFirma!, 'firmas', 'firma.jpg');
      if (_fotoContrato != null) urlContrato = await _uploadImage(_fotoContrato!, 'contratos', 'contrato.jpg');

      final fullName = '\${_nombresCtrl.text.trim()} \${_apePatCtrl.text.trim()} \${_apeMatCtrl.text.trim()}'.trim();
      final fullAddress = '\${_calleCtrl.text.trim()} \${_numExtCtrl.text.trim()}, \${_coloniaCtrl.text.trim()}'.trim();

      await SupabaseConfig.client.from('clientes').insert({
        'nombre': fullName,
        'nombres': _nombresCtrl.text.trim(),
        'apellido_paterno': _apePatCtrl.text.trim(),
        'apellido_materno': _apeMatCtrl.text.trim(),
        'sexo': _sexo,
        'estado_nacimiento': _estadoNacimiento,
        'telefono': _telefonoCtrl.text.trim().replaceAll('-', ''),
        'oficio': _oficioCtrl.text.trim(),
        'monto_solicitado': double.tryParse(_montoSolicitadoCtrl.text.trim().replaceAll(',', '')) ?? 0,
        'direccion': fullAddress,
        'calle': _calleCtrl.text.trim(),
        'numero_exterior': _numExtCtrl.text.trim(),
        'colonia': _coloniaCtrl.text.trim(),
        'curp': _curpCtrl.text.trim(),
        'activo': true,
        'aval_nombre': _avalNombreCtrl.text.trim(),
        'aval_parentesco': _avalParentescoCtrl.text.trim(),
        'aval_telefono': _avalTelefonoCtrl.text.trim().replaceAll('-', ''),
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

      if (!mounted) return;
      ref.read(asesorProvider.notifier).refresh();

      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente y Aval Guardados con Éxito'), backgroundColor: AppColors.ok));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar cliente: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPhotoTile(String title, File? file, Function(File?) handler) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: file != null ? AppColors.ok : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: file != null ? AppColors.okSurface : AppColors.background,
              borderRadius: BorderRadius.circular(8),
              image: file != null ? DecorationImage(image: FileImage(file), fit: BoxFit.cover) : null,
            ),
            child: file == null ? const Icon(Icons.camera_alt, color: AppColors.ink4) : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
              Text(file != null ? 'Capturada' : 'Tocar para tomar foto', style: TextStyle(fontSize: 10, color: file != null ? AppColors.ok : AppColors.ink4)),
            ],
          )),
          IconButton(
            icon: Icon(file != null ? Icons.check_circle : Icons.add_circle, color: file != null ? AppColors.ok : AppColors.asesor),
            onPressed: () => _pickImage(handler),
          )
        ],
      ),
    );
  }

  Widget _buildPaso1Cliente() {
    return Form(
      key: _formKeyPaso1,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Paso 1: Datos del Cliente', style: AppTypography.headingPrincipal),
          const SizedBox(height: 24),
          CustomInput(controller: _nombresCtrl, label: 'Nombres', validator: (v) => v!.isEmpty ? 'Requerido' : null, onChanged: (v) => _triggerCurpMath()),
          const SizedBox(height: 12),
          CustomInput(controller: _apePatCtrl, label: 'Apellido Paterno', validator: (v) => v!.isEmpty ? 'Requerido' : null, onChanged: (v) => _triggerCurpMath()),
          const SizedBox(height: 12),
          CustomInput(controller: _apeMatCtrl, label: 'Apellido Materno', validator: (v) => v!.isEmpty ? 'Requerido' : null, onChanged: (v) => _triggerCurpMath()),
          const SizedBox(height: 12),
          ListTile(
            title: Text(_fechaNac == null ? 'Fecha de Nacimiento' : 'Nacimiento: \${_fechaNac!.day}/\${_fechaNac!.month}/\${_fechaNac!.year}'),
            trailing: const Icon(Icons.calendar_today, color: AppColors.asesor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
            onTap: () async {
              final d = await showDatePicker(context: context, initialDate: DateTime(1990), firstDate: DateTime(1930), lastDate: DateTime.now());
              if (d != null) { setState(() { _fechaNac = d; _triggerCurpMath(); }); }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sexo,
                  decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()),
                  items: const [DropdownMenuItem(value: 'Hombre', child: Text('Hombre')), DropdownMenuItem(value: 'Mujer', child: Text('Mujer'))],
                  onChanged: (val) { setState(() { _sexo = val; _triggerCurpMath(); }); },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _estadoNacimiento,
                  decoration: const InputDecoration(labelText: 'Edo. Nac.', border: OutlineInputBorder()),
                  items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) { setState(() { _estadoNacimiento = val; _triggerCurpMath(); }); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomInput(controller: _curpCtrl, label: 'CURP Automática (Calculada por Sistema)', readOnly: true, validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _telefonoCtrl, label: 'Teléfono', keyboardType: TextInputType.phone, inputFormatters: [_phoneMask], validator: (v) => v!.length < 12 ? 'Requerido (10 dígitos)' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _oficioCtrl, label: 'Oficio / Ocupación', validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _montoSolicitadoCtrl, label: 'Préstamo a Solicitar', keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Requerido' : null),
          
          const Divider(height: 48, thickness: 1, color: AppColors.border),
          Text('DIRECCIÓN DEL CLIENTE', style: AppTypography.label.copyWith(color: AppColors.asesor)),
          const SizedBox(height: 12),
          CustomInput(controller: _calleCtrl, label: 'Calle', validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _numExtCtrl, label: 'Número Exterior / Interior', validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _coloniaCtrl, label: 'Colonia', validator: (v) => v!.isEmpty ? 'Requerido' : null),

          const Divider(height: 48, thickness: 1, color: AppColors.border),
          Text('EVIDENCIAS FOTOGRÁFICAS (CLIENTE)', style: AppTypography.label.copyWith(color: AppColors.asesor)),
          const SizedBox(height: 12),
          _buildPhotoTile('Foto de Perfil', _fotoPerfil, (f) => _fotoPerfil = f),
          _buildPhotoTile('INE Frente', _fotoIneFrente, (f) => _fotoIneFrente = f),
          _buildPhotoTile('INE Reverso', _fotoIneReverso, (f) => _fotoIneReverso = f),
          _buildPhotoTile('Foto de Fachada (Casa)', _fotoFachada, (f) => _fotoFachada = f),

          const SizedBox(height: 32),
          CustomButton(type: ButtonType.asesor, text: 'Siguiente: Datos del Aval', icon: Icons.arrow_forward_rounded, onPressed: _siguientePaso),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPaso2Aval() {
    return Form(
      key: _formKeyPaso2,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _currentStep = 0)),
              Expanded(child: Text('Paso 2: Aval y Archivos', style: AppTypography.headingPrincipal)),
            ],
          ),
          const SizedBox(height: 24),
          CustomInput(controller: _avalNombreCtrl, label: 'Nombre Completo del Aval', validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _avalParentescoCtrl, label: 'Parentesco con el Cliente', validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _avalTelefonoCtrl, label: 'Teléfono del Aval', keyboardType: TextInputType.phone, inputFormatters: [_avalPhoneMask], validator: (v) => v!.length < 12 ? 'Requerido (10 dígitos)' : null),
          
          const Divider(height: 48, thickness: 1, color: AppColors.border),
          Text('DIRECCIÓN DEL AVAL', style: AppTypography.label.copyWith(color: AppColors.asesor)),
          const SizedBox(height: 12),
          CustomInput(controller: _avalCalleCtrl, label: 'Calle del Aval', validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _avalNumExtCtrl, label: 'Número Exterior del Aval', validator: (v) => v!.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 12),
          CustomInput(controller: _avalColoniaCtrl, label: 'Colonia del Aval', validator: (v) => v!.isEmpty ? 'Requerido' : null),

          const Divider(height: 48, thickness: 1, color: AppColors.border),
          Text('EVIDENCIAS FOTOGRÁFICAS (AVAL Y CONTRATOS)', style: AppTypography.label.copyWith(color: AppColors.asesor)),
          const SizedBox(height: 12),
          _buildPhotoTile('Foto Rostro del Aval', _fotoAval, (f) => _fotoAval = f),
          _buildPhotoTile('INE Aval Frente', _avalIneFrente, (f) => _avalIneFrente = f),
          _buildPhotoTile('INE Aval Reverso', _avalIneReverso, (f) => _avalIneReverso = f),
          _buildPhotoTile('Comprobante Domicilio Aval', _fotoComprobanteAval, (f) => _fotoComprobanteAval = f),
          _buildPhotoTile('Firma del Titular (Fotografía)', _fotoFirma, (f) => _fotoFirma = f),
          _buildPhotoTile('Contrato Físico Firmado', _fotoContrato, (f) => _fotoContrato = f),

          const SizedBox(height: 32),
          CustomButton(
            type: ButtonType.asesor,
            text: _isLoading ? 'Subiendo 10 archivos...' : 'Finalizar y Guardar Cliente',
            icon: Icons.cloud_upload_rounded,
            onPressed: _isLoading ? () {} : _finalizarGuardado,
          ),
          const SizedBox(height: 32),
        ],
      ),
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
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text('Guardando información masiva...', style: TextStyle(color: AppColors.ink3))]))
        : IndexedStack(
            index: _currentStep,
            children: [
              _buildPaso1Cliente(),
              _buildPaso2Aval(),
            ],
          ),
    );
  }
}
