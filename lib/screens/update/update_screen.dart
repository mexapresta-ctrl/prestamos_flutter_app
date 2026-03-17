import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class UpdateScreen extends StatefulWidget {
  final String appUrl;

  const UpdateScreen({super.key, required this.appUrl});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isDownloading = false;
  bool _done = false;
  double _progress = 0;
  bool _progressKnown = false;
  int _receivedBytes = 0;
  String _statusText = '¡Nueva Versión Disponible!';
  String _detailText =
      'MEXA PRESTA se ha actualizado para brindarte un mejor servicio. Es necesario descargar la última versión para continuar.';
  String? _localPath;

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _done = false;
      _progress = 0;
      _progressKnown = false;
      _receivedBytes = 0;
      _statusText = 'Descargando Actualización...';
      _detailText = 'Por favor, no cierres esta pantalla hasta que se complete la descarga.';
    });

    try {
      if (!Platform.isAndroid) return;

      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('No se pudo acceder al almacenamiento externo.');

      final savePath = '${dir.path}/mexa-presta-update.apk';

      final dio = Dio();
      await dio.download(
        widget.appUrl,
        savePath,
        onReceiveProgress: (received, total) {
          setState(() {
            _receivedBytes = received;
            if (total > 0) {
              _progressKnown = true;
              _progress = received / total;
            } else {
              // GitHub CDN no envía Content-Length — spinner indeterminado
              _progressKnown = false;
            }
          });
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      setState(() {
        _localPath = savePath;
        _isDownloading = false;
        _done = true;
        _progress = 1.0;
        _progressKnown = true;
        _statusText = 'Descarga Completada';
        _detailText =
            'Toca el botón para instalar. Si Android solicita permiso para instalar apps desconocidas, acéptalo.';
      });

      await _installApk(savePath);
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Error en la Descarga';
          _detailText =
              'Ocurrió un error: $e\n\nVerifica tu conexión a internet e intenta nuevamente.';
          _isDownloading = false;
          _progress = 0;
        });
      }
      debugPrint('Update download error: $e');
    }
  }

  Future<void> _installApk(String path) async {
    try {
      final result =
          await OpenFilex.open(path, type: 'application/vnd.android.package-archive');
      if (result.type != ResultType.done) {
        if (mounted) {
          setState(() {
            _statusText = 'Lista para instalar';
            _detailText =
                'Toca "Instalar Ahora" para instalar manualmente la actualización.';
          });
        }
      }
    } catch (e) {
      debugPrint('Install error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _done
                      ? Icons.check_circle_outline_rounded
                      : _isDownloading
                          ? Icons.cloud_download_outlined
                          : Icons.system_update_rounded,
                  size: 100,
                  color: _done ? Colors.green : AppColors.admin,
                ),
                const SizedBox(height: 32),
                Text(
                  _statusText,
                  style: AppTypography.headingPrincipal.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  _detailText,
                  style: AppTypography.subtext.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // ── Descargando ───────────────────────────────────────────
                if (_isDownloading) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _progressKnown
                        ? LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: AppColors.surface1,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.admin),
                            minHeight: 14,
                          )
                        : const LinearProgressIndicator(
                            backgroundColor: AppColors.surface1,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.admin),
                            minHeight: 14,
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _progressKnown
                        ? '${(_progress * 100).toStringAsFixed(1)}%'
                        : 'Descargando... ${_formatBytes(_receivedBytes)}',
                    style: AppTypography.label.copyWith(color: AppColors.admin),
                    textAlign: TextAlign.center,
                  ),

                // ── Descarga lista ─────────────────────────────────────
                ] else if (_done && _localPath != null) ...[
                  ElevatedButton.icon(
                    onPressed: () => _installApk(_localPath!),
                    icon: const Icon(Icons.install_mobile_rounded),
                    label: const Text('Instalar Ahora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                // ── Botón inicial ──────────────────────────────────────
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: _startDownload,
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Descargar e Instalar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.admin,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
