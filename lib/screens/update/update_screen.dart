import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _statusText = '¡Nueva Versión Disponible!';
  String _detailText = 'MEXA PRESTA se ha actualizado para brindarte un mejor servicio. Es necesario descargar la última versión para continuar.';

  Future<void> _startDownload() async {
    final uri = Uri.parse(widget.appUrl);
    
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        setState(() {
          _statusText = 'No se pudo abrir el enlace';
          _detailText = 'Por favor, intenta de nuevo o contacta a soporte.';
        });
      } else {
        setState(() {
          _statusText = 'Descargando Actualización...';
          _detailText = 'Revisa tus notificaciones para ver el progreso. Cuando termine, toca la notificación para instalar el APK.';
        });
      }
    } catch(e) {
      debugPrint('Error launching url: $e');
      setState(() {
        _statusText = 'Error en el enlace';
        _detailText = 'Hubo un error al intentar abrir el navegador.';
      });
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
              const Icon(
                Icons.system_update_rounded,
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
              
              CustomButton(
                text: 'Descargar Actualización Navegador',
                onPressed: _startDownload,
                icon: Icons.download_rounded,
                type: ButtonType.admin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
