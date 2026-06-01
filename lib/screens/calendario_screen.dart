import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../services/pdf_service.dart';

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

  DateTime diaSeleccionado =
  DateTime.now();

  DateTime diaEnfocado =
  DateTime.now();

  List<Map> citasDelDia = [];

  Map<DateTime, List<Map>>
  eventos = {};

  bool cargando = true;

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

                const Text(

                  'Citas del Día',

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                citasDelDia.isEmpty

                    ? Container(

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
                    BorderRadius.circular(
                        20),
                  ),

                  child: const Center(

                    child: Text(

                      'No hay citas para este día',

                      style: TextStyle(

                        fontSize: 16,

                        color:
                        Colors.grey,
                      ),
                    ),
                  ),
                )

                    : ListView.builder(

                  shrinkWrap: true,

                  physics:
                  const NeverScrollableScrollPhysics(),

                  itemCount:
                  citasDelDia.length,

                  itemBuilder:
                      (context, index) {

                    final cita =
                    citasDelDia[index];

                    return Container(

                      margin:
                      const EdgeInsets.only(
                        bottom: 18,
                      ),

                      padding:
                      const EdgeInsets.all(
                          18),

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

                            blurRadius: 8,

                            offset:
                            const Offset(
                                0,
                                4),
                          ),
                        ],
                      ),

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Row(

                            children: [

                              CircleAvatar(

                                radius: 28,

                                backgroundColor:
                                colorEstado(

                                  cita['estado'],
                                ),

                                child: Icon(

                                  iconoEstado(

                                    cita['estado'],
                                  ),

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

                                      cita['cliente'],

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
                                      cita['servicio'],
                                    ),

                                    Text(
                                      '👩 ${cita['trabajadora']}',
                                    ),
                                  ],
                                ),
                              ),

                              Container(

                                padding:
                                const EdgeInsets.symmetric(

                                  horizontal:
                                  12,

                                  vertical:
                                  8,
                                ),

                                decoration:
                                BoxDecoration(

                                  color:
                                  colorEstado(

                                    cita['estado'],
                                  ),

                                  borderRadius:
                                  BorderRadius.circular(
                                      20),
                                ),

                                child: Text(

                                  cita['estado']
                                      .toString()
                                      .toUpperCase(),

                                  style:
                                  const TextStyle(

                                    color:
                                    Colors.white,

                                    fontWeight:
                                    FontWeight.bold,

                                    fontSize:
                                    12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          Text(
                            '📅 ${cita['fecha']}',
                          ),

                          Text(
                            '⏰ ${cita['hora']}',
                          ),

                          Text(
                            '📞 ${cita['telefono']}',
                          ),

                          Text(
                            '💰 S/ ${cita['precio']}',
                          ),

                          const SizedBox(height: 18),

                          Wrap(

                            spacing: 10,

                            runSpacing: 10,

                            children: [

                              ElevatedButton.icon(

                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.blue,
                                ),

                                onPressed: () {

                                  actualizarEstado(

                                    cita['id'],

                                    'confirmada',
                                  );
                                },

                                icon: const Icon(

                                  Icons.check,

                                  color:
                                  Colors.white,
                                ),

                                label: const Text(

                                  'Confirmar',

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              ElevatedButton.icon(

                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.green,
                                ),

                                onPressed: () {

                                  actualizarEstado(

                                    cita['id'],

                                    'finalizada',
                                  );
                                },

                                icon: const Icon(

                                  Icons.done_all,

                                  color:
                                  Colors.white,
                                ),

                                label: const Text(

                                  'Finalizar',

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              ElevatedButton.icon(

                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.green.shade700,
                                ),

                                onPressed: () {

                                  enviarWhatsApp(

                                    cita['telefono'],

                                    cita['cliente'],

                                    cita['fecha'],

                                    cita['hora'],

                                    cita['servicio'],
                                  );
                                },

                                icon: const Icon(

                                  Icons.message,

                                  color:
                                  Colors.white,
                                ),

                                label: const Text(

                                  'WhatsApp',

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              ElevatedButton.icon(

                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.deepOrange,
                                ),

                                onPressed: () {

                                  generarPDF(cita);
                                },

                                icon: const Icon(

                                  Icons.picture_as_pdf,

                                  color:
                                  Colors.white,
                                ),

                                label: const Text(

                                  'PDF',

                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              ElevatedButton.icon(

                                style:
                                ElevatedButton.styleFrom(

                                  backgroundColor:
                                  Colors.red,
                                ),

                                onPressed: () {

                                  eliminarCita(
                                    cita['id'],
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
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}