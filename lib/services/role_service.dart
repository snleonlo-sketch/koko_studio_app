import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>> obtenerDatosUsuario() async {
    try {
      final User? user = auth.currentUser;

      if (user == null) {
        return {
          'rol': '',
          'nombre': 'Usuario',
          'correo': '',
        };
      }

      final personalSnapshot =
          await firestore.collection('personal').doc(user.uid).get();

      if (personalSnapshot.exists) {
        return _normalizarDatos(
          personalSnapshot.data() ?? <String, dynamic>{},
          user.email,
          'personal',
        );
      }

      final email = user.email?.trim().toLowerCase();
      if (email != null && email.isNotEmpty) {
        final personalPorCorreo = await firestore
            .collection('personal')
            .where('correo', isEqualTo: email)
            .limit(1)
            .get();

        if (personalPorCorreo.docs.isNotEmpty) {
          return _normalizarDatos(
            personalPorCorreo.docs.first.data(),
            user.email,
            'personal',
          );
        }
      }

      final usuarioSnapshot =
          await firestore.collection('usuarios').doc(user.uid).get();

      if (usuarioSnapshot.exists) {
        return _normalizarDatos(
          usuarioSnapshot.data() ?? <String, dynamic>{},
          user.email,
          'usuarios',
          rolPorDefecto: 'cliente',
        );
      }

      return {
        'rol': '',
        'nombre': 'Usuario',
        'correo': user.email ?? '',
      };
    } catch (e) {
      return {
        'rol': '',
        'nombre': 'Usuario',
        'correo': auth.currentUser?.email ?? '',
      };
    }
  }

  Map<String, dynamic> _normalizarDatos(
    Map<String, dynamic> datos,
    String? email,
    String ruta, {
    String rolPorDefecto = '',
  }) {
    return {
      'rol': datos['rol'] ?? rolPorDefecto,
      'nombre': datos['nombre'] ?? 'Usuario',
      'telefono': datos['telefono'] ?? '',
      'sede': datos['sede'] ?? '',
      'sedePreferida': datos['sedePreferida'] ?? datos['sede'] ?? '',
      'correo': datos['correo'] ?? email ?? '',
      'ruta': ruta,
    };
  }

  Future<String> obtenerRol() async {
    final datos = await obtenerDatosUsuario();
    return datos['rol'] ?? '';
  }

  Future<bool> esAdmin() async {
    final rol = await obtenerRol();
    return rol == 'admin';
  }

  Future<bool> esRecepcionista() async {
    final rol = await obtenerRol();
    return rol == 'recepcionista';
  }

  Future<bool> esTrabajadora() async {
    final rol = await obtenerRol();
    return rol == 'trabajadora';
  }
}
