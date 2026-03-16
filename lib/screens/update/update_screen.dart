import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
      // 1. Request storage permissions
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) {
            // Check for manage external storage on Android 11+
            var manageStatus = await Permission.manageExternalStorage.status;
            if (!manageStatus.isGranted) {
               await Permission.manageExternalStorage.request();
            }
          }
        }
      }

      // 2. Determine path
      final dir = await getTemporaryDirectory();
      final filePath = '\${dir.path}/app-release-\${DateTime.now().millisecondsSinceEpoch}.apk';

      // 3. Download file
      Dio dio = Dio();
      await dio.download(
        widget.appUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      setState(() {
        _statusText = 'Descarga Completada';
        _detailText = 'Iniciando la instalación. Si Android te pide permisos para instalar aplicaciones desconocidas, acéptalos.';
        _isDownloading = false;
        _progress = 1.0;
      });

      // 4. Install APK
      final result = await OpenFilex.open(filePath);
      
      if (result.type != ResultType.done) {
        setState(() {
          _statusText = 'Error en Instalación';
          _detailText = 'No se pudo abrir el instalador: \${result.message}';
          _isDownloading = false;
        });
      }

    } catch (e) {
      setState(() {
        _statusText = 'Error en la Descarga';
        _detailText = 'Hubo un problema al intentar descargar el archivo. Verifica tu conexión a internet o intenta nuevamente.';
        _isDownloading = false;
        _progress = 0;
      });
      debugPrint('Error downloading: $e');
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
                  text: _progress >= 1.0 ? 'Instalar de nuevo' : 'Descargar e Instalar',
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
