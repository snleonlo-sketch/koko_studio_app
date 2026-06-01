import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'pagos_screen.dart';

class ReservarCitaScreen
    extends StatefulWidget {

  const ReservarCitaScreen({
    super.key,
  });

  @override
  State<ReservarCitaScreen>
  createState() =>
      _ReservarCitaScreenState();
}

class _ReservarCitaScreenState
    extends State<ReservarCitaScreen> {

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final usuario =
      FirebaseAuth.instance.currentUser;

  final TextEditingController
  fechaController =
  TextEditingController();

  final TextEditingController
  horaController =
  TextEditingController();

  String nombreCliente = '';

  String telefonoCliente = '';

  String? servicioSeleccionado;

  String? trabajadoraSeleccionada;

  String precioServicio = '';

  bool cargando = false;

  List<Map<String, dynamic>>
  servicios = [];

  List<Map<String, dynamic>>
  trabajadoras = [];

  @override
  void initState() {

    super.initState();

    cargarDatos();
  }

  Future<void>
  cargarDatos() async {

    final uid =
        usuario?.uid;

    if (uid == null) return;

    final clienteSnapshot =

    await database
        .child('usuarios')
        .child(uid)
        .get();

    if (clienteSnapshot.exists) {

      Map datos =
      clienteSnapshot.value as Map;

      nombreCliente =
          datos['nombre'] ?? '';

      telefonoCliente =
          datos['telefono'] ?? '';
    }

    // SERVICIOS

    database
        .child('servicios')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      servicios.clear();

      if (data != null) {

        Map serviciosMap =
        data as Map;

        serviciosMap.forEach((key, value) {

          servicios.add({

            'id': key,

            'nombre':
            value['nombre'],

            'precio':
            value['precio'],

            'descripcion':
            value['descripcion'],

            'duracion':
            value['duracion'],

            'imagen':
            value['imagen'],
          });
        });
      }

      setState(() {});
    });

    // TRABAJADORAS

    database
        .child('trabajadoras')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      trabajadoras.clear();

      if (data != null) {

        Map trabajadorasMap =
        data as Map;

        trabajadorasMap.forEach((key, value) {

          trabajadoras.add({

            'id': key,

            'nombre':
            value['nombre'],

            'horaEntrada':
            value['horaEntrada'],

            'horaSalida':
            value['horaSalida'],
          });
        });
      }

      setState(() {});
    });

    setState(() {});
  }

  Future<void>
  seleccionarFecha() async {

    DateTime? fecha =

    await showDatePicker(

      context: context,

      initialDate:
      DateTime.now(),

      firstDate:
      DateTime.now(),

      lastDate:
      DateTime(2035),
    );

    if (fecha != null) {

      fechaController.text =

      '${fecha.day}/'
          '${fecha.month}/'
          '${fecha.year}';
    }
  }

  Future<void>
  seleccionarHora() async {

    TimeOfDay? hora =

    await showTimePicker(

      context: context,

      initialTime:
      TimeOfDay.now(),
    );

    if (hora != null) {

      horaController.text =
          hora.format(context);
    }
  }

  Future<void>
  reservarCita() async {

    if (servicioSeleccionado == null ||
        trabajadoraSeleccionada == null ||
        fechaController.text.isEmpty ||
        horaController.text.isEmpty) {

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
          .child('citas')
          .push()
          .key!;

      await database
          .child('citas')
          .child(id)
          .set({

        'clienteUid':
        usuario?.uid,

        'cliente':
        nombreCliente,

        'telefono':
        telefonoCliente,

        'servicio':
        servicioSeleccionado,

        'trabajadora':
        trabajadoraSeleccionada,

        'fecha':
        fechaController.text,

        'hora':
        horaController.text,

        'precio':
        precioServicio,

        'estado':
        'pendiente',
      });

      await database
          .child('notificaciones')
          .push()
          .set({

        'trabajadora':
        trabajadoraSeleccionada,

        'mensaje':

        '$nombreCliente '
            'solicitó una cita '
            'para el '
            '$servicioSeleccionado',

        'fecha':
        DateTime.now()
            .toString(),

        'leido':
        false,
      });

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.success,

        title: 'Cita Solicitada',

        desc:
        'La trabajadora deberá confirmar tu cita 💖',

        btnOkOnPress: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
              const PagosScreen(),
            ),
          );
        },
      ).show();

      limpiarCampos();

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

  void limpiarCampos() {

    servicioSeleccionado = null;

    trabajadoraSeleccionada = null;

    fechaController.clear();

    horaController.clear();

    precioServicio = '';

    setState(() {});
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

          'Reservar Cita',

          style: TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(

                value:
                servicioSeleccionado,

                decoration:
                decoracionInput(

                  'Seleccionar servicio',

                  Icons.design_services,
                ),

                items:
                servicios.map<DropdownMenuItem<String>>((
                    servicio) {

                  return DropdownMenuItem<String>(

                    value:
                    servicio['nombre']
                        .toString(),

                    child: Text(

                      '${servicio['nombre']} '
                          '- S/ ${servicio['precio']}',
                    ),
                  );
                }).toList(),

                onChanged: (value) {

                  servicioSeleccionado =
                      value;

                  final servicio =

                  servicios.firstWhere(

                        (element) =>

                    element['nombre']
                        == value,
                  );

                  precioServicio =
                      servicio['precio']
                          .toString();

                  setState(() {});
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(

                value:
                trabajadoraSeleccionada,

                decoration:
                decoracionInput(

                  'Seleccionar trabajadora',

                  Icons.groups,
                ),

                items:
                trabajadoras.map<DropdownMenuItem<String>>((
                    trabajadora) {

                  return DropdownMenuItem<String>(

                    value:
                    trabajadora['nombre']
                        .toString(),

                    child: Text(

                      '${trabajadora['nombre']} '
                          '(${trabajadora['horaEntrada']} - '
                          '${trabajadora['horaSalida']})',
                    ),
                  );
                }).toList(),

                onChanged: (value) {

                  trabajadoraSeleccionada =
                      value;

                  setState(() {});
                },
              ),

              const SizedBox(height: 20),

              GestureDetector(

                onTap:
                seleccionarFecha,

                child: AbsorbPointer(

                  child: TextField(

                    controller:
                    fechaController,

                    decoration:
                    decoracionInput(

                      'Fecha',

                      Icons.calendar_month,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(

                onTap:
                seleccionarHora,

                child: AbsorbPointer(

                  child: TextField(

                    controller:
                    horaController,

                    decoration:
                    decoracionInput(

                      'Hora',

                      Icons.access_time,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              if (precioServicio
                  .isNotEmpty)

                Container(

                  width:
                  double.infinity,

                  padding:
                  const EdgeInsets.all(20),

                  decoration:
                  BoxDecoration(

                    color:
                    Theme.of(context)
                        .cardColor,

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Text(

                    'Precio: S/ $precioServicio',

                    style: const TextStyle(

                      fontSize: 22,

                      fontWeight:
                      FontWeight.bold,

                      color:
                      Colors.green,
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
                      : reservarCita,

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    const Color(0xFFD9A5B3),

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),

                  child: cargando

                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )

                      : const Text(

                    'Solicitar Cita',

                    style: TextStyle(

                      color: Colors.white,

                      fontWeight:
                      FontWeight.bold,

                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration decoracionInput(

      String texto,
      IconData icono,

      ) {

    return InputDecoration(

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
    );
  }
}