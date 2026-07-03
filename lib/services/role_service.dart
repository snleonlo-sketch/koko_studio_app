import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RoleService {

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  Future<Map<String, dynamic>>
  obtenerDatosUsuario() async {

    try {

      User? user =
          auth.currentUser;

      if (user == null) {

        return {

          'rol': 'trabajadora',

          'nombre': 'Usuario',

          'correo': '',
        };
      }

      final rutas = [
        'administrador',
        'trabajadoras',
        'usuarios',
      ];

      for (final ruta in rutas) {
        final snapshot =
        await database
            .child(ruta)
            .child(user.uid)
            .get();

        if (snapshot.exists) {
          final datos =
          snapshot.value as Map;

          return {
            'rol':
            datos['rol'] ??
                (ruta == 'administrador' ? 'admin' : 'trabajadora'),

            'nombre':
            datos['nombre'] ??
                'Usuario',

            'telefono':
            datos['telefono'] ??
                '',

            'sede':
            datos['sede'] ??
                '',

            'sedePreferida':
            datos['sedePreferida'] ??
                datos['sede'] ??
                '',

            'correo':
            datos['correo'] ??
                user.email ??
                '',

            'ruta':
            ruta,
          };
        }
      }

      return {

        'rol': '',

        'nombre': 'Usuario',

        'correo':
        user.email ?? '',
      };

    } catch (e) {

      return {

        'rol': 'trabajadora',

        'nombre': 'Usuario',

        'correo': '',
      };
    }
  }

  Future<String> obtenerRol() async {

    final datos =
    await obtenerDatosUsuario();

    return datos['rol'];
  }

  Future<bool> esAdmin() async {

    final rol =
    await obtenerRol();

    return rol == 'admin';
  }

  Future<bool> esRecepcionista() async {

    final rol =
    await obtenerRol();

    return rol == 'recepcionista';
  }

  Future<bool> esTrabajadora() async {

    final rol =
    await obtenerRol();

    return rol == 'trabajadora';
  }
}
