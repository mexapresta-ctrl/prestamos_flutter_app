import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';

// GitHub repo info
const _githubRepo = 'mexapresta-ctrl/prestamos_flutter_app';
const _githubApkUrl =
    'https://github.com/$_githubRepo/releases/latest/download/app-arm64-v8a-release.apk';

class AppUpdateInfo {
  final bool isUpdateRequired;
  final String? updateUrl;
  final String? latestVersion;

  AppUpdateInfo({required this.isUpdateRequired, this.updateUrl, this.latestVersion});
}

final updateProvider = FutureProvider<AppUpdateInfo>((ref) async {
  try {
    // 1. Get current app version
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version; // e.g. "1.0.27"

    // 2. Check latest release from GitHub API
    final dio = Dio();
    final res = await dio.get(
      'https://api.github.com/repos/$_githubRepo/releases/latest',
      options: Options(
        receiveTimeout: const Duration(seconds: 8),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ),
    );

    if (res.statusCode != 200 || res.data == null) {
      return AppUpdateInfo(isUpdateRequired: false);
    }

    // 3. Parse latest version from tag (e.g. "v1.0.28" -> "1.0.28")
    final tagName = res.data['tag_name']?.toString() ?? '';
    final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

    // 4. Compare versions
    final requiresUpdate = _isNewerVersion(latestVersion, currentVersion);

    // 5. Get download URL from release assets (fallback to direct URL)
    String downloadUrl = _githubApkUrl;
    final assets = res.data['assets'] as List?;
    if (assets != null && assets.isNotEmpty) {
      for (var asset in assets) {
        final name = asset['name']?.toString() ?? '';
        if (name.endsWith('.apk')) {
          downloadUrl = asset['browser_download_url']?.toString() ?? _githubApkUrl;
          break;
        }
      }
    }

    return AppUpdateInfo(
      isUpdateRequired: requiresUpdate,
      updateUrl: requiresUpdate ? downloadUrl : null,
      latestVersion: latestVersion,
    );
  } catch (e) {
    return AppUpdateInfo(isUpdateRequired: false);
  }
});

/// Returns true if [latest] is newer than [current].
/// Compares semantic version parts (e.g. "1.0.28" > "1.0.27").
bool _isNewerVersion(String latest, String current) {
  final cleanLatest = latest.split('+').first;
  final cleanCurrent = current.split('+').first;
  final latestParts = cleanLatest.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final currentParts = cleanCurrent.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  for (int i = 0; i < latestParts.length; i++) {
    final l = latestParts[i];
    final c = (i < currentParts.length) ? currentParts[i] : 0;

    if (c < l) return true;
    if (c > l) return false;
  }

  return false;
}
