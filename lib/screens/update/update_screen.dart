import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../theme/app_colors.dart';
import '../auth/login_assets.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
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

    _downloadState.value = {'received': 0, 'total': 0, 'progress': 0.0};
    setState(() {
      _isDownloading = true;
      _isDone = false;
    });

    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception("No storage directory");
      
      final savePath = '${dir.path}/app-release.apk';
      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      final dio = Dio();
      await dio.download(
        _apkUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (!mounted) return;
          final now = DateTime.now();
          if (now.difference(lastUpdate).inMilliseconds > 100 || received == total) {
            lastUpdate = now;
            _downloadState.value = {
              'received': received,
              'total': total,
              'progress': total > 0 ? (received / total) : 0.0,
            };
          }
        },
      );

      if (mounted) {
        setState(() {
          _localPath = savePath;
          _isDownloading = false;
          _isDone = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _installApk() async {
    if (_localPath != null) {
      await OpenFilex.open(_localPath!);
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
                  child: ValueListenableBuilder<Map<String, dynamic>>(
                    valueListenable: _downloadState,
                    builder: (context, state, child) {
                      final received = state['received'] as int;
                      final total = state['total'] as int;
                      final double progress = state['progress'] as double;
                      final bool isKnown = total > 0;

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Descargando...', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87)),
                              Text(isKnown ? '${(progress * 100).toInt()}%' : _formatBytes(received), style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.admin)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: isKnown ? progress : null,
                              minHeight: 8,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.admin),
                            ),
                          ),
                        ],
                      );
                    },
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
                ElevatedButton.icon(
                  onPressed: _installApk,
                  icon: const Icon(Icons.system_update_alt),
                  label: Text('Instalar Ahora', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else if (!_isDownloading)
                ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download_rounded),
                  label: Text('Descargar Actualización', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.admin,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
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
