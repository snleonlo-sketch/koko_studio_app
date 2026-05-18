import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../utils/page_transition.dart';

import 'dashboard_cliente_screen.dart';

class RegisterClienteScreen
    extends StatefulWidget {

  const RegisterClienteScreen({
    super.key,
  });

  @override
  State<RegisterClienteScreen>
  createState() =>
      _RegisterClienteScreenState();
}

class _RegisterClienteScreenState
    extends State<RegisterClienteScreen> {

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final TextEditingController
  nombreController =
  TextEditingController();

  final TextEditingController
  telefonoController =
  TextEditingController();

  final TextEditingController
  correoController =
  TextEditingController();

  final TextEditingController
  passwordController =
  TextEditingController();

  bool cargando = false;

  bool ocultarPassword = true;

  Future<void>
  registrarCliente() async {

    if (nombreController.text.isEmpty ||
        telefonoController.text.isEmpty ||
        correoController.text.isEmpty ||
        passwordController.text.isEmpty) {

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.warning,

        title: 'Campos Vacíos',

        desc:
        'Complete todos los campos',

        btnOkOnPress: () {},
      ).show();

      return;
    }

    if (passwordController.text.length < 6) {

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.warning,

        title: 'Contraseña inválida',

        desc:
        'La contraseña debe tener mínimo 6 caracteres',

        btnOkOnPress: () {},
      ).show();

      return;
    }

    setState(() {

      cargando = true;
    });

    try {

      UserCredential userCredential =

      await auth
          .createUserWithEmailAndPassword(

        email:
        correoController.text.trim(),

        password:
        passwordController.text.trim(),
      );

      final uid =
          userCredential.user!.uid;

      await database
          .child('usuarios')
          .child(uid)
          .set({

        'nombre':
        nombreController.text.trim(),

        'telefono':
        telefonoController.text.trim(),

        'correo':
        correoController.text.trim(),

        'rol':
        'cliente',
      });

      if (!mounted) return;

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.success,

        title: 'Cuenta creada',

        desc:
        'Cliente registrado correctamente 💖',

        btnOkOnPress: () {

          Navigator.pushReplacement(

            context,

            PageTransitionAnimation
                .crearTransicion(

              const DashboardClienteScreen(),
            ),
          );
        },
      ).show();

    } on FirebaseAuthException
    catch (e) {

      String mensaje =
          'Ocurrió un error';

      if (e.code ==
          'email-already-in-use') {

        mensaje =
        'Ese correo ya está registrado';
      }

      if (e.code ==
          'invalid-email') {

        mensaje =
        'Correo inválido';
      }

      if (e.code ==
          'weak-password') {

        mensaje =
        'Contraseña demasiado débil';
      }

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.error,

        title: 'Error',

        desc: mensaje,

        btnOkOnPress: () {},
      ).show();

    } catch (e) {

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.error,

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

      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
            const EdgeInsets.all(25),

            child: Column(

              children: [

                const Icon(

                  Icons.favorite,

                  size: 90,

                  color:
                  Color(0xFFD9A5B3),
                ),

                const SizedBox(height: 20),

                const Text(

                  'Koko Studio',

                  style: TextStyle(

                    fontSize: 34,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(

                  'Registro de Clientes 💖',

                  style: TextStyle(

                    fontSize: 18,

                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 40),

                campoTexto(

                  controller:
                  nombreController,

                  texto:
                  'Nombre completo',

                  icono:
                  Icons.person,
                ),

                const SizedBox(height: 20),

                campoTexto(

                  controller:
                  telefonoController,

                  texto:
                  'Teléfono',

                  icono:
                  Icons.phone,

                  tipo:
                  TextInputType.phone,
                ),

                const SizedBox(height: 20),

                campoTexto(

                  controller:
                  correoController,

                  texto:
                  'Correo electrónico',

                  icono:
                  Icons.email,

                  tipo:
                  TextInputType.emailAddress,
                ),

                const SizedBox(height: 20),

                TextField(

                  controller:
                  passwordController,

                  obscureText:
                  ocultarPassword,

                  decoration:
                  InputDecoration(

                    hintText:
                    'Contraseña',

                    prefixIcon:
                    const Icon(
                      Icons.lock,
                    ),

                    suffixIcon:
                    IconButton(

                      onPressed: () {

                        setState(() {

                          ocultarPassword =
                          !ocultarPassword;
                        });
                      },

                      icon: Icon(

                        ocultarPassword

                            ? Icons.visibility

                            : Icons.visibility_off,
                      ),
                    ),

                    filled: true,

                    fillColor:
                    Theme.of(context)
                        .cardColor,

                    border:
                    OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(
                          15),

                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    onPressed:
                    cargando
                        ? null
                        : registrarCliente,

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      const Color(0xFFD9A5B3),

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(
                            15),
                      ),
                    ),

                    child: cargando

                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )

                        : const Text(

                      'Crear Cuenta',

                      style: TextStyle(

                        color: Colors.white,

                        fontWeight:
                        FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(

                  'Al registrarte podrás reservar citas y servicios ✨',

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(

                    color: Colors.grey,

                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget campoTexto({

    required TextEditingController
    controller,

    required String texto,

    required IconData icono,

    TextInputType tipo =
        TextInputType.text,

  }) {

    return TextField(

      controller:
      controller,

      keyboardType:
      tipo,

      decoration:
      InputDecoration(

        hintText:
        texto,

        prefixIcon:
        Icon(icono),

        filled: true,

        fillColor:
        Theme.of(context)
            .cardColor,

        border:
        OutlineInputBorder(

          borderRadius:
          BorderRadius.circular(
              15),

          borderSide:
          BorderSide.none,
        ),
      ),
    );
  }
}