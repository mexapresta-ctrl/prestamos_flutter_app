import 'package:supabase/supabase.dart';

void main() async {
  const url = 'https://cogvtgydumgprhnwxftf.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZ3Z0Z3lkdW1ncHJobnd4ZnRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MDEzMzEsImV4cCI6MjA4OTA3NzMzMX0.QLWKLRwef7B1FyJBKKEFiiwnecB1_8HEoIaONghUWMs';
  final client = SupabaseClient(url, anonKey);
  
  try {
    final c = await client.from('clientes').select('*').limit(1);
    print('CLIENTE: $c');

    final p = await client.from('prestamos').select('*').limit(1);
    print('PRESTAMO: $p');
    
    final u = await client.from('usuarios').select('*').limit(1);
    print('USUARIO: $u');
  } catch(e) {
    print('ERROR: $e');
  }
}
