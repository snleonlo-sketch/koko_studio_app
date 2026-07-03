import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../utils/koko_config.dart';

class ServiciosScreen
    extends StatefulWidget {

  const ServiciosScreen({
    super.key,
  });

  @override
  State<ServiciosScreen>
  createState() =>
      _ServiciosScreenState();
}

class _ServiciosScreenState
    extends State<ServiciosScreen> {

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  bool cargando = false;

  String sedeSeleccionada =
      KokoConfig.sedes.first;

  final TextEditingController
  nombreController =
  TextEditingController();

  final TextEditingController
  precioController =
  TextEditingController();

  final TextEditingController
  descripcionController =
  TextEditingController();

  final TextEditingController
  duracionController =
  TextEditingController();

  Future<void>
  guardarServicio() async {

    if (nombreController.text.isEmpty ||
        descripcionController.text.isEmpty ||
        duracionController.text.isEmpty) {

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
          .child('servicios')
          .push()
          .key!;

      await database
          .child('servicios')
          .child(id)
          .set({

        'nombre':
        nombreController.text,

        'precio':
        precioController.text.trim(),

        'descripcion':
        descripcionController.text,

        'duracion':
        duracionController.text,

        'sede':
        sedeSeleccionada,

        'imagen':
        '',
      });

      limpiarCampos();

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.success,

        title: 'Éxito',

        desc:
        'Servicio agregado correctamente',

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

    precioController.clear();

    descripcionController.clear();

    duracionController.clear();

    sedeSeleccionada =
        KokoConfig.sedes.first;

    setState(() {});
  }

  Future<void>
  eliminarServicio(
      String id) async {

    await database
        .child('servicios')
        .child(id)
        .remove();

    AwesomeDialog(

      context: context,

      dialogType:
      DialogType.success,

      title: 'Eliminado',

      desc:
      'Servicio eliminado correctamente',

      btnOkOnPress: () {},
    ).show();
  }

  Future<void>
  editarServicio(

      String id,
      Map servicio,

      ) async {

    final TextEditingController
    editarNombreController =

    TextEditingController(
      text: servicio['nombre'],
    );

    final TextEditingController
    editarPrecioController =

    TextEditingController(
      text: servicio['precio'],
    );

    final TextEditingController
    editarDescripcionController =

    TextEditingController(
      text: servicio['descripcion'],
    );

    final TextEditingController
    editarDuracionController =

    TextEditingController(
      text: servicio['duracion'],
    );

    showDialog(

      context: context,

      builder: (context) {

        return AlertDialog(

          shape: RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(20),
          ),

          title: const Text(
            'Editar Servicio',
          ),

          content: SingleChildScrollView(

            child: Column(

              mainAxisSize:
              MainAxisSize.min,

              children: [

                campoEditar(
                  editarNombreController,
                  'Nombre',
                ),

                const SizedBox(height: 15),

                campoEditar(
                  editarPrecioController,
                  'Precio referencial',
                ),

                const SizedBox(height: 15),

                campoEditar(
                  editarDescripcionController,
                  'Descripción',
                ),

                const SizedBox(height: 15),

                campoEditar(
                  editarDuracionController,
                  'Duración',
                ),
              ],
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);
              },

              child: const Text(
                'Cancelar',
              ),
            ),

            ElevatedButton(

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                const Color(0xFFD9A5B3),
              ),

              onPressed: () async {

                await database
                    .child('servicios')
                    .child(id)
                    .update({

                  'nombre':
                  editarNombreController.text,

                  'precio':
                  editarPrecioController.text.trim(),

                  'descripcion':
                  editarDescripcionController.text,

                  'duracion':
                  editarDuracionController.text,
                });

                Navigator.pop(context);

                AwesomeDialog(

                  context: context,

                  dialogType:
                  DialogType.success,

                  title: 'Actualizado',

                  desc:
                  'Servicio actualizado correctamente',

                  btnOkOnPress: () {},
                ).show();
              },

              child: const Text(

                'Guardar',

                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
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

          'Servicios',

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

                      'Gestión de Servicios 💖',

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

                      'Administra los servicios del negocio.',

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

                        'Nombre del servicio',

                        Icons.design_services,
                      ),

                      const SizedBox(height: 15),

                      campoTexto(

                        precioController,

                        'Precio referencial (opcional)',

                        Icons.attach_money,

                        tipo:
                        TextInputType.number,
                      ),

                      const SizedBox(height: 15),

                      campoTexto(

                        descripcionController,

                        'Descripción',

                        Icons.description,
                      ),

                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(

                        value:
                        sedeSeleccionada,

                        decoration:
                        InputDecoration(

                          hintText:
                          'Sede',

                          prefixIcon:
                          const Icon(Icons.store),

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

                        items:
                        KokoConfig.sedes.map((sede) {

                          return DropdownMenuItem(

                            value:
                            sede,

                            child:
                            Text(sede),
                          );
                        }).toList(),

                        onChanged: (value) {

                          if (value == null) return;

                          setState(() {

                            sedeSeleccionada = value;
                          });
                        },
                      ),

                      const SizedBox(height: 15),

                      campoTexto(

                        duracionController,

                        'Duración',

                        Icons.timer,
                      ),

                      const SizedBox(height: 20),

                      SizedBox(

                        width: double.infinity,

                        height: 55,

                        child: ElevatedButton(

                          onPressed:
                          cargando
                              ? null
                              : guardarServicio,

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

                            'Guardar Servicio',

                            style: TextStyle(

                              color: Colors.white,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Align(

                        alignment:
                        Alignment.centerLeft,

                        child: Text(

                          'Lista de Servicios',

                          style: TextStyle(

                            fontSize: 24,

                            fontWeight:
                            FontWeight.bold,

                            color:
                            Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      StreamBuilder(

                        stream:
                        database
                            .child('servicios')
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

                            return mensajeVacio(
                              context,
                            );
                          }

                          Map servicios =
                          data as Map;

                          List items =
                          servicios
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

                              final item =
                              items[index];

                              final id =
                                  item.key;

                              final servicio =
                                  item.value;

                              return tarjetaServicio(

                                context,

                                id,

                                servicio,
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

  Widget tarjetaServicio(

      BuildContext context,

      String id,
      Map servicio,

      ) {

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
        BorderRadius.circular(25),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black
                .withOpacity(0.05),

            blurRadius: 10,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          if (servicio['imagen'] != null &&
              servicio['imagen'] != '')

            ClipRRect(

              borderRadius:
              const BorderRadius.only(

                topLeft:
                Radius.circular(25),

                topRight:
                Radius.circular(25),
              ),

              child: Image.network(

                servicio['imagen'],

                height: 190,

                width:
                double.infinity,

                fit:
                BoxFit.cover,
              ),
            ),

          Padding(

            padding:
            const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  servicio['nombre'],

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight:
                    FontWeight.bold,

                    color:
                    Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color,
                  ),
                ),

                const SizedBox(height: 10),

                Text(

                  'Sede: ${servicio['sede'] ?? 'No asignada'}',

                  style: const TextStyle(

                    fontSize: 15,

                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                if ((servicio['precio'] ?? '')
                    .toString()
                    .isNotEmpty) ...[

                  Text(

                    'Precio referencial: S/ ${servicio['precio']}',

                    style: const TextStyle(

                      fontSize: 16,

                      color:
                      Colors.green,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],

                Text(

                  '📝 ${servicio['descripcion']}',

                  style: const TextStyle(

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 10),

                Text(

                  '⏱ ${servicio['duracion']}',

                  style: const TextStyle(

                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 18),

                Row(

                  children: [

                    Expanded(

                      child:
                      ElevatedButton.icon(

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.blue,

                          shape:
                          RoundedRectangleBorder(

                            borderRadius:
                            BorderRadius.circular(
                                15),
                          ),
                        ),

                        onPressed: () {

                          editarServicio(
                            id,
                            servicio,
                          );
                        },

                        icon: const Icon(

                          Icons.edit,

                          color:
                          Colors.white,
                        ),

                        label: const Text(

                          'Editar',

                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(

                      child:
                      ElevatedButton.icon(

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

                        onPressed: () {

                          eliminarServicio(
                            id,
                          );
                        },

                        icon: const Icon(

                          Icons.delete,

                          color:
                          Colors.white,
                        ),

                        label: const Text(

                          'Eliminar',

                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget mensajeVacio(
      BuildContext context) {

    return Container(

      width:
      double.infinity,

      padding:
      const EdgeInsets.all(25),

      decoration:
      BoxDecoration(

        color:
        Theme.of(context)
            .cardColor,

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: const Center(

        child: Text(

          'No hay servicios registrados',

          style: TextStyle(

            fontSize: 16,

            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget campoTexto(

      TextEditingController controller,
      String texto,
      IconData icono, {

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
          BorderRadius.circular(15),

          borderSide:
          BorderSide.none,
        ),
      ),
    );
  }

  Widget campoEditar(

      TextEditingController controller,
      String texto,

      ) {

    return TextField(

      controller:
      controller,

      decoration:
      InputDecoration(

        hintText:
        texto,

        filled: true,

        fillColor:
        Colors.grey.shade100,

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
