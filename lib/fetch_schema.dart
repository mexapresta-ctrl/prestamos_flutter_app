import 'dart:io';
import 'package:supabase/supabase.dart';
import 'config/supabase_config.dart';

void main() async {
  final supabase = SupabaseClient(SupabaseConfig.url, SupabaseConfig.anonKey);
  final res = await supabase.from('clientes').select().limit(1);
  print(res);
  exit(0);
}
