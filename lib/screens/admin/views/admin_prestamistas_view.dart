import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../core/providers/admin_provider.dart';

class AdminPrestamistasView extends ConsumerWidget {
  const AdminPrestamistasView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prestamistas'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: adminState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (data) {
          if (data.prestamistas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_outlined, size: 64, color: AppColors.ink4),
                  SizedBox(height: 16),
                  Text('No hay prestamistas registrados', style: TextStyle(color: AppColors.ink3, fontSize: 15)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.prestamistas.length,
            itemBuilder: (context, index) {
              final p = data.prestamistas[index];

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
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.admin.withValues(alpha: 0.1),
                      child: Text(
                        p['iniciales'] ?? 'PR',
                        style: const TextStyle(
                          color: AppColors.admin,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['nombre'] ?? 'Sin nombre',
                            style: AppTypography.headingPrincipal.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Usuario: ${p['usuario'] ?? ''}',
                            style: const TextStyle(color: AppColors.ink4, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.adminSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Prestamista',
                        style: TextStyle(
                          color: AppColors.admin,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
