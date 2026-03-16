import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/supabase_config.dart';

class AppUpdateInfo {
  final bool isUpdateRequired;
  final String? updateUrl;

  AppUpdateInfo({required this.isUpdateRequired, this.updateUrl});
}

final updateProvider = FutureProvider<AppUpdateInfo>((ref) async {
  try {
    // Attempt to fetch configuration from Supabase 'app_config' table.
    // The table should have columns: 'key' (text) and 'value' (text).
    // Expected keys: 'min_version' and 'apk_url'
    final response = await SupabaseConfig.client
        .from('app_config')
        .select('*')
        .inFilter('key', ['min_version', 'apk_url']);

    if (response.isEmpty) {
      return AppUpdateInfo(isUpdateRequired: false);
    }

    String? minVersionStr;
    String? apkUrl;

    for (var row in response) {
      if (row['key'] == 'min_version') minVersionStr = row['value'];
      if (row['key'] == 'apk_url') apkUrl = row['value'];
    }

    if (minVersionStr != null) {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionStr = packageInfo.version;

      final minVersionParts = minVersionStr.split('.').map(int.tryParse).toList();
      final currentVersionParts = currentVersionStr.split('.').map(int.tryParse).toList();

      bool requiresUpdate = false;
      
      // Simple semantic version check
      for (int i = 0; i < minVersionParts.length; i++) {
        final minPart = minVersionParts[i] ?? 0;
        final currPart = (i < currentVersionParts.length) ? (currentVersionParts[i] ?? 0) : 0;
        
        if (currPart < minPart) {
          requiresUpdate = true;
          break;
        } else if (currPart > minPart) {
          requiresUpdate = false;
          break;
        }
      }

      return AppUpdateInfo(
        isUpdateRequired: requiresUpdate,
        updateUrl: requiresUpdate ? apkUrl : null,
      );
    }

    return AppUpdateInfo(isUpdateRequired: false);
  } catch (e) {
    // If the table doesn't exist or any other error occurs, fail gracefully.
    return AppUpdateInfo(isUpdateRequired: false);
  }
});
