import 'lib/core/config/supabase_config.dart';

void main() async {
  await SupabaseConfig.initialize();
  final res = await SupabaseConfig.client.from('clientes').select().limit(1);
  print(res[0].keys);
}
