import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/models/tipo_pago_model.dart';

class AdminModalidadesView extends ConsumerStatefulWidget {
  const AdminModalidadesView({super.key});

  @override
  ConsumerState<AdminModalidadesView> createState() => _AdminModalidadesViewState();
}

class _AdminModalidadesViewState extends ConsumerState<AdminModalidadesView> {
  List<TipoPagoModel> _tiposPago = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final res = await Supabase.instance.client
          .from('tipos_pago')
          .select()
          .order('id');
      setState(() {
        _tiposPago = (res as List).map((e) => TipoPagoModel.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Modalidades de Pago'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tiposPago.isEmpty
              ? const Center(child: Text('No hay modalidades registradas', style: TextStyle(color: AppColors.ink3)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _tiposPago.length,
                  itemBuilder: (context, index) {
                    final tipo = _tiposPago[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: tipo.afectaSaldo
                                  ? AppColors.okSurface
                                  : AppColors.warnSurface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              tipo.afectaSaldo
                                  ? Icons.attach_money_rounded
                                  : Icons.receipt_long_rounded,
                              color: tipo.afectaSaldo
                                  ? AppColors.ok
                                  : AppColors.warn,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tipo.nombre,
                                  style: AppTypography.headingPrincipal.copyWith(fontSize: 15),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tipo.afectaSaldo ? 'Afecta saldo del préstamo' : 'No afecta saldo',
                                  style: TextStyle(
                                    color: tipo.afectaSaldo ? AppColors.ok : AppColors.ink4,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: tipo.activo ? AppColors.okSurface : AppColors.errorSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tipo.activo ? 'Activo' : 'Inactivo',
                              style: TextStyle(
                                color: tipo.activo ? AppColors.ok : AppColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
