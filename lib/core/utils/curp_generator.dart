import 'package:intl/intl.dart';

class CurpGenerator {
  static const List<String> _consonantes = ['B','C','D','F','G','H','J','K','L','M','N','Ñ','P','Q','R','S','T','V','W','X','Y','Z'];
  static const List<String> _vocales = ['A','E','I','O','U'];

  static String generate({
    required String nombres,
    required String apellidoPaterno,
    required String apellidoMaterno,
    required DateTime? fechaNacimiento,
    required String sexo, // 'H' o 'M'
    required String claveEstado, // 'DF', 'CM', 'GT', etc.
  }) {
    if (nombres.isEmpty || apellidoPaterno.isEmpty || fechaNacimiento == null || sexo.isEmpty || claveEstado.isEmpty) {
      return '';
    }

    try {
      final n = _clean(nombres);
      final p = _clean(apellidoPaterno);
      final m = _clean(apellidoMaterno.isEmpty ? 'X' : apellidoMaterno);

      String p1 = p.isNotEmpty ? p.substring(0, 1) : 'X';
      String p2 = _firstVowel(p.substring(1));
      String p3 = m.isNotEmpty ? m.substring(0, 1) : 'X';
      
      // Filtro José/María
      String primerNombre = n;
      final partesNombre = n.split(' ');
      if (partesNombre.length > 1 && (partesNombre[0] == 'JOSE' || partesNombre[0] == 'MARIA')) {
        primerNombre = partesNombre[1];
      }
      String p4 = primerNombre.isNotEmpty ? primerNombre.substring(0, 1) : 'X';

      String root = '$p1$p2$p3$p4';
      root = _filterBadWords(root);

      String fNac = DateFormat('yyMMdd').format(fechaNacimiento);
      String s = sexo.toUpperCase().startsWith('M') ? 'M' : 'H';
      String est = claveEstado.length == 2 ? claveEstado.toUpperCase() : 'NE';

      String c1 = _firstConsonant(p.substring(1));
      String c2 = _firstConsonant(m.substring(1));
      String c3 = _firstConsonant(primerNombre.substring(1));

      // 00 final generico. El RENAPO asigna la homoclave real.
      String curp = '$root$fNac$s$est$c1$c2$c3' '00';
      return curp.toUpperCase();
    } catch (e) {
      return '';
    }
  }

  static String _clean(String text) {
    if (text.isEmpty) return 'X';
    return text.trim().toUpperCase()
        .replaceAll('Á', 'A').replaceAll('É', 'E').replaceAll('Í', 'I').replaceAll('Ó', 'O').replaceAll('Ú', 'U')
        .replaceAll(RegExp(r'[^A-Z]'), '');
  }

  static String _firstVowel(String text) {
    for (int i = 0; i < text.length; i++) {
      if (_vocales.contains(text[i])) return text[i];
    }
    return 'X';
  }

  static String _firstConsonant(String text) {
    for (int i = 0; i < text.length; i++) {
      if (_consonantes.contains(text[i])) return text[i];
    }
    return 'X';
  }

  static String _filterBadWords(String root) {
    const bad = ['BACA', 'BAKA', 'BUEI', 'BUEY', 'CACA', 'CACO', 'CAGA', 'CAGO', 'CAKA', 'CAKO', 'COGE', 'COGI', 'COJA', 'COJE', 'COJI', 'COJO', 'COLA', 'CULO', 'FALO', 'GETA', 'GUEI', 'GUEY', 'JETA', 'JOTO', 'KACA', 'KACO', 'KAGA', 'KAGO', 'KAKA', 'KAKO', 'KOGE', 'KOGI', 'KOJA', 'KOJE', 'KOJI', 'KOJO', 'KOLA', 'KULO', 'LILO', 'LOCA', 'LOCO', 'LOKA', 'LOKO', 'MAME', 'MAMI', 'MAMO', 'MEAR', 'MEAS', 'MEON', 'MIAR', 'MION', 'MOCO', 'MOKO', 'MULA', 'MULO', 'NACA', 'NACO', 'PEDA', 'PEDO', 'PENE', 'PIPI', 'PITO', 'POPO', 'PUTA', 'PUTO', 'QULO', 'RATA', 'ROBA', 'ROBE', 'ROBO', 'RUIN', 'SENO', 'TETA', 'VACA', 'VAGA', 'VAGO', 'VAKA', 'VUEI', 'VUEY', 'WUEI', 'WUEY'];
    if (bad.contains(root)) {
      return '${root.substring(0, 1)}X${root.substring(2)}';
    }
    return root;
  }
}
