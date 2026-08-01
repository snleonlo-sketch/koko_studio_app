import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_database_shim.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../utils/page_transition.dart';

import 'dashboard_cliente_screen.dart';
import 'register_cliente_screen.dart';

class LoginClienteScreen extends StatefulWidget {
  const LoginClienteScreen({
    super.key,
  });

  @override
  State<LoginClienteScreen> createState() => _LoginClienteScreenState();
}

class _LoginClienteScreenState extends State<LoginClienteScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final DatabaseReference database = FirebaseDatabase.instance.ref();

  final TextEditingController correoController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool cargando = false;

  bool ocultarPassword = true;

  Future<void> iniciarSesionCliente() async {
    if (correoController.text.isEmpty || passwordController.text.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'Campos Vacíos',
        desc: 'Complete todos los campos',
        btnOkOnPress: () {},
      ).show();

      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: correoController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      final snapshot = await database.child('usuarios').child(uid).get();

      if (!snapshot.exists) {
        throw Exception(
          'Usuario no encontrado',
        );
      }

      Map datos = snapshot.value as Map;

      if (datos['rol'] != 'cliente') {
        throw Exception(
          'Esta cuenta no pertenece a un cliente',
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageTransitionAnimation.crearTransicion(
          const DashboardClienteScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String mensaje = 'Ocurrió un error';

      if (e.code == 'user-not-found') {
        mensaje = 'No existe una cuenta con ese correo';
      }

      if (e.code == 'wrong-password') {
        mensaje = 'Contraseña incorrecta';
      }

      if (e.code == 'invalid-email') {
        mensaje = 'Correo inválido';
      }

      if (e.code == 'invalid-credential') {
        mensaje = 'Credenciales incorrectas';
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: mensaje,
        btnOkOnPress: () {},
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: e.toString(),
        btnOkOnPress: () {},
      ).show();
    }

    setState(() {
      cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                const Icon(
                  Icons.favorite,
                  size: 90,
                  color: Color(0xFFD9A5B3),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Koko Studio',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Ingreso para Clientes ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Correo electrónico',
                    prefixIcon: const Icon(
                      Icons.email,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: ocultarPassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: const Icon(
                      Icons.lock,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          ocultarPassword = !ocultarPassword;
                        });
                      },
                      icon: Icon(
                        ocultarPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: cargando ? null : iniciarSesionCliente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD9A5B3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: cargando
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Ingresar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta?',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransitionAnimation.crearTransicion(
                            const RegisterClienteScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Color(0xFFD9A5B3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
