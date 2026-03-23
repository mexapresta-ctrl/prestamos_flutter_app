import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

void main() async {
  const url = 'https://cogvtgydumgprhnwxftf.supabase.co/rest/v1/';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZ3Z0Z3lkdW1ncHJobnd4ZnRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MDEzMzEsImV4cCI6MjA4OTA3NzMzMX0.QLWKLRwef7B1FyJBKKEFiiwnecB1_8HEoIaONghUWMs';
  
  try {
    final dio = Dio();
    final res = await dio.get(url, options: Options(headers: {'apikey': anonKey}));
    
    if (res.statusCode == 200) {
      final data = res.data;
      final definitions = data['definitions'] as Map<String, dynamic>?;
      if (definitions != null) {
        for (final table in definitions.keys) {
          debugPrint('Table: $table');
        }
      }
    } else {
      debugPrint('Error: \${res.statusCode}');
    }
  } catch (e) {
    debugPrint('Error: $e');
  }
}
