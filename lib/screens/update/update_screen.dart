import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../auth/login_assets.dart';
import 'package:flutter/services.dart';
class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  static const _channel = MethodChannel('com.mexapresta.app/downloader');
  String _currentVersion = 'v...';
  String _latestVersion = 'Cargando...';
  String _releaseNotes = 'Buscando novedades...';
  String _apkUrl = '';

  bool _isLoadingInfo = true;
  bool _isDownloading = false;
  bool _isDone = false;
  String? _localPath;

  final ValueNotifier<Map<String, dynamic>> _downloadState = ValueNotifier({'received': 0, 'total': 0, 'progress': 0.0});
  DateTime lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initAppVersion();
    _fetchGithubRelease();
  }

  @override
  void dispose() {
    _downloadState.dispose();
    super.dispose();
  }

  Future<void> _initAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
    });
  }

  Future<void> _fetchGithubRelease() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.github.com/repos/mexapresta-ctrl/prestamos_flutter_app/releases/latest',
      );

      final data = response.data;
      final String tagName = data['tag_name'] ?? 'v0.0.0';
      String body = data['body'] ?? 'Actualización sin notas.';
      final List assets = data['assets'] ?? [];

      // Automate changelog for version 1.1.3
      if (tagName.contains('1.1.3') || tagName.contains('1.1.4')) {
        body = '''$body

✨ Novedades de la versión anterior:
• El registro Web ahora exige todos los datos y fotos.
• Autogenerador de CURP y formato en teléfonos.
• Arreglo Global: El botón "Cerrar Sesión" ahora desloguea correctamente.
• Eliminado campo DUI/INE y agregado Oficio y Préstamo a Solicitar.''';
      }

      // Automate changelog for version 1.1.5
      if (tagName.contains('1.1.5')) {
        body = '''$body

✨ Novedades de la Versión 1.1.5:
• [Mejora] Unificación total: El Asesor ahora utiliza exactamente el mismo Formulario de Registro con los nuevos campos avanzados (Ocupación, Préstamo 
Sugerido, Fotografías y Nombres Segmentados) para mantener paridad con el Administrador web.
• [Mejora] Ahora se procesan los campos de "Plan / Interés" y "Prestamista Asignado" siguiendo la arquitectura de la Web.''';
      }

      String foundUrl = '';
      if (assets.isNotEmpty) {
        foundUrl = assets.first['browser_download_url'] ?? '';
      }

      if (mounted) {
        setState(() {
          _latestVersion = tagName;
          _releaseNotes = body;
          _apkUrl = foundUrl;
          _isLoadingInfo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _latestVersion = 'Desconocida';
          _releaseNotes = 'No se pudo cargar la info de GitHub.\nError: $e';
          _isLoadingInfo = false;
        });
      }
    }
  }

  Future<void> _startDownload() async {
    if (_apkUrl.isEmpty) return;

    setState(() {
      _isDownloading = true;
      _isDone = false;
    });

    try {
      final result = await _channel.invokeMethod('startDownload', {
        'url': _apkUrl,
        'fileName': 'MexaPresta-update.apk',
      });

      if (mounted) {
        setState(() {
          _localPath = result?.toString();
          _isDownloading = false;
          _isDone = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _installApk() async {
    if (_localPath != null) {
      try {
        await _channel.invokeMethod('installApk', {'path': _localPath});
      } catch (_) {
        // Fallback to open_filex
        await OpenFilex.open(_localPath!);
      }
    }
  }

  Future<void> _openInBrowser() async {
    if (_apkUrl.isEmpty) return;
    final uri = Uri.parse(_apkUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text('Actualización', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // App Icon
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: AppColors.admin.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.memory(LoginAssets.getDecodedLogo(), fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Nueva Versión Disponible',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              
              // Versions
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_currentVersion, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.admin),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.admin.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(_latestVersion, style: GoogleFonts.inter(color: AppColors.admin, fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Download Status
              if (_isDownloading)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Descargando en segundo plano...', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          minHeight: 8,
                          backgroundColor: Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.admin),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Puedes salir de la app. La descarga continuará en la barra de notificaciones.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

              if (!_isDownloading && _isDone)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 30),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text('Descarga completada con éxito. Listo para instalar.', style: GoogleFonts.inter(fontWeight: FontWeight.w500, color: Colors.black87)),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Button
              if (_isLoadingInfo)
                const Center(child: CircularProgressIndicator())
              else if (_isDone)
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
                      const SizedBox(height: 16),
                      Text('¡Descarga Completa!', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[700])),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.system_update_alt_rounded),
                        label: const Text('Instalar Ahora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.admin,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _installApk,
                      ),
                    ],
                  ),
                )
              else if (!_isDownloading)
                Column(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Descargar Actualización'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.admin,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _startDownload,
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      icon: const Icon(Icons.open_in_browser_rounded),
                      label: const Text('Descarga Lenta? Usa el Navegador'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      onPressed: _openInBrowser,
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Release Notes
              const Text('Novedades:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                child: Text(
                  _releaseNotes,
                  style: GoogleFonts.inter(height: 1.5, color: Colors.black87, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
