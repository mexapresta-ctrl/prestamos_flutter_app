import 'package:curp/curp.dart';

void main() {
  var curpObj = Curp(
    nombre: 'Juan',
    apellidoPaterno: 'Perez',
    apellidoMaterno: 'Lopez',
    fechaNacimiento: '1990-10-15',
    genero: 'H',
    estado: 'DF'
  );
  print(curpObj.curp);
}
