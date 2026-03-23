import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/core/config/supabase_config.dart';

void main() async {
  await SupabaseConfig.initialize();
  
  try {
    final planes = await SupabaseConfig.client.from('planes').select();
    print('PLANES_RESULT: \$planes');
  } catch (e) {
    print('PLANES_ERROR: \$e');
  }

  try {
    final prestamistas = await SupabaseConfig.client.from('usuarios').select('id, nombre, rol').eq('rol', 'prestamista');
    print('PRESTAMISTAS_RESULT: \$prestamistas');
  } catch(e) {
    print('PRESTAMISTAS_ERROR: \$e');
  }
}
