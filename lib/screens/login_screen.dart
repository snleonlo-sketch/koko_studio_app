import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../services/auth_service.dart';
import '../services/role_service.dart';

import 'dashboard_screen.dart';
import 'dashboard_trabajadora.dart';
import 'dashboard_cliente_screen.dart';
import 'register_cliente_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final TextEditingController
  emailController =
  TextEditingController();

  final TextEditingController
  passwordController =
  TextEditingController();

  bool cargando = false;

  final RoleService roleService =
  RoleService();

  Future<void>
  iniciarSesion() async {

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.warning,

        animType:
        AnimType.scale,

        title: 'Campos Vacíos',

        desc:
        'Complete todos los campos',

        btnOkOnPress: () {},
      ).show();

      return;
    }

    setState(() {

      cargando = true;
    });

    try {

      UserCredential userCredential =

      await AuthService().login(

        emailController.text.trim(),

        passwordController.text.trim(),
      );

      if (userCredential.user != null) {

        final datosUsuario =

        await roleService
            .obtenerDatosUsuario();

        String rol =
        datosUsuario['rol'];

        String nombre =
        datosUsuario['nombre'];

        if (!mounted) return;

        AwesomeDialog(

          context: context,

          dialogType:
          DialogType.success,

          animType:
          AnimType.scale,

          title: 'Bienvenida 💖',

          desc:
          'Hola $nombre',

          btnOkOnPress: () {

            // =========================
            // ADMIN
            // =========================

            if (rol == 'admin') {

              Navigator.pushReplacement(

                context,

                MaterialPageRoute(

                  builder: (context) =>

                  const DashboardScreen(),
                ),
              );
            }

            // =========================
            // TRABAJADORA
            // =========================

            else if (rol == 'trabajadora') {

              Navigator.pushReplacement(

                context,

                MaterialPageRoute(

                  builder: (context) =>

                  const DashboardTrabajadoraScreen(),
                ),
              );
            }

            // =========================
            // CLIENTE
            // =========================

            else if (rol == 'cliente') {

              Navigator.pushReplacement(

                context,

                MaterialPageRoute(

                  builder: (context) =>

                  const DashboardClienteScreen(),
                ),
              );
            }

            // =========================
            // ERROR ROL
            // =========================

            else {

              AwesomeDialog(

                context: context,

                dialogType:
                DialogType.error,

                title: 'Error',

                desc:
                'Rol no reconocido',

                btnOkOnPress: () {},
              ).show();
            }
          },

        ).show();
      }

    } on FirebaseAuthException catch (e) {

      String mensaje =
          'Error al iniciar sesión';

      switch (e.code) {

        case 'user-not-found':

          mensaje =
          'Usuario no encontrado';
          break;

        case 'wrong-password':

          mensaje =
          'Contraseña incorrecta';
          break;

        case 'invalid-email':

          mensaje =
          'Correo inválido';
          break;

        case 'invalid-credential':

          mensaje =
          'Credenciales incorrectas';
          break;

        default:

          mensaje =
          'Error de autenticación';
      }

      if (!mounted) return;

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.error,

        animType:
        AnimType.scale,

        title: 'Error',

        desc: mensaje,

        btnOkOnPress: () {},
      ).show();

    } catch (e) {

      if (!mounted) return;

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.error,

        animType:
        AnimType.scale,

        title: 'Error',

        desc:
        'Ocurrió un problema:\n$e',

        btnOkOnPress: () {},
      ).show();
    }

    if (mounted) {

      setState(() {

        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFFFF5F7),

      body: Center(

        child: SingleChildScrollView(

          padding:
          const EdgeInsets.all(25),

          child: Column(

            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [

              // ======================
              // LOGO
              // ======================

              Container(

                padding:
                const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(30),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black.withOpacity(0.08),

                      blurRadius: 15,

                      offset:
                      const Offset(0, 5),
                    ),
                  ],
                ),

                child: Image.asset(

                  'assets/images/logo_koko.jpg',

                  height: 120,
                ),
              ),

              const SizedBox(height: 30),

              const Text(

                'Koko Studio',

                style: TextStyle(

                  fontSize: 34,

                  fontWeight:
                  FontWeight.bold,

                  color:
                  Color(0xFFD9A5B3),
                ),
              ),

              const SizedBox(height: 10),

              const Text(

                'Sistema Empresarial de Belleza 💖',

                style: TextStyle(

                  fontSize: 18,

                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 45),

              // ======================
              // EMAIL
              // ======================

              TextField(

                controller:
                emailController,

                keyboardType:
                TextInputType.emailAddress,

                decoration:
                InputDecoration(

                  hintText:
                  'Correo electrónico',

                  filled: true,

                  fillColor:
                  Colors.white,

                  prefixIcon:
                  const Icon(
                    Icons.email,
                  ),

                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(15),

                    borderSide:
                    BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ======================
              // PASSWORD
              // ======================

              TextField(

                controller:
                passwordController,

                obscureText: true,

                decoration:
                InputDecoration(

                  hintText:
                  'Contraseña',

                  filled: true,

                  fillColor:
                  Colors.white,

                  prefixIcon:
                  const Icon(
                    Icons.lock,
                  ),

                  border:
                  OutlineInputBorder(

                    borderRadius:
                    BorderRadius.circular(15),

                    borderSide:
                    BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ======================
              // BOTON LOGIN
              // ======================

              SizedBox(

                width: double.infinity,

                height: 58,

                child: ElevatedButton(

                  onPressed:
                  cargando
                      ? null
                      : iniciarSesion,

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(0xFFD9A5B3),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(18),
                    ),
                  ),

                  child: cargando

                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )

                      : const Text(

                    'Iniciar Sesión',

                    style: TextStyle(

                      color: Colors.white,

                      fontWeight:
                      FontWeight.bold,

                      fontSize: 17,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ======================
              // REGISTRO CLIENTE
              // ======================

              Row(

                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [

                  const Text(

                    '¿No tienes cuenta?',
                  ),

                  TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (context) =>

                          const RegisterClienteScreen(),
                        ),
                      );
                    },

                    child: const Text(

                      'Registrarse',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}