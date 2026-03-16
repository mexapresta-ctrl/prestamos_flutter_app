import 'package:supabase/supabase.dart';

void main() async {
  const url = 'https://cogvtgydumgprhnwxftf.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZ3Z0Z3lkdW1ncHJobnd4ZnRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MDEzMzEsImV4cCI6MjA4OTA3NzMzMX0.QLWKLRwef7B1FyJBKKEFiiwnecB1_8HEoIaONghUWMs';
  final client = SupabaseClient(url, anonKey);
  
  try {
    // Delete by duplicate IDs
    print('Cleaning up duplicates...');
    await client.from('app_config').delete().eq('id', 3);
    await client.from('app_config').delete().eq('id', 4);
    
    final test = await client.from('app_config').select('*');
    print('Final VERIFICATION: $test');
  } catch (e) {
    print('ERROR: $e');
  }
}
