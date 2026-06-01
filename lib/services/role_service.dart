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

      final snapshot =

      await database
          .child('usuarios')
          .child(user.uid)
          .get();

      if (snapshot.exists) {

        Map datos =
        snapshot.value as Map;

        return {

          'rol':
          datos['rol'] ??
              'trabajadora',

          'nombre':
          datos['nombre'] ??
              'Usuario',

          'correo':
          user.email ?? '',
        };
      }

      return {

        'rol': 'trabajadora',

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

  Future<bool> esTrabajadora() async {

    final rol =
    await obtenerRol();

    return rol == 'trabajadora';
  }
}