import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:math' as math;

import '../auth/login_assets.dart';

class UpdateScreen extends StatefulWidget {
  final String appUrl;

  const UpdateScreen({super.key, required this.appUrl});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> with TickerProviderStateMixin {
  bool _isDownloading = false;
  bool _done = false;
  
  // Isolate download progress to avoid rebuilding the entire screen
  final ValueNotifier<Map<String, dynamic>> _downloadState = ValueNotifier({'received': 0, 'total': 0, 'progress': 0.0});
  String? _localPath;

  String _currentVersion = 'v1.0.0';
  String _newVersion = 'Verificando...';
  List<Map<String, String>> _changelog = [];
  bool _isLoadingInfo = true;

  late AnimationController _badgePulseController;

  late AnimationController _dotBlinkController;
  late Animation<double> _dotBlink;

  late AnimationController _fadeUpController;
  late Animation<double> _fadeUpSlide;
  late Animation<double> _fadeUpOpacity;

  // success animation
  late AnimationController _successController;

  @override
  void initState() {
    super.initState();

    _badgePulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: false);

    _dotBlinkController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _dotBlink = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
      parent: _dotBlinkController,
      curve: Curves.easeInOut,
    ));

    _fadeUpController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeUpSlide = Tween<double>(begin: 20, end: 0).animate(CurvedAnimation(
      parent: _fadeUpController,
      curve: Curves.easeOutCubic,
    ));
    _fadeUpOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _fadeUpController,
      curve: Curves.easeOut,
    ));

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Delay fade-up to let layout settle and avoid visual glitches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _fadeUpController.forward();
    });

    _initInfo();
  }

  Future<void> _initInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _currentVersion = 'v${info.version}';
      });
    } catch (_) {}

    try {
      final dio = Dio();
      final res = await dio.get(
        'https://api.github.com/repos/mexapresta-ctrl/prestamos_flutter_app/releases/latest',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      if (res.statusCode == 200 && res.data != null) {
        final version = res.data['tag_name']?.toString() ?? 'v2.4.0';
        final body = res.data['body']?.toString() ?? '';
        setState(() {
          _newVersion = version;
          _changelog = _parseChangelog(body);
          _isLoadingInfo = false;
        });
      } else {
        _setFallbackInfo();
      }
    } catch (e) {
      _setFallbackInfo();
    }
  }

  void _setFallbackInfo() {
    setState(() {
      _newVersion = 'Nueva versión';
      _changelog = [
        {'type': 'mejora', 'text': 'Actualización con mejoras de rendimiento y nuevas funciones.'}
      ];
      _isLoadingInfo = false;
    });
  }

  List<Map<String, String>> _parseChangelog(String body) {
    if (body.isEmpty) return [];
    final lines = body.split('\n');
    final List<Map<String, String>> items = [];

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('*') || line.startsWith('-')) {
        line = line.substring(1).trim();
        String type = 'mejora';
        String text = line;

        final lowerLine = line.toLowerCase();
        if (lowerLine.startsWith('nuevo:') ||
            lowerLine.startsWith('new:') ||
            lowerLine.startsWith('[nuevo]') ||
            lowerLine.startsWith('[new]')) {
          type = 'nuevo';
          text = line.replaceFirst(RegExp(r'^(nuevo:|new:|\[nuevo\]|\[new\])\s*', caseSensitive: false), '');
        } else if (lowerLine.startsWith('fix:') ||
            lowerLine.startsWith('correccion:') ||
            lowerLine.startsWith('[fix]') ||
            lowerLine.startsWith('corregido:')) {
          type = 'fix';
          text = line.replaceFirst(RegExp(r'^(fix:|correccion:|\[fix\]|corregido:)\s*', caseSensitive: false), '');
        } else if (lowerLine.startsWith('mejora:')) {
          text = line.replaceFirst(RegExp(r'^mejora:\s*', caseSensitive: false), '');
        }

        items.add({'type': type, 'text': text});
      }
    }

    if (items.isEmpty) {
      items.add({'type': 'mejora', 'text': body.replaceAll('*', '').replaceAll('-', '').trim()});
    }

    return items;
  }

  @override
  void dispose() {
    _badgePulseController.dispose();
    _dotBlinkController.dispose();
    _fadeUpController.dispose();
    _successController.dispose();
    _downloadState.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _startDownload() async {
    _downloadState.value = {'received': 0, 'total': 0, 'progress': 0.0};
    setState(() {
      _isDownloading = true;
      _done = false;
    });

    try {
      if (!Platform.isAndroid) return;

      final dir = await getExternalStorageDirectory();
      if (dir == null) throw Exception('No se pudo acceder al almacenamiento externo.');

      final savePath = '${dir.path}/mexa-presta-update.apk';

      final dio = Dio();
      DateTime lastUpdate = DateTime.now();
      await dio.download(
        widget.appUrl,
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
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (!mounted) return;

      setState(() {
        _localPath = savePath;
        _isDownloading = false;
        _done = true;
      });
      
      _successController.forward(from: 0.0);

      await Future.delayed(const Duration(milliseconds: 800));

      await _installApk(savePath);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en la descarga: $e')),
        );
      }
      debugPrint('Update download error: $e');
    }
  }

  Future<void> _installApk(String path) async {
    try {
      final result = await OpenFilex.open(path, type: 'application/vnd.android.package-archive');
      if (result.type != ResultType.done) {
        // failed to open
      }
    } catch (e) {
      debugPrint('Install error: $e');
    }
  }

  Widget _buildChangelog() {
    if (_isLoadingInfo) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF006847))),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      margin: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOVEDADES DE ESTA VERSIÓN',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 12),
          ..._changelog.map((item) {
            Color tagBg;
            Color tagText;
            String tagLabel = item['type']!.toUpperCase();

            switch (item['type']) {
              case 'nuevo':
                tagBg = const Color(0xFFEFF6FF);
                tagText = const Color(0xFF1E3A8A);
                break;
              case 'fix':
                tagBg = const Color(0xFFFFF7ED);
                tagText = const Color(0xFF92400E);
                break;
              case 'mejora':
              default:
                tagBg = const Color(0xFFECFDF5);
                tagText = const Color(0xFF065F46);
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 1, right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: tagBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tagLabel,
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: tagText,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item['text'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D3142),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: Stack(
          children: [
            // Background gradients
            Positioned.fill(
              child: CustomPaint(
                painter: _AtmosphericBackgroundPainter(),
              ),
            ),

            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: AnimatedBuilder(
                    animation: _fadeUpController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeUpOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _fadeUpSlide.value),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 480),
                      padding: const EdgeInsets.fromLTRB(36, 36, 36, 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1)),
                          BoxShadow(color: Color(0x0F000000), blurRadius: 24, offset: Offset(0, 8)),
                          BoxShadow(color: Color(0x0F000000), blurRadius: 56, offset: Offset(0, 24)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // LOGO
                          Image.memory(
                            LoginAssets.getDecodedLogo(),
                            width: 130,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 24),

                          // DIVIDER
                          Container(
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Color(0xFFE5E7EB), Colors.transparent],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // BADGE — fixed: no spreading shadow to avoid distortion
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(99),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _dotBlink,
                                  builder: (context, child) {
                                    return Opacity(
                                      opacity: _dotBlink.value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  "ACTUALIZACIÓN DISPONIBLE",
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF065F46),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // TITLE
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0D1117),
                                height: 1.25,
                              ),
                              children: const [
                                TextSpan(text: 'Nueva '),
                                TextSpan(
                                  text: 'versión',
                                  style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF006847)),
                                ),
                                TextSpan(text: ' disponible'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Se encontró una actualización con mejoras\nde rendimiento y nuevas funciones.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF9CA3AF),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // VERSION CHIPS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F4F6),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.history_rounded, size: 14, color: Color(0xFF6B7280)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_currentVersion actual',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0),
                                child: Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF9CA3AF)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  border: Border.all(color: const Color(0xFFBFDBFE)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.new_releases_outlined, size: 14, color: Color(0xFF1E3A8A)),
                                    const SizedBox(width: 6),
                                    Text(
                                      '$_newVersion nueva',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // CHANGELOG
                          _buildChangelog(),

                          // PROGRESS
                          if (_isDownloading)
                            Container(
                              margin: const EdgeInsets.only(bottom: 22),
                              child: ValueListenableBuilder<Map<String, dynamic>>(
                                valueListenable: _downloadState,
                                builder: (context, state, child) {
                                  final int received = state['received'] ?? 0;
                                  final int total = state['total'] ?? 0;
                                  final double progress = state['progress'] ?? 0.0;
                                  final bool isKnown = total > 0;

                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Descargando actualización...',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                          Text(
                                            isKnown ? '${(progress * 100).toInt()}%' : _formatBytes(received),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      SizedBox(
                                        height: 6,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(99),
                                          child: isKnown
                                              ? LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor: const Color(0xFFE5E7EB),
                                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                                )
                                              : const LinearProgressIndicator(
                                                  backgroundColor: Color(0xFFE5E7EB),
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                                ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                          // BUTTONS
                          if (!_isDownloading && !_done) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: _startDownload,
                                icon: const Icon(Icons.system_update_alt_rounded, size: 20),
                                label: Text(
                                  'Actualizar ahora',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006847),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                ).copyWith(
                                  overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF9CA3AF),
                                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                ).copyWith(
                                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                                      return const Color(0xFF2D3142);
                                    }
                                    return const Color(0xFF9CA3AF);
                                  }),
                                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                                    if (states.contains(WidgetState.pressed) || states.contains(WidgetState.hovered)) {
                                      return const Color(0xFFF3F4F6);
                                    }
                                    return Colors.transparent;
                                  }),
                                ),
                                child: Text(
                                  'Recordar más tarde',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                          ] else if (_done && _localPath != null) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () => _installApk(_localPath!),
                                icon: const Icon(Icons.install_mobile_rounded, size: 20),
                                label: Text(
                                  'Instalar Manualmente',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006847),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // SUCCESS OVERLAY
            if (_done)
              AnimatedBuilder(
                animation: _successController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.55 * _successController.value),
                      child: _successController.value > 0.1
                          ? Center(
                              child: Transform.scale(
                                scale: 0.9 + (0.1 * _successController.value),
                                child: Container(
                                  width: 320,
                                  padding: const EdgeInsets.all(36),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 64, offset: Offset(0, 24))],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: CustomPaint(
                                          painter: _SuccessIconPainter(progress: _successController.value),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        '¡Actualización lista!',
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0D1117),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'MexaPresta $_newVersion se ha descargado\ncorrectamente.',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF9CA3AF),
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SuccessIconPainter extends CustomPainter {
  final double progress;

  _SuccessIconPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2.5;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw rings
    for (int i = 0; i < 3; i++) {
      double pt = (progress * 1.4 + i * 0.33) % 1.0;
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF065F46).withOpacity((1 - pt) * 0.35);
      canvas.drawCircle(center, radius + pt * 22, ringPaint);
    }

    // Solid Circle
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF065F46)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, bgPaint);

    // Arc
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = Colors.white.withOpacity(0.25);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.88,
      math.pi * 0.76,
      false,
      arcPaint,
    );

    // Checkmark
    double cp = math.min(progress * 2.5, 1.0);
    final checkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = Colors.white;

    final p1 = center + const Offset(-22, 4);
    final p2 = center + const Offset(-5, 21);
    final p3 = center + const Offset(25, -15);

    if (cp > 0) {
      final path = Path();
      path.moveTo(p1.dx, p1.dy);
      if (cp < 0.5) {
        double p = cp * 2;
        path.lineTo(p1.dx + (p2.dx - p1.dx) * p, p1.dy + (p2.dy - p1.dy) * p);
      } else {
        double p = (cp - 0.5) * 2;
        path.lineTo(p2.dx, p2.dy);
        path.lineTo(p2.dx + (p3.dx - p2.dx) * p, p2.dy + (p3.dy - p2.dy) * p);
      }
      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SuccessIconPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _AtmosphericBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Top-Left Green Gradient
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFF006847).withOpacity(0.04), Colors.transparent],
        stops: const [0.0, 0.65],
      ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.15, size.height * 0.20),
          width: 800,
          height: 600));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    // Bottom-Right Red Gradient
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFCE1126).withOpacity(0.04), Colors.transparent],
        stops: const [0.0, 0.65],
      ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.88, size.height * 0.85),
          width: 700,
          height: 600));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);

    // Center Gold Gradient
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [const Color(0xFFC8960C).withOpacity(0.03), Colors.transparent],
        stops: const [0.0, 0.60],
      ).createShader(Rect.fromCenter(
          center: Offset(size.width * 0.50, size.height * 0.50),
          width: 500,
          height: 500));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
