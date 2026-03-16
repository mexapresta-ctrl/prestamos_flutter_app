import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  const url = 'https://cogvtgydumgprhnwxftf.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZ3Z0Z3lkdW1ncHJobnd4ZnRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MDEzMzEsImV4cCI6MjA4OTA3NzMzMX0.QLWKLRwef7B1FyJBKKEFiiwnecB1_8HEoIaONghUWMs';
  final client = SupabaseClient(url, anonKey);
  
  try {
    final test = await client.from('clientes').select().limit(1);
    if (test.isNotEmpty) {
      File('test_clientes_output.txt').writeAsStringSync('Keys: ' + test.first.keys.toList().toString());
    } else {
      File('test_clientes_output.txt').writeAsStringSync('No clients');
    }
  } catch (e) {
    File('test_clientes_output.txt').writeAsStringSync('Error: ' + e.toString());
  }
}
