import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_input.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/providers/asesor_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/utils/curp_generator.dart';
import '../../../core/utils/time_util.dart';

class AsesorClienteCreateView extends ConsumerStatefulWidget {
  const AsesorClienteCreateView({super.key});

  @override
  ConsumerState<AsesorClienteCreateView> createState() => _AsesorClienteCreateViewState();
}

class _AsesorClienteCreateViewState extends ConsumerState<AsesorClienteCreateView> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Datos Personales
  final _primerNombreCtrl = TextEditingController();
  final _segundoNombreCtrl = TextEditingController();
  final _apePatCtrl = TextEditingController();
  final _apeMatCtrl = TextEditingController();
  final _curpCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _oficioCtrl = TextEditingController();
  final _montoSolicitadoCtrl = TextEditingController();

  // Fecha de Nacimiento manual
  final _diaCtrl = TextEditingController();
  final _mesCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();
  DateTime? _fechaNac;

  String? _genero = 'Masculino';
  String? _estadoNacimiento = 'Ciudad de México';
  String? _planSeleccionado;

  final _phoneMask = MaskTextInputFormatter(mask: '###-###-####', filter: {"#": RegExp(r'[0-9]')});
  final _avalPhoneMask = MaskTextInputFormatter(mask: '###-###-####', filter: {"#": RegExp(r'[0-9]')});

  // Estados con nombre completo
  final List<String> _estados = [
    'Aguascalientes', 'Baja California', 'Baja California Sur', 'Campeche',
    'Coahuila', 'Colima', 'Chiapas', 'Chihuahua', 'Ciudad de México',
    'Durango', 'Guanajuato', 'Guerrero', 'Hidalgo', 'Jalisco',
    'Estado de México', 'Michoacán', 'Morelos', 'Nayarit', 'Nuevo León',
    'Oaxaca', 'Puebla', 'Querétaro', 'Quintana Roo', 'San Luis Potosí',
    'Sinaloa', 'Sonora', 'Tabasco', 'Tamaulipas', 'Tlaxcala',
    'Veracruz', 'Yucatán', 'Zacatecas', 'Nacido en el Extranjero'
  ];
  final List<String> _estadosCurp = [
    'AS', 'BC', 'BS', 'CC', 'CL', 'CM', 'CS', 'CH', 'DF',
    'DG', 'GT', 'GR', 'HG', 'JC', 'MC', 'MN', 'MS', 'NT', 'NL',
    'OC', 'PL', 'QT', 'QR', 'SP', 'SL', 'SR', 'TC', 'TS', 'TL',
    'VZ', 'YN', 'ZS', 'NE'
  ];

  List<Map<String, dynamic>> _tiposPrestamo = [];
  final List<String> _parentescos = [
    'Padre', 'Madre', 'Hijo/a', 'Hermano/a', 'Cónyuge / Pareja',
    'Tío/a', 'Primo/a', 'Abuelo/a', 'Amigo/a', 'Vecino/a', 'Otro',
  ];
  String? _avalParentesco;

  // Dirección Cliente
  final _calleCtrl = TextEditingController();
  final _numExtCtrl = TextEditingController();
  final _coloniaCtrl = TextEditingController();

  // Aval
  final _avalNombreCtrl = TextEditingController();
  final _avalApePatCtrl = TextEditingController();
  final _avalApeMatCtrl = TextEditingController();
  final _avalTelefonoCtrl = TextEditingController();
  final _avalCalleCtrl = TextEditingController();
  final _avalNumExtCtrl = TextEditingController();
  final _avalColoniaCtrl = TextEditingController();

  // Fotos
  File? _fotoPerfil;
  File? _fotoIneFrente;
  File? _fotoIneReverso;
  File? _fotoFachada;
  File? _fotoFirmaCliente;
  File? _fotoContrato;
  File? _avalFirma;
  File? _avalIneFrente;
  File? _avalIneReverso;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchPlanes();
    _montoSolicitadoCtrl.addListener(_onMontoChanged);
  }

  void _onMontoChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _fetchPlanes() async {
    try {
      final res = await SupabaseConfig.client
          .from('tipos_prestamo')
          .select('id, nombre, activo, color, ciclo, valor_pago')
          .eq('activo', true)
          .order('id');
      if (mounted) {
        setState(() {
          _tiposPrestamo = List<Map<String, dynamic>>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Error loading planes: $e');
    }
  }

  @override
  void dispose() {
    _montoSolicitadoCtrl.removeListener(_onMontoChanged);
    _primerNombreCtrl.dispose();
    _segundoNombreCtrl.dispose();
    _apePatCtrl.dispose();
    _apeMatCtrl.dispose();
    _curpCtrl.dispose();
    _telefonoCtrl.dispose();
    _oficioCtrl.dispose();
    _montoSolicitadoCtrl.dispose();
    _diaCtrl.dispose();
    _mesCtrl.dispose();
    _anioCtrl.dispose();
    _calleCtrl.dispose();
    _numExtCtrl.dispose();
    _coloniaCtrl.dispose();
    _avalNombreCtrl.dispose();
    _avalApePatCtrl.dispose();
    _avalApeMatCtrl.dispose();
    _avalTelefonoCtrl.dispose();
    _avalCalleCtrl.dispose();
    _avalNumExtCtrl.dispose();
    _avalColoniaCtrl.dispose();
    super.dispose();
  }

  String _getClaveCurp() {
    final idx = _estados.indexOf(_estadoNacimiento ?? 'Ciudad de México');
    return idx >= 0 ? _estadosCurp[idx] : 'DF';
  }

  void _tryBuildDate() {
    final dia = int.tryParse(_diaCtrl.text.trim());
    final mes = int.tryParse(_mesCtrl.text.trim());
    final anio = int.tryParse(_anioCtrl.text.trim());
    if (dia != null && mes != null && anio != null && anio > 1900) {
      try {
        setState(() { _fechaNac = DateTime(anio, mes, dia); });
        _triggerCurpMath();
      } catch (_) {}
    }
  }

  void _triggerCurpMath() {
    if (_primerNombreCtrl.text.isNotEmpty && _apePatCtrl.text.isNotEmpty && _fechaNac != null) {
      final nombres = '${_primerNombreCtrl.text.trim()} ${_segundoNombreCtrl.text.trim()}'.trim();
      // H = Hombre/Masculino, M = Mujer/Femenino
      final sexoCurp = (_genero == 'Masculino') ? 'H' : 'M';
      final generated = CurpGenerator.generate(
        nombres: nombres,
        apellidoPaterno: _apePatCtrl.text,
        apellidoMaterno: _apeMatCtrl.text,
        fechaNacimiento: _fechaNac,
        sexo: sexoCurp,
        claveEstado: _getClaveCurp(),
      );
      setState(() { _curpCtrl.text = generated; });
    }
  }

  Future<void> _pickImage(Function(File?) onPicked) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
      if (image != null) setState(() { onPicked(File(image.path)); });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al abrir cámara: $e')));
    }
  }

  Future<String?> _uploadImage(File file, String folder, String fileName) async {
    try {
      final path = '$folder/${TimeUtil.now().millisecondsSinceEpoch}_$fileName';
      await SupabaseConfig.client.storage.from('clientes_archivos').upload(path, file);
      return SupabaseConfig.client.storage.from('clientes_archivos').getPublicUrl(path);
    } catch (e) {
      debugPrint('Error subiendo $fileName: $e');
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Completa todos los campos requeridos'), backgroundColor: AppColors.error));
      return;
    }
    if (_fechaNac == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La fecha de nacimiento es obligatoria'), backgroundColor: AppColors.error));
      return;
    }
    if (_fotoPerfil == null || _fotoIneFrente == null || _fotoIneReverso == null || _fotoFirmaCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fotos del cliente (Perfil, INE Frente, INE Reverso y Firma) son obligatorias'), backgroundColor: AppColors.error));
      return;
    }
    if (_avalFirma == null || _avalIneFrente == null || _avalIneReverso == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fotos del Aval (Firma, INE Frente e INE Reverso) son obligatorias'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? urlPerfil, urlIneF, urlIneR, urlFachada, urlFirmaCliente, urlContrato, urlAvalFirma, urlAvalIneF, urlAvalIneR;

      if (_fotoPerfil != null) urlPerfil = await _uploadImage(_fotoPerfil!, 'perfiles', 'perfil.jpg');
      if (_fotoIneFrente != null) urlIneF = await _uploadImage(_fotoIneFrente!, 'ine', 'ine_f.jpg');
      if (_fotoIneReverso != null) urlIneR = await _uploadImage(_fotoIneReverso!, 'ine', 'ine_r.jpg');
      if (_fotoFachada != null) urlFachada = await _uploadImage(_fotoFachada!, 'fachadas', 'fachada.jpg');
      if (_fotoFirmaCliente != null) urlFirmaCliente = await _uploadImage(_fotoFirmaCliente!, 'firmas', 'firma_cliente.jpg');
      if (_fotoContrato != null) urlContrato = await _uploadImage(_fotoContrato!, 'contratos', 'contrato.jpg');
      if (_avalFirma != null) urlAvalFirma = await _uploadImage(_avalFirma!, 'firmas', 'firma_aval.jpg');
      if (_avalIneFrente != null) urlAvalIneF = await _uploadImage(_avalIneFrente!, 'ine', 'aval_ine_f.jpg');
      if (_avalIneReverso != null) urlAvalIneR = await _uploadImage(_avalIneReverso!, 'ine', 'aval_ine_r.jpg');

      final nombres = '${_primerNombreCtrl.text.trim()} ${_segundoNombreCtrl.text.trim()}'.trim();
      final fullName = '$nombres ${_apePatCtrl.text.trim()} ${_apeMatCtrl.text.trim()}'.trim();
      final avalNombre = '${_avalNombreCtrl.text.trim()} ${_avalApePatCtrl.text.trim()} ${_avalApeMatCtrl.text.trim()}'.trim();
      final fullAddress = '${_calleCtrl.text.trim()} ${_numExtCtrl.text.trim()}, ${_coloniaCtrl.text.trim()}'.trim();

      final newClienteRes = await SupabaseConfig.client.from('clientes').insert({
        'nombre': fullName,
        'nombres': nombres,
        'apellido_paterno': _apePatCtrl.text.trim(),
        'apellido_materno': _apeMatCtrl.text.trim(),
        'sexo': _genero,
        'estado_nacimiento': _getClaveCurp(),
        'telefono': _telefonoCtrl.text.trim().replaceAll('-', ''),
        'oficio': _oficioCtrl.text.trim(),
        'monto_solicitado': double.tryParse(_montoSolicitadoCtrl.text.trim().replaceAll(',', '')) ?? 0,
        'direccion': fullAddress,
        'calle': _calleCtrl.text.trim(),
        'numero_exterior': _numExtCtrl.text.trim(),
        'colonia': _coloniaCtrl.text.trim(),
        'curp': _curpCtrl.text.trim(),
        'activo': true,
        'aval_nombre': avalNombre,
        'aval_parentesco': _avalParentesco,
        'aval_telefono': _avalTelefonoCtrl.text.trim().replaceAll('-', ''),
        'aval_calle': _avalCalleCtrl.text.trim(),
        'aval_numero_exterior': _avalNumExtCtrl.text.trim(),
        'aval_colonia': _avalColoniaCtrl.text.trim(),
        'foto_perfil_url': urlPerfil,
        'foto_ine_frente_url': urlIneF,
        'foto_ine_reverso_url': urlIneR,
        'foto_fachada_url': urlFachada,
        'foto_firma_url': urlFirmaCliente,
        'foto_contrato_url': urlContrato,
        'foto_aval_url': urlAvalFirma,
        'aval_ine_frente_url': urlAvalIneF,
        'aval_ine_reverso_url': urlAvalIneR,
      }).select('id').single();

      final int clienteId = newClienteRes['id'];
      final double montoSolicitado = double.tryParse(_montoSolicitadoCtrl.text.trim().replaceAll(',', '')) ?? 0;

      if (montoSolicitado > 0 && _planSeleccionado != null) {
        final planOpt = _tiposPrestamo.where((p) => p['id'] == _planSeleccionado).toList();
        if (planOpt.isNotEmpty) {
          final p = planOpt.first;
          final double valorPago = double.tryParse(p['valor_pago'].toString()) ?? 0;
          final int plazo = int.tryParse(p['total_pagos']?.toString() ?? '1') ?? 1;
          final String ciclo = p['ciclo'] ?? '';
          final String frecuencia = p['frecuencia'] ?? '';
          final String nombrePlan = p['nombre'] ?? '';

          double cuotaSemanal = 0;
          double totalAPagar = 0;
          final double factor = montoSolicitado / 1000;

          if (ciclo == 'PORCENTAJE') {
             final interesPorPeriodo = montoSolicitado * (valorPago / 100);
             final interesTotal = interesPorPeriodo * plazo;
             totalAPagar = montoSolicitado + interesTotal;
             cuotaSemanal = totalAPagar / plazo;
          } else {
             int factorMultiplicador = 1;
             if (frecuencia == 'Único (Día 20)') {
               factorMultiplicador = 20;
             } else if (frecuencia == 'Único (Día 15)') {
               factorMultiplicador = 15;
             }

             cuotaSemanal = valorPago * factor * factorMultiplicador;
             totalAPagar = cuotaSemanal * plazo;
          }

          final userState = ref.read(authProvider);
          final user = userState.user;

          await SupabaseConfig.client.from('prestamos').insert({
            'cliente_id': clienteId,
            'asesor_id': user?.id,
            'cobrador_id': user?.id,
            'monto': montoSolicitado,
            'plazo': plazo,
            'tasa_interes': 0,
            'cuota_semanal': cuotaSemanal,
            'total_a_pagar': totalAPagar,
            'estado': 'solicitado',
            'tipo_prestamo_id': _planSeleccionado,
            'nombre_plan': nombrePlan,
            'frecuencia': frecuencia,
            'cuotas_pagadas': 0,
            'cuotas_totales': plazo,
            'fecha_desembolso': null,
            'fecha_aprobacion': null,
          });
        }
      }

      if (!mounted) return;
      ref.read(asesorProvider.notifier).refresh();
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cliente guardado exitosamente'), backgroundColor: AppColors.ok));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar cliente: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPhotoField(String title, File? currentFile, Function(File?) onPicked, {bool required = true}) {
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
            width: 44, height: 44,
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
                Row(children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  if (required) const Text(' *', style: TextStyle(color: AppColors.error, fontSize: 12)),
                ]),
                Text(currentFile != null ? 'Capturada ✓' : 'Tocar para tomar foto',
                    style: TextStyle(fontSize: 10, color: currentFile != null ? AppColors.ok : AppColors.ink4)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(currentFile != null ? Icons.check_circle : Icons.add_circle,
                color: currentFile != null ? AppColors.ok : AppColors.asesor),
            onPressed: () => _pickImage(onPicked),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(title.toUpperCase(),
          style: AppTypography.label.copyWith(fontSize: 11, color: AppColors.asesor, letterSpacing: 1.5)),
    );
  }

  InputDecoration _dropDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
  );

  Widget _buildPlanSummaryCard() {
    if (_planSeleccionado == null || _montoSolicitadoCtrl.text.isEmpty) return const SizedBox.shrink();
    
    final planOpt = _tiposPrestamo.where((p) => p['id'].toString() == _planSeleccionado).toList();
    if (planOpt.isEmpty) return const SizedBox.shrink();
    
    final p = planOpt.first;
    final double montoSolicitado = double.tryParse(_montoSolicitadoCtrl.text.trim().replaceAll(',', '')) ?? 0;
    if (montoSolicitado <= 0) return const SizedBox.shrink();

    final double valorPago = double.tryParse(p['valor_pago'].toString()) ?? 0;
    final int plazo = int.tryParse(p['total_pagos']?.toString() ?? '1') ?? 1;
    final String ciclo = p['ciclo'] ?? '';
    final String frecuencia = p['frecuencia'] ?? '';
    final String colorStr = p['color']?.toString() ?? '#252525';
    
    Color planColor;
    try {
      planColor = Color(int.parse(colorStr.replaceAll('#', ''), radix: 16) + 0xFF000000);
    } catch (_) {
      planColor = AppColors.ink2;
    }

    double cuotaSemanal = 0;
    double totalAPagar = 0;
    final double factor = montoSolicitado / 1000;

    if (ciclo == 'PORCENTAJE') {
      final interesPorPeriodo = montoSolicitado * (valorPago / 100);
      final interesTotal = interesPorPeriodo * plazo;
      totalAPagar = montoSolicitado + interesTotal;
      cuotaSemanal = totalAPagar / plazo;
    } else {
      int factorMultiplicador = 1;
      if (frecuencia == 'Único (Día 20)') {
        factorMultiplicador = 20;
      } else if (frecuencia == 'Único (Día 15)') {
        factorMultiplicador = 15;
      }
      cuotaSemanal = valorPago * factor * factorMultiplicador;
      totalAPagar = cuotaSemanal * plazo;
    }

    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: planColor.withOpacity(0.1),
        border: Border.all(color: planColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: planColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Resumen del Préstamo',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16).copyWith(color: planColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Total a Pagar:', currency.format(totalAPagar)),
          _buildSummaryRow('Pagos Totales:', '\$plazo pagos'),
          _buildSummaryRow('Cuota ($frecuencia):', currency.format(cuotaSemanal)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.ink3, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ── DATOS PERSONALES ──────────────────────────────────────
                  _buildSectionTitle('Datos Personales'),

                  CustomInput(controller: _primerNombreCtrl, label: 'Primer Nombre *',
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      onChanged: (v) => _triggerCurpMath()),
                  const SizedBox(height: 12),

                  CustomInput(controller: _segundoNombreCtrl, label: 'Segundo Nombre (Opcional)',
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (v) => _triggerCurpMath()),
                  const SizedBox(height: 12),

                  CustomInput(controller: _apePatCtrl, label: 'Apellido Paterno *',
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      onChanged: (v) => _triggerCurpMath()),
                  const SizedBox(height: 12),

                  CustomInput(controller: _apeMatCtrl, label: 'Apellido Materno',
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (v) => _triggerCurpMath()),
                  const SizedBox(height: 12),

                  // Fecha de Nacimiento DD / MM / AAAA
                  const Text('Fecha de Nacimiento *',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SizedBox(width: 70, child: TextFormField(
                        controller: _diaCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                        decoration: _dropDecoration('DD'),
                        onChanged: (v) { if (v.length == 2) { FocusScope.of(context).nextFocus(); _tryBuildDate(); } },
                        validator: (v) => v!.isEmpty ? 'DD' : null,
                      )),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      SizedBox(width: 70, child: TextFormField(
                        controller: _mesCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                        decoration: _dropDecoration('MM'),
                        onChanged: (v) { if (v.length == 2) { FocusScope.of(context).nextFocus(); _tryBuildDate(); } },
                        validator: (v) => v!.isEmpty ? 'MM' : null,
                      )),
                      const Padding(padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text('/', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      Expanded(child: TextFormField(
                        controller: _anioCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                        decoration: _dropDecoration('AAAA'),
                        onChanged: (v) { if (v.length == 4) _tryBuildDate(); },
                        validator: (v) => v!.length < 4 ? 'AAAA' : null,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Género
                  DropdownButtonFormField<String>(
                    initialValue: _genero,
                    decoration: _dropDecoration('Género *'),
                    items: const [
                      DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                      DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                    ],
                    onChanged: (val) { setState(() { _genero = val; _triggerCurpMath(); }); },
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),

                  // Estado de Nacimiento
                  DropdownButtonFormField<String>(
                    initialValue: _estadoNacimiento,
                    decoration: _dropDecoration('Estado de Nacimiento *'),
                    isExpanded: true,
                    items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (val) { setState(() { _estadoNacimiento = val; _triggerCurpMath(); }); },
                    validator: (v) => v == null ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),

                  CustomInput(controller: _curpCtrl, label: 'CURP (Calculada automáticamente)', readOnly: true,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),

                  CustomInput(controller: _telefonoCtrl, label: 'Teléfono *',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_phoneMask],
                      validator: (v) => v!.length < 12 ? 'Requerido (10 dígitos)' : null),
                  const SizedBox(height: 12),

                  CustomInput(controller: _oficioCtrl, label: 'Oficio / Ocupación'),

                  // ── DIRECCIÓN ─────────────────────────────────────────────
                  _buildSectionTitle('Dirección Completa'),
                  CustomInput(controller: _calleCtrl, label: 'Calle *',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  CustomInput(controller: _numExtCtrl, label: 'Núm. Exterior / Interior *',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  CustomInput(controller: _coloniaCtrl, label: 'Colonia *',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),

                  // ── PRÉSTAMO Y PLAN ───────────────────────────────────────
                  _buildSectionTitle('Datos del Préstamo Sugerido'),
                  CustomInput(
                    controller: _montoSolicitadoCtrl,
                    label: 'Monto a Solicitar * (Múltiplos de \$1,000)',
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: (_planSeleccionado != null && _tiposPrestamo.any((p) => p['id'].toString() == _planSeleccionado)) ? _planSeleccionado : null,
                    decoration: _dropDecoration('Plan / Interés *'),
                    isExpanded: true,
                    items: () {
                      final seen = <String>{};
                      final items = <DropdownMenuItem<String>>[];
                      for (var p in _tiposPrestamo) {
                        final val = p['id']?.toString() ?? '';
                        if (val.isNotEmpty && !seen.contains(val)) {
                          seen.add(val);
                          final cStr = p['color']?.toString() ?? '#252525';
                          Color pColor = AppColors.ink2;
                          try { pColor = Color(int.parse(cStr.replaceAll('#',''), radix: 16) + 0xFF000000); } catch (_) {}
                          items.add(DropdownMenuItem<String>(
                            value: val,
                            child: Row(
                              children: [
                                Container(
                                  width: 14, height: 14,
                                  decoration: BoxDecoration(color: pColor, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 10),
                                Text(p['nombre']?.toString() ?? 'Plan sin nombre'),
                              ],
                            ),
                          ));
                        }
                      }
                      return items;
                    }(),
                    onChanged: (val) => setState(() => _planSeleccionado = val),
                    validator: (v) => v == null ? 'Selecciona un Plan' : null,
                  ),
                  _buildPlanSummaryCard(),

                  // ── FOTOS CLIENTE ─────────────────────────────────────────
                  _buildSectionTitle('Fotografías del Cliente'),
                  _buildPhotoField('Foto de Perfil / Rostro', _fotoPerfil, (f) => _fotoPerfil = f),
                  _buildPhotoField('INE Frontal', _fotoIneFrente, (f) => _fotoIneFrente = f),
                  _buildPhotoField('INE Reverso', _fotoIneReverso, (f) => _fotoIneReverso = f),
                  _buildPhotoField('Foto de Fachada', _fotoFachada, (f) => _fotoFachada = f, required: false),
                  _buildPhotoField('Firma del Cliente / Titular *', _fotoFirmaCliente, (f) => _fotoFirmaCliente = f),
                  _buildPhotoField('Foto del Contrato Firmado', _fotoContrato, (f) => _fotoContrato = f, required: false),

                  // ── DATOS DEL AVAL ────────────────────────────────────────
                  _buildSectionTitle('Datos del Aval'),
                  CustomInput(controller: _avalNombreCtrl, label: 'Nombre(s) del Aval *',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalApePatCtrl, label: 'Apellido Paterno del Aval *',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalApeMatCtrl, label: 'Apellido Materno del Aval'),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _avalParentesco,
                    decoration: _dropDecoration('Parentesco con el Cliente *'),
                    isExpanded: true,
                    items: _parentescos.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                    onChanged: (val) => setState(() => _avalParentesco = val),
                    validator: (v) => v == null ? 'Selecciona un Parentesco' : null,
                  ),
                  const SizedBox(height: 12),

                  CustomInput(controller: _avalTelefonoCtrl, label: 'Teléfono del Aval *',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_avalPhoneMask],
                      validator: (v) => v!.length < 12 ? 'Requerido (10 dígitos)' : null),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalCalleCtrl, label: 'Calle del Aval *',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalNumExtCtrl, label: 'Núm. Exterior del Aval *',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 12),
                  CustomInput(controller: _avalColoniaCtrl, label: 'Colonia del Aval *',
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),

                  // ── FOTOS AVAL ────────────────────────────────────────────
                  _buildSectionTitle('Fotografías del Aval'),
                  _buildPhotoField('Firma del Aval *', _avalFirma, (f) => _avalFirma = f),
                  _buildPhotoField('INE Frontal del Aval *', _avalIneFrente, (f) => _avalIneFrente = f),
                  _buildPhotoField('INE Reverso del Aval *', _avalIneReverso, (f) => _avalIneReverso = f),

                  const SizedBox(height: 48),
                  CustomButton(
                    type: ButtonType.asesor,
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
