import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/supabase_config.dart';
import '../models/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be set to null explicitly
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<bool> login(String usuario, String password, String rol) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await SupabaseConfig.client
          .from('usuarios')
          .select('*')
          .eq('usuario', usuario)
          .eq('password', password) // In production, never query plain passwords. But matching the web approach here.
          .eq('rol', rol)
          .eq('activo', true)
          .maybeSingle();

      if (data != null) {
        final user = UserModel.fromJson(data);
        state = state.copyWith(isLoading: false, user: user);
        
        // Log Audit (fire and forget)
        _logAudit(user, 'LOGIN', '\${user.nombre} inició sesión en la app');

        return true;
      } else {
        state = state.copyWith(
          isLoading: false, 
          error: 'Credenciales incorrectas o rol no autorizado'
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: 'Ocurrió un error al conectar con el servidor.'
      );
      print('Login error: \$e');
      return false;
    }
  }

  void logout() {
    final user = state.user;
    if (user != null) {
      _logAudit(user, 'LOGOUT', '\${user.nombre} cerró sesión');
    }
    state = AuthState(); 
  }

  Future<void> _logAudit(UserModel user, String tipo, String descripcion) async {
    try {
      await SupabaseConfig.client
        .from('auditoria')
        .insert({
          'tipo': tipo,
          'descripcion': descripcion,
          'usuario': user.nombre, // Match web format
          'rol': user.rol,
        });
    } catch (e) {
      print('Audit log error: \$e');
    }
  }
}
