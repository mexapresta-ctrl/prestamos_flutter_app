import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_filex/open_filex.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/custom_button.dart';

class UpdateScreen extends StatefulWidget {
  final String appUrl;

  const UpdateScreen({super.key, required this.appUrl});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isDownloading = false;
  double _progress = 0;
  String _statusText = '¡Nueva Versión Disponible!';
  String _detailText = 'MEXA PRESTA se ha actualizado para brindarte un mejor servicio. Es necesario descargar la última versión para continuar.';

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'Descargando Actualización...';
      _detailText = 'Por favor, no cierres esta pantalla hasta que se complete la descarga.';
      _progress = 0;
    });

    try {
      if (!Platform.isAndroid) return;

      // Usar flutter_file_downloader asegura descargar los archivos resolviendo los permisos correctamente.
      // Al usar downloadDestination: DownloadDestinations.appFiles el APK se guardará
      // en la memoria limpia (Data) del teléfono sin ensuciar la carpeta visible de "Descargas" del usuario.
      FileDownloader.downloadFile(
        url: widget.appUrl,
        name: 'mexa-presta-update.apk',
        downloadDestination: DownloadDestinations.appFiles,
        onProgress: (name, progress) {
          setState(() {
            _progress = progress / 100.0;
          });
        },
        onDownloadCompleted: (path) async {
          setState(() {
            _statusText = 'Descarga Completada';
            _detailText = 'Iniciando la instalación. Si Android te pide permisos para instalar aplicaciones desconocidas, acéptalos.';
            _isDownloading = false;
            _progress = 1.0;
          });

          // Iniciar la instalación
          final result = await OpenFilex.open(path);
          
          if (result.type != ResultType.done) {
            if (mounted) {
              setState(() {
                _statusText = 'Error en Instalación';
                _detailText = 'No se pudo iniciar el instalador (Código: \${result.message}). Por favor, contacta a soporte.';
                _isDownloading = false;
              });
            }
          }
        },
        onDownloadError: (errorMessage) {
          if (mounted) {
            setState(() {
              _statusText = 'Error en la Descarga';
              _detailText = 'Ocurrió el siguiente error: $errorMessage. Verifica tu conexión a internet o intenta nuevamente.';
              _isDownloading = false;
              _progress = 0;
            });
          }
          debugPrint('Download error: $errorMessage');
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Error en la Ejecución';
          _detailText = 'Excepción: $e';
          _isDownloading = false;
          _progress = 0;
        });
      }
      debugPrint('Exception downloading update: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                _isDownloading ? Icons.cloud_download_outlined : Icons.system_update_rounded,
                size: 80,
                color: AppColors.admin,
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 32),
              
              if (_isDownloading) ...[
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: AppColors.surface1,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.admin),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 12),
                Text(
                  '\${(_progress * 100).toStringAsFixed(1)}%',
                  style: AppTypography.label.copyWith(color: AppColors.admin),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                CustomButton(
                  text: _progress >= 1.0 ? 'Reintentar instalación' : 'Descargar e Instalar',
                  onPressed: _startDownload,
                  icon: Icons.download_rounded,
                  type: ButtonType.admin,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
