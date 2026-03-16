import 'package:supabase/supabase.dart';

void main() async {
  const String url = 'https://cogvtgydumgprhnwxftf.supabase.co';
  const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZ3Z0Z3lkdW1ncHJobnd4ZnRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MDEzMzEsImV4cCI6MjA4OTA3NzMzMX0.QLWKLRwef7B1FyJBKKEFiiwnecB1_8HEoIaONghUWMs';

  final client = SupabaseClient(url, anonKey);

  try {
    final response = await client.from('app_config').select('*');
    print('CONFIG: $response');
  } catch (e) {
    print('ERR: $e');
  }
}
