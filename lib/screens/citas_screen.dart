import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';

import '../services/pdf_service.dart';
import '../services/notification_service.dart';
import '../services/role_service.dart';
import '../services/excel_service.dart';
import '../utils/koko_config.dart';

import 'pagos_screen.dart';

class CitasScreen extends StatefulWidget {

  const CitasScreen({
    super.key,
  });

  @override
  State<CitasScreen> createState() =>
      _CitasScreenState();
}

class _CitasScreenState
    extends State<CitasScreen> {

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final RoleService roleService =
  RoleService();

  final TextEditingController
  clienteController =
  TextEditingController();

  final TextEditingController
  telefonoController =
  TextEditingController();

  final TextEditingController
  fechaController =
  TextEditingController();

  final TextEditingController
  horaController =
  TextEditingController();

  final TextEditingController
  precioController =
  TextEditingController();

  final TextEditingController
  observacionesController =
  TextEditingController();

  final TextEditingController
  buscarController =
  TextEditingController();

  bool cargando = false;

  String textoBusqueda = '';

  String rolUsuario = '';

  String nombreUsuario = '';

  List<String> servicios = [];

  List<String> trabajadoras = [];

  String? servicioSeleccionado;

  String? trabajadoraSeleccionada;

  String sedeSeleccionada =
      KokoConfig.sedes.first;

  bool adelantoPagado = false;

  @override
  void initState() {

    super.initState();

    iniciarPantalla();
  }

  Future<void>
  iniciarPantalla() async {

    await cargarUsuario();

    cargarDatos();
  }

  Future<void>
  cargarUsuario() async {

    final datos =

    await roleService
        .obtenerDatosUsuario();

    rolUsuario =
        datos['rol'] ?? '';

    nombreUsuario =
        datos['nombre'] ?? '';

    setState(() {});
  }

  void cargarDatos() {

    database
        .child('servicios')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      if (data != null) {

        Map serviciosMap =
        data as Map;

        servicios =
            serviciosMap.values
                .map<String>((e) =>
                e['nombre'].toString())
                .toList();

        setState(() {});
      }
    });

    database
        .child('trabajadoras')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      if (data != null) {

        Map trabajadorasMap =
        data as Map;

        trabajadoras =
            trabajadorasMap.values
                .map<String>((e) =>
                e['nombre'].toString())
                .toList();

        setState(() {});
      }
    });
  }

  Future<void>
  seleccionarFecha() async {

    DateTime? fecha =

    await showDatePicker(

      context: context,

      initialDate:
      DateTime.now(),

      firstDate:
      DateTime(2024),

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
  guardarCita() async {

    if (clienteController.text.isEmpty ||
        telefonoController.text.isEmpty ||
        servicioSeleccionado == null ||
        trabajadoraSeleccionada == null ||
        fechaController.text.isEmpty ||
        horaController.text.isEmpty ||
        precioController.text.isEmpty) {

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

        'cliente':
        clienteController.text,

        'sede':
        sedeSeleccionada,

        'telefono':
        telefonoController.text,

        'servicio':
        servicioSeleccionado,

        'trabajadora':
        trabajadoraSeleccionada,

        'fecha':
        fechaController.text,

        'hora':
        horaController.text,

        'precio':
        precioController.text,

        'adelanto':
        '20',

        'adelantoPagado':
        adelantoPagado,

        'estadoPago':
        adelantoPagado
            ? 'adelanto pagado'
            : 'pendiente de adelanto',

        'observaciones':
        observacionesController.text.trim(),

        'estado':
        'pendiente',
      });

      await NotificationService
          .mostrarNotificacion(

        titulo:
        'Nueva cita 💖',

        mensaje:
        '${clienteController.text} registrada',
      );

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.success,

        title: 'Éxito',

        desc:
        'Cita registrada correctamente',

        btnOkOnPress: () {},
      ).show();

      limpiarCampos();

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

    clienteController.clear();

    telefonoController.clear();

    fechaController.clear();

    horaController.clear();

    precioController.clear();

    observacionesController.clear();

    servicioSeleccionado = null;

    trabajadoraSeleccionada = null;

    sedeSeleccionada =
        KokoConfig.sedes.first;

    adelantoPagado = false;

    setState(() {});
  }

  Future<void>
  eliminarCita(
      String id) async {

    await database
        .child('citas')
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
  actualizarEstado(

      String id,
      String estado,

      ) async {

    await database
        .child('citas')
        .child(id)
        .update({

      'estado':
      estado,
    });
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
  exportarExcel() async {

    final snapshot =

    await database
        .child('citas')
        .get();

    if (snapshot.exists) {

      Map citas =
      snapshot.value as Map;

      List<Map<String, dynamic>>
      lista = [];

      citas.forEach((key, value) {

        lista.add({

          'cliente':
          value['cliente'] ?? '',

          'sede':
          value['sede'] ?? '',

          'telefono':
          value['telefono'] ?? '',

          'servicio':
          value['servicio'] ?? '',

          'trabajadora':
          value['trabajadora'] ?? '',

          'fecha':
          value['fecha'] ?? '',

          'hora':
          value['hora'] ?? '',

          'precio':
          value['precio'] ?? '',

          'adelanto':
          value['adelanto'] ?? '',

          'estadoPago':
          value['estadoPago'] ?? '',

          'observaciones':
          value['observaciones'] ?? '',

          'estado':
          value['estado'] ?? '',
        });
      });

      await ExcelService
          .exportarCitas(

        citas: lista,
      );
    }
  }

  Color colorEstado(
      String estado) {

    switch (estado.toLowerCase()) {

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

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,

      appBar: AppBar(

        elevation: 0,

        title: Text(

          rolUsuario == 'admin'

              ? 'Gestión de Citas'

              : 'Mis Citas',

          style: const TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),

        actions: [

          if (rolUsuario == 'admin')

            IconButton(

              onPressed:
              exportarExcel,

              icon: const Icon(
                Icons.table_chart,
              ),
            ),
        ],
      ),

      floatingActionButton:

      rolUsuario == 'admin'

          ? FloatingActionButton.extended(

        backgroundColor:
        const Color(0xFFD9A5B3),

        onPressed: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder:
                  (_) =>
              const PagosScreen(),
            ),
          );
        },

        icon: const Icon(

          Icons.payment,

          color: Colors.white,
        ),

        label: const Text(

          'Yape',

          style: TextStyle(
            color: Colors.white,
          ),
        ),
      )

          : null,

      body: SafeArea(

        child: Padding(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            children: [

              if (rolUsuario == 'admin') ...[

                Flexible(

                  child: SingleChildScrollView(

                    child: Column(

                      children: [

                TextField(

                  controller:
                  buscarController,

                  onChanged: (value) {

                    setState(() {

                      textoBusqueda =
                          value.toLowerCase();
                    });
                  },

                  decoration:
                  decoracionInput(

                    'Buscar cliente',

                    Icons.search,
                  ),
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(

                  value:
                  sedeSeleccionada,

                  decoration:
                  decoracionInput(

                    'Sede',

                    Icons.store,
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
                  clienteController,
                  'Cliente',
                  Icons.person,
                ),

                const SizedBox(height: 15),

                campoTexto(
                  telefonoController,
                  'Teléfono',
                  Icons.phone,
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(

                  value:
                  servicioSeleccionado,

                  decoration:
                  decoracionInput(

                    'Servicio',

                    Icons.design_services,
                  ),

                  items:
                  servicios.map((servicio) {

                    return DropdownMenuItem(

                      value:
                      servicio,

                      child:
                      Text(servicio),
                    );
                  }).toList(),

                  onChanged: (value) {

                    setState(() {

                      servicioSeleccionado =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                DropdownButtonFormField<String>(

                  value:
                  trabajadoraSeleccionada,

                  decoration:
                  decoracionInput(

                    'Trabajadora',

                    Icons.groups,
                  ),

                  items:
                  trabajadoras.map((trabajadora) {

                    return DropdownMenuItem(

                      value:
                      trabajadora,

                      child:
                      Text(trabajadora),
                    );
                  }).toList(),

                  onChanged: (value) {

                    setState(() {

                      trabajadoraSeleccionada =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                GestureDetector(

                  onTap:
                  seleccionarFecha,

                  child: AbsorbPointer(

                    child: campoTexto(

                      fechaController,

                      'Fecha',

                      Icons.calendar_month,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                GestureDetector(

                  onTap:
                  seleccionarHora,

                  child: AbsorbPointer(

                    child: campoTexto(

                      horaController,

                      'Hora',

                      Icons.access_time,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                campoTexto(

                  precioController,

                  'Precio final estimado',

                  Icons.attach_money,
                ),

                const SizedBox(height: 15),

                SwitchListTile(

                  value:
                  adelantoPagado,

                  activeColor:
                  const Color(0xFFD9A5B3),

                  contentPadding:
                  EdgeInsets.zero,

                  title:
                  const Text(
                    'Adelanto de S/ 20 recibido',
                  ),

                  subtitle:
                  const Text(
                    'Marca esta opcion para confirmar la reserva.',
                  ),

                  secondary:
                  const Icon(
                    Icons.payments,
                  ),

                  onChanged: (value) {

                    setState(() {

                      adelantoPagado = value;
                    });
                  },
                ),

                const SizedBox(height: 15),

                campoTexto(

                  observacionesController,

                  'Observaciones de la clienta',

                  Icons.notes,
                ),

                const SizedBox(height: 25),

                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    onPressed:
                    cargando
                        ? null
                        : guardarCita,

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

                      'Guardar Cita',

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

                      ],
                    ),
                  ),
                ),
              ],

              Expanded(

                child: StreamBuilder(

                  stream:
                  database
                      .child('citas')
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

                      return const Center(

                        child: Text(
                          'Aun no tienes citas programadas',
                        ),
                      );
                    }

                    Map citas =
                    data as Map;

                    if (rolUsuario == 'admin' &&
                        textoBusqueda.trim().isEmpty) {

                      return Center(

                        child: Container(

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

                          child:
                          const Text(

                            'Busca por nombre o celular para ver las citas registradas.',

                            textAlign:
                            TextAlign.center,

                            style: TextStyle(

                              color:
                              Colors.grey,

                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }

                    List items =
                    citas.entries.where((entry) {

                      final cita =
                          entry.value;

                      if (rolUsuario == 'admin') {

                        final cliente =
                            (cita['cliente'] ?? '')
                                .toString()
                                .toLowerCase();

                        final telefono =
                            (cita['telefono'] ?? '')
                                .toString()
                                .replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );

                        final busqueda =
                            textoBusqueda
                                .trim()
                                .toLowerCase();

                        final busquedaNumeros =
                            textoBusqueda
                                .replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );

                        return cliente.contains(busqueda) ||
                            (busquedaNumeros.isNotEmpty &&
                                telefono.contains(
                                  busquedaNumeros,
                                ));
                      }

                      return cita['trabajadora']
                          .toString()
                          .toLowerCase()

                          ==

                          nombreUsuario
                              .toLowerCase();

                    }).toList();

                    if (items.isEmpty) {

                      return Center(

                        child: Text(

                          rolUsuario == 'admin'
                              ? 'No se encontraron citas con esa busqueda'
                              : 'Aun no tienes citas programadas',

                          textAlign:
                          TextAlign.center,

                          style:
                          const TextStyle(

                            color:
                            Colors.grey,

                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(

                      itemCount:
                      items.length,

                      itemBuilder:
                          (context, index) {

                        final id =
                            items[index].key;

                        final cita =
                            items[index].value;

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
                                    .withOpacity(0.05),

                                blurRadius: 10,

                                offset:
                                const Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Padding(

                            padding:
                            const EdgeInsets.all(
                                18),

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

                                      child: const Icon(

                                        Icons.calendar_month,

                                        color:
                                        Colors.white,
                                      ),
                                    ),

                                    const SizedBox(width: 15),

                                    Expanded(

                                      child: Column(

                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,

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

                                          const SizedBox(height: 5),

                                          Text(
                                            cita['servicio'],
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

                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                Text(
                                  'Sede: ${cita['sede'] ?? 'No indicada'}',
                                ),

                                Text(
                                  '📅 ${cita['fecha']}',
                                ),

                                Text(
                                  '⏰ ${cita['hora']}',
                                ),

                                Text(
                                  '👩 ${cita['trabajadora']}',
                                ),

                                Text(
                                  '📞 ${cita['telefono']}',
                                ),

                                Text(
                                  '💰 S/ ${cita['precio']}',
                                ),

                                Text(
                                  'Adelanto: S/ ${cita['adelanto'] ?? '20'} - ${cita['estadoPago'] ?? 'pendiente'}',
                                ),

                                if ((cita['observaciones'] ?? '')
                                    .toString()
                                    .isNotEmpty)

                                  Text(
                                    'Notas: ${cita['observaciones']}',
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

                                          id,

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

                                          id,

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
                                        Colors.red,
                                      ),

                                      onPressed:
                                          () async {

                                        eliminarCita(
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

                                    ElevatedButton.icon(

                                      style:
                                      ElevatedButton.styleFrom(

                                        backgroundColor:
                                        Colors.deepOrange,
                                      ),

                                      onPressed: () async {

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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
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

  Widget campoTexto(

      TextEditingController controller,
      String texto,
      IconData icono,

      ) {

    return TextField(

      controller:
      controller,

      decoration:
      decoracionInput(
        texto,
        icono,
      ),
    );
  }
}
