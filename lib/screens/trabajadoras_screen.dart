import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class TrabajadorasScreen
    extends StatefulWidget {

  const TrabajadorasScreen({
    super.key,
  });

  @override
  State<TrabajadorasScreen>
  createState() =>
      _TrabajadorasScreenState();
}

class _TrabajadorasScreenState
    extends State<TrabajadorasScreen> {

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final TextEditingController
  nombreController =
  TextEditingController();

  final TextEditingController
  correoController =
  TextEditingController();

  final TextEditingController
  passwordController =
  TextEditingController();

  final TextEditingController
  telefonoController =
  TextEditingController();

  final TextEditingController
  horaEntradaController =
  TextEditingController();

  final TextEditingController
  horaSalidaController =
  TextEditingController();

  bool cargando = false;

  Future<void>
  seleccionarHora(

      TextEditingController controller,

      ) async {

    TimeOfDay? hora =

    await showTimePicker(

      context: context,

      initialTime:
      TimeOfDay.now(),
    );

    if (hora != null) {

      controller.text =
          hora.format(context);
    }
  }

  Future<void>
  guardarTrabajadora() async {

    if (nombreController.text.isEmpty ||
        correoController.text.isEmpty ||
        passwordController.text.isEmpty ||
        telefonoController.text.isEmpty ||
        horaEntradaController.text.isEmpty ||
        horaSalidaController.text.isEmpty) {

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

    setState(() {

      cargando = true;
    });

    try {

      String id =

      database
          .child('trabajadoras')
          .push()
          .key!;

      await database
          .child('trabajadoras')
          .child(id)
          .set({

        'nombre':
        nombreController.text,

        'correo':
        correoController.text,

        'password':
        passwordController.text,

        'telefono':
        telefonoController.text,

        'horaEntrada':
        horaEntradaController.text,

        'horaSalida':
        horaSalidaController.text,
      });

      limpiarCampos();

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.success,

        title: 'Éxito',

        desc:
        'Trabajadora registrada correctamente',

        btnOkOnPress: () {},
      ).show();

    } catch (e) {

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.error,

        title: 'Error',

        desc: '$e',

        btnOkOnPress: () {},
      ).show();
    }

    setState(() {

      cargando = false;
    });
  }

  void limpiarCampos() {

    nombreController.clear();

    correoController.clear();

    passwordController.clear();

    telefonoController.clear();

    horaEntradaController.clear();

    horaSalidaController.clear();

    setState(() {});
  }

  Future<void>
  eliminarTrabajadora(
      String id) async {

    await database
        .child('trabajadoras')
        .child(id)
        .remove();

    AwesomeDialog(

      context: context,

      dialogType:
      DialogType.success,

      title: 'Eliminada',

      desc:
      'Trabajadora eliminada correctamente',

      btnOkOnPress: () {},
    ).show();
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

          'Trabajadoras',

          style: TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child: Padding(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(25),

                decoration: BoxDecoration(

                  gradient:
                  const LinearGradient(

                    colors: [

                      Color(0xFFD9A5B3),

                      Color(0xFFEFC3CF),
                    ],
                  ),

                  borderRadius:
                  BorderRadius.circular(30),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.pink
                          .withOpacity(0.15),

                      blurRadius: 15,

                      offset:
                      const Offset(0, 8),
                    ),
                  ],
                ),

                child: const Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    Text(

                      'Gestión de Trabajadoras 💖',

                      style: TextStyle(

                        color:
                        Colors.white,

                        fontSize: 28,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(

                      'Administra las trabajadoras del sistema.',

                      style: TextStyle(

                        color:
                        Colors.white70,

                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Expanded(

                child: SingleChildScrollView(

                  child: Column(

                    children: [

                      campoTexto(

                        nombreController,

                        'Nombre Completo',

                        Icons.person,
                      ),

                      const SizedBox(height: 15),

                      campoTexto(

                        correoController,

                        'Correo Electrónico',

                        Icons.email,
                      ),

                      const SizedBox(height: 15),

                      campoTexto(

                        passwordController,

                        'Contraseña',

                        Icons.lock,

                        oculto: true,
                      ),

                      const SizedBox(height: 15),

                      campoTexto(

                        telefonoController,

                        'Teléfono',

                        Icons.phone,
                      ),

                      const SizedBox(height: 15),

                      GestureDetector(

                        onTap: () {

                          seleccionarHora(
                            horaEntradaController,
                          );
                        },

                        child: AbsorbPointer(

                          child: campoTexto(

                            horaEntradaController,

                            'Hora Entrada',

                            Icons.access_time,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      GestureDetector(

                        onTap: () {

                          seleccionarHora(
                            horaSalidaController,
                          );
                        },

                        child: AbsorbPointer(

                          child: campoTexto(

                            horaSalidaController,

                            'Hora Salida',

                            Icons.access_time_filled,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(

                        width: double.infinity,

                        height: 55,

                        child: ElevatedButton(

                          onPressed:
                          cargando
                              ? null
                              : guardarTrabajadora,

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

                            'Guardar Trabajadora',

                            style: TextStyle(

                              color: Colors.white,

                              fontWeight:
                              FontWeight.bold,

                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Align(

                        alignment:
                        Alignment.centerLeft,

                        child: Text(

                          'Lista de Trabajadoras',

                          style: TextStyle(

                            fontSize: 24,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      StreamBuilder(

                        stream:
                        database
                            .child('trabajadoras')
                            .onValue,

                        builder:
                            (context, snapshot) {

                          if (!snapshot.hasData) {

                            return const Center(

                              child:
                              CircularProgressIndicator(),
                            );
                          }

                          final data =
                              snapshot.data!
                                  .snapshot
                                  .value;

                          if (data == null) {

                            return Container(

                              width:
                              double.infinity,

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
                                    20),
                              ),

                              child: const Center(

                                child: Text(

                                  'No hay trabajadoras registradas',

                                  style: TextStyle(

                                    color:
                                    Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          }

                          Map trabajadoras =
                          data as Map;

                          List items =
                          trabajadoras
                              .entries
                              .toList();

                          return ListView.builder(

                            shrinkWrap: true,

                            physics:
                            const NeverScrollableScrollPhysics(),

                            itemCount:
                            items.length,

                            itemBuilder:
                                (context, index) {

                              final id =
                                  items[index].key;

                              final trabajadora =
                                  items[index]
                                      .value;

                              return Container(

                                margin:
                                const EdgeInsets.only(
                                  bottom: 18,
                                ),

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
                                      const Offset(
                                          0,
                                          4),
                                    ),
                                  ],
                                ),

                                child: Padding(

                                  padding:
                                  const EdgeInsets.all(
                                      18),

                                  child: Row(

                                    children: [

                                      const CircleAvatar(

                                        radius: 30,

                                        backgroundColor:
                                        Color(0xFFD9A5B3),

                                        child: Icon(

                                          Icons.person,

                                          color:
                                          Colors.white,
                                        ),
                                      ),

                                      const SizedBox(
                                          width: 15),

                                      Expanded(

                                        child: Column(

                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                          children: [

                                            Text(

                                              trabajadora['nombre'],

                                              style:
                                              const TextStyle(

                                                fontSize:
                                                20,

                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),

                                            const SizedBox(
                                                height:
                                                5),

                                            Text(
                                              trabajadora['correo'],
                                            ),

                                            Text(
                                              '📞 ${trabajadora['telefono']}',
                                            ),

                                            Text(
                                              '🕐 ${trabajadora['horaEntrada']} - ${trabajadora['horaSalida']}',
                                            ),
                                          ],
                                        ),
                                      ),

                                      IconButton(

                                        onPressed: () {

                                          eliminarTrabajadora(
                                            id,
                                          );
                                        },

                                        icon: const Icon(

                                          Icons.delete,

                                          color:
                                          Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campoTexto(

      TextEditingController controller,
      String texto,
      IconData icono, {

        bool oculto = false,

      }) {

    return TextField(

      controller:
      controller,

      obscureText:
      oculto,

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
          BorderRadius.circular(15),

          borderSide:
          BorderSide.none,
        ),
      ),
    );
  }
}