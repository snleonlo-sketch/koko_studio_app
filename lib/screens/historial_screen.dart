import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/pdf_service.dart';
import '../services/excel_service.dart';

class HistorialScreen
    extends StatefulWidget {

  const HistorialScreen({
    super.key,
  });

  @override
  State<HistorialScreen> createState() =>
      _HistorialScreenState();
}

class _HistorialScreenState
    extends State<HistorialScreen> {

  final DatabaseReference citasRef =
  FirebaseDatabase.instance
      .ref()
      .child('citas');

  final TextEditingController
  buscarController =
  TextEditingController();

  String textoBusqueda = '';

  int totalPendientes = 0;

  int totalConfirmadas = 0;

  int totalFinalizadas = 0;

  int totalCanceladas = 0;

  double ingresos = 0;

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

  Future<void>
  cambiarEstado(

      String id,
      String estado,

      ) async {

    await citasRef
        .child(id)
        .update({

      'estado':
      estado,
    });
  }

  Future<void>
  eliminarCita(
      String id) async {

    await citasRef
        .child(id)
        .remove();
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

  Future<void>
  exportarExcel(
      List citasLista) async {

    List<Map<String, dynamic>>
    lista = [];

    for (var cita in citasLista) {

      lista.add({

        'cliente':
        cita['cliente'],

        'telefono':
        cita['telefono'],

        'servicio':
        cita['servicio'],

        'trabajadora':
        cita['trabajadora'],

        'fecha':
        cita['fecha'],

        'hora':
        cita['hora'],

        'precio':
        cita['precio'],

        'estado':
        cita['estado'],
      });
    }

    await ExcelService
        .exportarCitas(

      citas: lista,
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

          'Historial de Citas',

          style: TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder(

        stream:
        citasRef.onValue,

        builder:
            (context, snapshot) {

          if (snapshot.hasError) {

            return const Center(

              child:
              Text('Ocurrió un error'),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!
                  .snapshot
                  .value ==
                  null) {

            return const Center(

              child: Text(

                'No hay citas registradas',

                style: TextStyle(

                  fontSize: 18,

                  color:
                  Colors.grey,
                ),
              ),
            );
          }

          Map<dynamic, dynamic>
          citas =

          snapshot.data!
              .snapshot
              .value
          as Map<dynamic, dynamic>;

          List citasLista = [];

          totalPendientes = 0;

          totalConfirmadas = 0;

          totalFinalizadas = 0;

          totalCanceladas = 0;

          ingresos = 0;

          citas.forEach((key, value) {

            String estado =
                value['estado'] ??
                    'pendiente';

            if (estado ==
                'pendiente') {

              totalPendientes++;
            }

            if (estado ==
                'confirmada') {

              totalConfirmadas++;
            }

            if (estado ==
                'finalizada') {

              totalFinalizadas++;

              ingresos +=
                  double.tryParse(

                    value['precio']
                        .toString(),

                  ) ??
                      0;
            }

            if (estado ==
                'cancelada') {

              totalCanceladas++;
            }

            citasLista.add({

              'id': key,

              'cliente':
              value['cliente'] ??
                  '',

              'telefono':
              value['telefono'] ??
                  '',

              'servicio':
              value['servicio'] ??
                  '',

              'trabajadora':
              value['trabajadora'] ??
                  '',

              'fecha':
              value['fecha'] ??
                  '',

              'hora':
              value['hora'] ??
                  '',

              'estado':
              estado,

              'precio':
              value['precio']
                  .toString(),
            });
          });

          if (textoBusqueda
              .isNotEmpty) {

            citasLista =
                citasLista.where((cita) {

                  return cita['cliente']
                      .toString()
                      .toLowerCase()
                      .contains(

                    textoBusqueda
                        .toLowerCase(),
                  );
                }).toList();
          }

          return Column(

            children: [

              Padding(

                padding:
                const EdgeInsets.all(
                    15),

                child: Column(

                  children: [

                    TextField(

                      controller:
                      buscarController,

                      onChanged:
                          (value) {

                        setState(() {

                          textoBusqueda =
                              value;
                        });
                      },

                      decoration:
                      InputDecoration(

                        hintText:
                        'Buscar cliente',

                        prefixIcon:
                        const Icon(
                          Icons.search,
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

                    const SizedBox(
                        height: 20),

                    Row(

                      children: [

                        Expanded(

                          child:
                          tarjetaResumen(

                            'Pendientes',

                            totalPendientes
                                .toString(),

                            Colors.orange,
                          ),
                        ),

                        const SizedBox(
                            width: 10),

                        Expanded(

                          child:
                          tarjetaResumen(

                            'Confirmadas',

                            totalConfirmadas
                                .toString(),

                            Colors.blue,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 10),

                    Row(

                      children: [

                        Expanded(

                          child:
                          tarjetaResumen(

                            'Finalizadas',

                            totalFinalizadas
                                .toString(),

                            Colors.green,
                          ),
                        ),

                        const SizedBox(
                            width: 10),

                        Expanded(

                          child:
                          tarjetaResumen(

                            'Ingresos',

                            'S/ ${ingresos.toStringAsFixed(0)}',

                            Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                        height: 10),

                    SizedBox(

                      width:
                      double.infinity,

                      height: 55,

                      child:
                      ElevatedButton.icon(

                        onPressed: () {

                          exportarExcel(
                            citasLista,
                          );
                        },

                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.green,
                        ),

                        icon: const Icon(

                          Icons.table_chart,

                          color:
                          Colors.white,
                        ),

                        label: const Text(

                          'Exportar Excel',

                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(

                child: ListView.builder(

                  padding:
                  const EdgeInsets.all(
                      15),

                  itemCount:
                  citasLista.length,

                  itemBuilder:
                      (context, index) {

                    final cita =
                    citasLista[index];

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

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

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

                                          fontWeight:
                                          FontWeight.bold,

                                          fontSize:
                                          20,
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
                                        .toUpperCase(),

                                    style:
                                    const TextStyle(

                                      color:
                                      Colors.white,

                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                                height: 18),

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

                            const SizedBox(
                                height: 18),

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

                                    cambiarEstado(

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

                                    cambiarEstado(

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

                                    generarPDF(
                                      cita,
                                    );
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
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget tarjetaResumen(

      String titulo,
      String valor,
      Color color,

      ) {

    return Container(

      padding:
      const EdgeInsets.all(
          18),

      decoration:
      BoxDecoration(

        color: color,

        borderRadius:
        BorderRadius.circular(
            20),
      ),

      child: Column(

        children: [

          Text(

            valor,

            style: const TextStyle(

              color:
              Colors.white,

              fontSize: 22,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
              height: 5),

          Text(

            titulo,

            style: const TextStyle(

              color:
              Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}