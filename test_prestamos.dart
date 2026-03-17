import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  const url = 'https://cogvtgydumgprhnwxftf.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZ3Z0Z3lkdW1ncHJobnd4ZnRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MDEzMzEsImV4cCI6MjA4OTA3NzMzMX0.QLWKLRwef7B1FyJBKKEFiiwnecB1_8HEoIaONghUWMs';
  final client = SupabaseClient(url, anonKey);
  
  try {
    final test = await client.from('prestamos').select('*').limit(3);
    
    String output = '';
    for (var p in test) {
      output += 'ID: \${p['id']}\n';
      output += 'Estado: \${p['estado']}\n';
      output += 'Cuota Semanal: \${p['cuota_semanal']}\n';
      output += 'Cuota Semanal Type: \${p['cuota_semanal'].runtimeType}\n';
      output += 'Cuotas Totales: \${p['cuotas_totales']}\n';
      output += 'Cuotas Totales Type: \${p['cuotas_totales'].runtimeType}\n';
      output += 'Activo: \${p['activo']}\n';
      output += '-------------------\n';
    }
    
    File('test_prestamos_output.txt').writeAsStringSync(output);
  } catch (e) {
    File('test_prestamos_output.txt').writeAsStringSync('Error: $e');
  }
}
