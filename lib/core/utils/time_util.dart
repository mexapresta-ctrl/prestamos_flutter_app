/// Utilidad para forzar globalmente la zona horaria de México (UTC-6)
/// tanto en la app como en la web, sin depender de la hora del dispositivo.
class TimeUtil {
  static const Duration mexicoOffset = Duration(hours: -6);

  /// Devuelve el `DateTime` actual con los valores estrictos de la hora de México (-6).
  static DateTime now() {
    return _toMexico(DateTime.now());
  }

  /// Filtro seguro para comprobar si una fecha es "Hoy" en tiempo de México.
  static bool isToday(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final date = parse(dateStr);
      final today = now();
      return date.year == today.year && date.month == today.month && date.day == today.day;
    } catch (_) {
      return false;
    }
  }

  /// Parsea la fecha de la DB (o string ISO) y la convierte estrictamente a hora de México (-6).
  static DateTime parse(String dateStr) {
    return _toMexico(DateTime.parse(dateStr));
  }

  static DateTime _toMexico(DateTime dateTime) {
    // 1. Convertimos a UTC absoluto real
    final utc = dateTime.toUtc();
    // 2. Aplicamos el offset de México (-6 horas)
    final mex = utc.add(mexicoOffset);
    // 3. Devolvemos un DateTime "local" (sin Z) pero que matemáticamente tiene los números de México.
    return DateTime(
      mex.year,
      mex.month,
      mex.day,
      mex.hour,
      mex.minute,
      mex.second,
      mex.millisecond,
    );
  }

  /// Usa esto al guardar fechas en Supabase.
  /// Genera un String ISO 8601 con el offset explícito `-06:00`.
  /// Así Postgres sabrá que está recibiendo una hora de México y la almacenará perfecto.
  static String toIsoDb([DateTime? dt]) {
    final target = dt ?? now();
    // Genera: 2024-03-19T16:40:00-06:00
    return '${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}T${target.hour.toString().padLeft(2, '0')}:${target.minute.toString().padLeft(2, '0')}:${target.second.toString().padLeft(2, '0')}-06:00';
  }

  /// Genera un String "yyyy-MM-dd" perfecto para búsquedas rápidas si es necesario.
  static String todayIsoDate() {
    final target = now();
    return '${target.year}-${target.month.toString().padLeft(2, '0')}-${target.day.toString().padLeft(2, '0')}';
  }
}
