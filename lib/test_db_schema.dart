import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void main() async {
  const url = 'https://cogvtgydumgprhnwxftf.supabase.co/rest/v1/';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZ3Z0Z3lkdW1ncHJobnd4ZnRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MDEzMzEsImV4cCI6MjA4OTA3NzMzMX0.QLWKLRwef7B1FyJBKKEFiiwnecB1_8HEoIaONghUWMs';
  
  final dio = Dio();
  final opts = Options(headers: {
    'apikey': anonKey,
    'Authorization': 'Bearer \$anonKey',
  });
  
  try {
    final res = await dio.get('${url}modalidades', options: opts);
    debugPrint('modalidades exists! ${res.data}');
  } catch (e) {
    debugPrint('modalidades error: $e');
  }

  try {
    final res2 = await dio.get('${url}tipos_pago', options: opts);
    debugPrint('tipos_pago exists! ${res2.data}');
  } catch (e) {
    debugPrint('tipos_pago error: $e');
  }
}
