import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_database_shim.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'login_cliente_screen.dart';

class ProfileClienteScreen
    extends StatefulWidget {

  const ProfileClienteScreen({
    super.key,
  });

  @override
  State<ProfileClienteScreen>
  createState() =>
      _ProfileClienteScreenState();
}

class _ProfileClienteScreenState
    extends State<ProfileClienteScreen> {

  final usuario =
      FirebaseAuth.instance.currentUser;

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final FirebaseAuth auth =
      FirebaseAuth.instance;

  final TextEditingController
  nombreController =
  TextEditingController();

  final TextEditingController
  telefonoController =
  TextEditingController();

  final TextEditingController
  correoController =
  TextEditingController();

  bool cargando = true;

  @override
  void initState() {

    super.initState();

    cargarDatos();
  }

  Future<void>
  cargarDatos() async {

    try {

      final uid =
          usuario?.uid;

      if (uid == null) return;

      final snapshot =

      await database
          .child('usuarios')
          .child(uid)
          .get();

      if (snapshot.exists) {

        Map datos =
        snapshot.value as Map;

        nombreController.text =
            datos['nombre'] ?? '';

        telefonoController.text =
            datos['telefono'] ?? '';

        correoController.text =
            datos['correo'] ?? '';
      }

    } catch (e) {

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.error,

        title: 'Error',

        desc:
        'No se pudo cargar el perfil',

        btnOkOnPress: () {},
      ).show();
    }

    setState(() {

      cargando = false;
    });
  }

  Future<void>
  guardarCambios() async {

    try {

      final uid =
          usuario?.uid;

      if (uid == null) return;

      await database
          .child('usuarios')
          .child(uid)
          .update({

        'nombre':
        nombreController.text.trim(),

        'telefono':
        telefonoController.text.trim(),
      });

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.success,

        title: 'Actualizado',

        desc:
        'Perfil actualizado correctamente ',

        btnOkOnPress: () {},
      ).show();

    } catch (e) {

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.error,

        title: 'Error',

        desc:
        'No se pudo actualizar el perfil',

        btnOkOnPress: () {},
      ).show();
    }
  }

  Future<void>
  cerrarSesion() async {

    await auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder:
            (_) =>
        const LoginClienteScreen(),
      ),

          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,

      appBar: AppBar(

        elevation: 0,

        centerTitle: true,

        title: const Text(

          'Mi Perfil',

          style: TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: cargando

          ? const Center(

        child:
        CircularProgressIndicator(),
      )

          : SafeArea(

        child: SingleChildScrollView(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            children: [

              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(30),

                decoration:
                BoxDecoration(

                  gradient:
                  const LinearGradient(

                    colors: [

                      Color(0xFFD9A5B3),

                      Color(0xFFEFC3CF),
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(
                      30),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.pink
                          .withOpacity(
                          0.15),

                      blurRadius: 15,

                      offset:
                      const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(

                  children: [

                    CircleAvatar(

                      radius: 50,

                      backgroundColor:
                      Colors.white,

                      child: Text(

                        nombreController
                            .text
                            .isNotEmpty

                            ? nombreController
                            .text
                            .substring(0, 1)
                            .toUpperCase()

                            : 'C',

                        style:
                        const TextStyle(

                          fontSize: 40,

                          fontWeight:
                          FontWeight.bold,

                          color:
                          Color(0xFFD9A5B3),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: 20),

                    Text(

                      nombreController
                          .text,

                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize: 28,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 8),

                    Text(

                      correoController
                          .text,

                      style:
                      const TextStyle(

                        color:
                        Colors.white70,

                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

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

              TextField(

                controller:
                correoController,

                enabled: false,

                decoration:
                InputDecoration(

                  hintText:
                  'Correo electrónico',

                  prefixIcon:
                  const Icon(
                    Icons.email,
                  ),

                  filled: true,

                  fillColor:
                  Colors.grey.shade200,

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

                child: ElevatedButton.icon(

                  onPressed:
                  guardarCambios,

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(
                        0xFFD9A5B3),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                          15),
                    ),
                  ),

                  icon: const Icon(

                    Icons.save,

                    color:
                    Colors.white,
                  ),

                  label: const Text(

                    'Guardar Cambios',

                    style: TextStyle(

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton.icon(

                  onPressed:
                  cerrarSesion,

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.red,

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(
                          15),
                    ),
                  ),

                  icon: const Icon(

                    Icons.logout,

                    color:
                    Colors.white,
                  ),

                  label: const Text(

                    'Cerrar Sesión',

                    style: TextStyle(

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(
                    25),

                decoration:
                BoxDecoration(

                  color:
                  Theme.of(context)
                      .cardColor,

                  borderRadius:
                  BorderRadius.circular(
                      25),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black
                          .withOpacity(
                          0.05),

                      blurRadius: 10,

                      offset:
                      const Offset(0, 4),
                    ),
                  ],
                ),

                child: const Column(

                  children: [

                    Icon(

                      Icons.favorite,

                      color:
                      Colors.pink,

                      size: 45,
                    ),

                    SizedBox(height: 15),

                    Text(

                      'Koko Studio ',

                      style: TextStyle(

                        fontSize: 26,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(

                      'Gracias por formar parte de nuestra familia ',

                      textAlign:
                      TextAlign.center,

                      style: TextStyle(

                        fontSize: 16,

                        color:
                        Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

