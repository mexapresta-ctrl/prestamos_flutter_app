import 'package:supabase/supabase.dart';

void main() async {
  const url = 'https://cogvtgydumgprhnwxftf.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvZ3Z0Z3lkdW1ncHJobnd4ZnRmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM1MDEzMzEsImV4cCI6MjA4OTA3NzMzMX0.QLWKLRwef7B1FyJBKKEFiiwnecB1_8HEoIaONghUWMs';
  final client = SupabaseClient(url, anonKey);
  
  try {
    // Check if it's there
    final exists = await client.from('app_config').select('*');
    if (exists.isEmpty) {
        print('Inserting records...');
        await client.from('app_config').insert([
            {'key': 'min_version', 'value': '1.0.7'},
            {'key': 'apk_url', 'value': 'https://github.com/leslyyareth866-code/prestamos_flutter_app/releases/latest/download/mexa-presta.apk'},
        ]);
        print('Insert successful.');
    } else {
        print('Records exist. Updating...');
        await client.from('app_config').update({'value': '1.0.7'}).eq('key', 'min_version');
        await client.from('app_config').update({'value': 'https://github.com/leslyyareth866-code/prestamos_flutter_app/releases/latest/download/mexa-presta.apk'}).eq('key', 'apk_url');
        print('Update successful.');
    }
    
    final test = await client.from('app_config').select('*');
    print('VERIFICATION: $test');
  } catch (e) {
    print('ERROR: $e');
  }
}
