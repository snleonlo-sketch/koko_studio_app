import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../services/pdf_service.dart';
import '../services/role_service.dart';

import 'calendario_dia_screen.dart';
import 'citas_dia_screen.dart';

class CalendarioScreen
    extends StatefulWidget {

  const CalendarioScreen({
    super.key,
  });

  @override
  State<CalendarioScreen>
  createState() =>
      _CalendarioScreenState();
}

class _CalendarioScreenState
    extends State<CalendarioScreen> {

  final DatabaseReference citasRef =
  FirebaseDatabase.instance
      .ref()
      .child('citas');

  final RoleService roleService =
      RoleService();

  DateTime diaSeleccionado =
  DateTime.now();

  DateTime diaEnfocado =
  DateTime.now();

  List<Map> citasDelDia = [];

  Map<DateTime, List<Map>>
  eventos = {};

  bool cargando = true;

  String rolUsuario = '';

  String nombreUsuario = '';

  String sedeUsuario = '';

  @override
  void initState() {

    super.initState();

    iniciarCalendario();
  }

  Future<void>
  iniciarCalendario() async {

    await initializeDateFormatting(
      'es_ES',
      null,
    );

    final datos =
    await roleService.obtenerDatosUsuario();

    rolUsuario =
        (datos['rol'] ?? '').toString();

    nombreUsuario =
        (datos['nombre'] ?? '').toString();

    sedeUsuario =
        (datos['sede'] ?? '').toString();

    cargarCitas();
  }

  void cargarCitas() {

    citasRef.onValue.listen((event) {

      final data =
          event.snapshot.value;

      eventos.clear();

      if (data != null) {

        Map citas =
        data as Map;

        citas.forEach((key, value) {

          try {

            String fecha =
            value['fecha'];

            final sedeCita =
                (value['sede'] ?? '').toString();

            final trabajadoraCita =
                (value['trabajadora'] ?? '').toString();

            if (rolUsuario != 'admin' &&
                sedeUsuario.isNotEmpty &&
                sedeCita.isNotEmpty &&
                sedeCita != sedeUsuario) {

              return;
            }

            if (rolUsuario == 'trabajadora' &&
                trabajadoraCita.toLowerCase() !=
                    nombreUsuario.toLowerCase()) {

              return;
            }

            List partes =
            fecha.split('/');

            DateTime fechaCita =

            DateTime(

              int.parse(partes[2]),

              int.parse(partes[1]),

              int.parse(partes[0]),
            );

            final fechaNormalizada =

            DateTime(

              fechaCita.year,

              fechaCita.month,

              fechaCita.day,
            );

            eventos.putIfAbsent(
              fechaNormalizada,
                  () => [],
            );

            eventos[fechaNormalizada]!
                .add({

              'id': key,

              'cliente':
              value['cliente'] ?? '',

              'telefono':
              value['telefono'] ?? '',

              'servicio':
              value['servicio'] ?? '',

              'trabajadora':
              value['trabajadora'] ?? '',

              'hora':
              value['hora'] ?? '',

              'precio':
              value['precio'] ?? '',

              'fecha':
              value['fecha'] ?? '',

              'estado':
              value['estado'] ??
                  'pendiente',
            });

          } catch (e) {

            debugPrint(
              'Error cita: $e',
            );
          }
        });
      }

      cargarEventosDelDia(
        diaSeleccionado,
      );

      setState(() {

        cargando = false;
      });
    });
  }

  void cargarEventosDelDia(
      DateTime fecha) {

    final fechaNormalizada =

    DateTime(

      fecha.year,

      fecha.month,

      fecha.day,
    );

    setState(() {

      citasDelDia =

          eventos[
          fechaNormalizada] ??

              [];
    });
  }

  String textoFecha(DateTime fecha) {

    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  Future<void>
  actualizarEstado(

      String id,
      String estado,

      ) async {

    await citasRef
        .child(id)
        .update({

      'estado':
      estado,
    });

    AwesomeDialog(

      context: context,

      dialogType:
      DialogType.success,

      title: 'Actualizado',

      desc:
      'Estado actualizado correctamente',

      btnOkOnPress: () {},
    ).show();
  }

  Future<void>
  eliminarCita(
      String id) async {

    await citasRef
        .child(id)
        .remove();

    AwesomeDialog(

      context: context,

      dialogType:
      DialogType.success,

      title: 'Eliminada',

      desc:
      'Cita eliminada correctamente',

      btnOkOnPress: () {},
    ).show();
  }

  Future<void>
  enviarWhatsApp(

      String telefono,
      String cliente,
      String fecha,
      String hora,
      String servicio,

      ) async {

    String numero =

    telefono.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (!numero.startsWith('51')) {

      numero = '51$numero';
    }

    String mensaje =

        'Hola $cliente 💖\n\n'

        'Te recordamos tu cita en '
        'Koko Studio ✨\n\n'

        '📅 Fecha: $fecha\n'
        '⏰ Hora: $hora\n'
        '💅 Servicio: $servicio\n\n'

        'Te esperamos 💕';

    final Uri uri = Uri.parse(

      'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}',
    );

    await launchUrl(

      uri,

      mode:
      LaunchMode.externalApplication,
    );
  }

  Future<void>
  generarPDF(Map cita) async {

    final pdf =

    await PdfService
        .generarBoleta(

      cliente:
      cita['cliente'],

      servicio:
      cita['servicio'],

      fecha:
      cita['fecha'],

      hora:
      cita['hora'],

      precio:
      cita['precio'],
    );

    await Printing.layoutPdf(

      onLayout: (format) async => pdf,
    );
  }

  Color colorEstado(
      String estado) {

    switch (
    estado.toLowerCase()) {

      case 'confirmada':
        return Colors.blue;

      case 'finalizada':
        return Colors.green;

      case 'cancelada':
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  IconData iconoEstado(
      String estado) {

    switch (
    estado.toLowerCase()) {

      case 'confirmada':
        return Icons.check_circle;

      case 'finalizada':
        return Icons.done_all;

      case 'cancelada':
        return Icons.cancel;

      default:
        return Icons.access_time;
    }
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

          'Calendario de Citas',

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

          child: Padding(

            padding:
            const EdgeInsets.all(15),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Container(

                  decoration: BoxDecoration(

                    color:
                    Theme.of(context)
                        .cardColor,

                    borderRadius:
                    BorderRadius.circular(25),

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

                  child: TableCalendar(

                    locale: 'es_ES',

                    firstDay:
                    DateTime(2024),

                    lastDay:
                    DateTime(2035),

                    focusedDay:
                    diaEnfocado,

                    selectedDayPredicate:
                        (day) {

                      return isSameDay(

                        diaSeleccionado,

                        day,
                      );
                    },

                    eventLoader:
                        (day) {

                      return eventos[

                      DateTime(

                        day.year,

                        day.month,

                        day.day,
                      )

                      ] ??
                          [];
                    },

                    onDaySelected:
                        (selectedDay,
                        focusedDay) {

                      setState(() {

                        diaSeleccionado =
                            selectedDay;

                        diaEnfocado =
                            focusedDay;
                      });

                      cargarEventosDelDia(
                        selectedDay,
                      );

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (context) =>
                          rolUsuario == 'trabajadora'
                              ? CitasDiaScreen(
                                  fecha:
                                  textoFecha(selectedDay),
                                )
                              : CalendarioDiaScreen(
                            fecha:
                            textoFecha(selectedDay),
                          ),
                        ),
                      );
                    },

                    calendarStyle:
                    CalendarStyle(

                      todayDecoration:
                      const BoxDecoration(

                        color:
                        Colors.purple,

                        shape:
                        BoxShape.circle,
                      ),

                      selectedDecoration:
                      const BoxDecoration(

                        color:
                        Color(0xFFD9A5B3),

                        shape:
                        BoxShape.circle,
                      ),

                      markerDecoration:
                      const BoxDecoration(

                        color:
                        Colors.green,

                        shape:
                        BoxShape.circle,
                      ),
                    ),

                    headerStyle:
                    const HeaderStyle(

                      formatButtonVisible:
                      false,

                      titleCentered:
                      true,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Container(

                  width:
                  double.infinity,

                  padding:
                  const EdgeInsets.all(22),

                  decoration:
                  BoxDecoration(

                    color:
                    Theme.of(context)
                        .cardColor,

                    borderRadius:
                    BorderRadius.circular(22),

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

                      const Text(

                        'Revisar agenda del dia',

                        style: TextStyle(

                          fontSize: 20,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(

                        'Toca una fecha del calendario para ver franjas horarias y citas de ese dia.',

                        style: TextStyle(

                          color:
                          Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(

                        width:
                        double.infinity,

                        child: ElevatedButton.icon(

                          onPressed: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (context) =>
                                rolUsuario == 'trabajadora'
                                    ? CitasDiaScreen(
                                        fecha:
                                        textoFecha(diaSeleccionado),
                                      )
                                    : CalendarioDiaScreen(

                                  fecha:
                                  textoFecha(diaSeleccionado),
                                ),
                              ),
                            );
                          },

                          icon:
                          const Icon(Icons.open_in_new),

                          label:
                          const Text('Abrir dia seleccionado'),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
