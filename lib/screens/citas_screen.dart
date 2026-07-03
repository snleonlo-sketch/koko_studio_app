import 'dart:async';
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
    this.citaEditar,
    this.motivoEdicion,
  });

  final Map<String, dynamic>? citaEditar;
  final String? motivoEdicion;

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

  bool get puedeGestionarCitas =>
      rolUsuario == 'admin' || rolUsuario == 'recepcionista';

  List<String> servicios = [];

  List<String> trabajadoras = [];

  String? servicioSeleccionado;

  String? trabajadoraSeleccionada;

  String sedeSeleccionada =
      KokoConfig.sedes.first;

  bool adelantoPagado = false;
  String? citaEditandoId;

  List<Map<String, dynamic>> clientas = [];
  StreamSubscription? _serviciosSub;
  StreamSubscription? _trabajadorasSub;
  StreamSubscription? _usuariosSub;

  @override
  void dispose() {
    _serviciosSub?.cancel();
    _trabajadorasSub?.cancel();
    _usuariosSub?.cancel();
    clienteController.dispose();
    telefonoController.dispose();
    fechaController.dispose();
    horaController.dispose();
    precioController.dispose();
    observacionesController.dispose();
    buscarController.dispose();
    super.dispose();
  }

  @override
  void initState() {

    super.initState();

    iniciarPantalla();
  }

  Future<void>
  iniciarPantalla() async {

    await cargarUsuario();

    cargarCitaParaEditar();

    cargarDatos();
  }

  void cargarCitaParaEditar() {
    final cita = widget.citaEditar;
    if (cita == null) return;

    setState(() {
      citaEditandoId = (cita['id'] ?? '').toString();
      clienteController.text = (cita['cliente'] ?? '').toString();
      telefonoController.text = (cita['telefono'] ?? '').toString();
      fechaController.text = (cita['fecha'] ?? '').toString();
      horaController.text = (cita['horaInicio'] ?? cita['hora'] ?? '').toString();
      precioController.text = (cita['precio'] ?? '').toString();
      observacionesController.text = (cita['observaciones'] ?? '').toString();
      
      final serv = (cita['servicio'] ?? '').toString();
      if (serv.isNotEmpty && servicios.contains(serv)) {
        servicioSeleccionado = serv;
      }
      
      final trab = (cita['trabajadora'] ?? '').toString();
      if (trab.isNotEmpty && trabajadoras.contains(trab)) {
        trabajadoraSeleccionada = trab;
      }

      adelantoPagado = (cita['adelantoPagado'] == true);
    });
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

    if (rolUsuario == 'recepcionista') {
      final sede = datos['sede'] ?? '';
      if (sede.isNotEmpty) {
        sedeSeleccionada = sede;
      }
    }

    setState(() {});
  }

  void cargarDatos() {

    _serviciosSub = database
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

        if (!servicios.contains('Servicio Personalizado')) {
          servicios.add('Servicio Personalizado');
        }

        if (widget.citaEditar != null) {
          final serv = (widget.citaEditar!['servicio'] ?? '').toString();
          if (servicios.contains(serv)) {
            servicioSeleccionado = serv;
          }
        }

        setState(() {});
      }
    });

    _trabajadorasSub = database
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
                .where((e) => e is Map && e['rol'] != 'recepcionista')
                .map<String>((e) =>
                e['nombre'].toString())
                .toList();

        if (widget.citaEditar != null) {
          final trab = (widget.citaEditar!['trabajadora'] ?? '').toString();
          if (trabajadoras.contains(trab)) {
            trabajadoraSeleccionada = trab;
          }
        }

        setState(() {});
      }
    });

    _usuariosSub = database
        .child('usuarios')
        .onValue
        .listen((event) {

      final data = event.snapshot.value;
      if (data != null) {
        final Map temp = data as Map;
        final List<Map<String, dynamic>> lista = [];
        temp.forEach((key, value) {
          if (value is Map &&
              (value['rol'] ?? '').toString().toLowerCase() == 'cliente') {
            lista.add({
              'uid': key,
              'nombre': (value['nombre'] ?? '').toString(),
              'telefono': (value['telefono'] ?? '').toString(),
              'correo': (value['correo'] ?? '').toString(),
            });
          }
        });
        if (mounted) {
          setState(() {
            clientas = lista;
          });
        }
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

      final String id = citaEditandoId ??
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

        'estado': widget.citaEditar != null
            ? (widget.citaEditar!['estado'] ?? 'pendiente')
            : (adelantoPagado ? 'confirmada' : 'pendiente'),
      });

      await NotificationService
          .mostrarNotificacion(

        titulo:
        citaEditandoId == null ? 'Nueva cita 💖' : 'Cita actualizada 💖',

        mensaje:
        '${clienteController.text} ${citaEditandoId == null ? 'registrada' : 'actualizada'}',
      );

      AwesomeDialog(

        context: context,

        dialogType:
        DialogType.success,

        title: 'Éxito',

        desc:
        citaEditandoId == null ? 'Cita registrada correctamente' : 'Cita actualizada correctamente',

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
    citaEditandoId = null;

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

          puedeGestionarCitas

              ? 'Gestión de Citas'

              : 'Mis Citas',

          style: const TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),

        actions: [

          if (puedeGestionarCitas)

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

      puedeGestionarCitas

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

              if (puedeGestionarCitas) ...[

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

                  onChanged: rolUsuario == 'recepcionista'
                      ? null
                      : (value) {
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

                        : Text(
                          citaEditandoId == null ? 'Guardar Cita' : 'Actualizar Cita',

                      style: const TextStyle(

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

              if (puedeGestionarCitas && textoBusqueda.trim().isNotEmpty)
                Expanded(
                  child: (() {
                    final busqueda = textoBusqueda.trim().toLowerCase();
                    final busquedaNumeros = textoBusqueda.replaceAll(RegExp(r'[^0-9]'), '');

                    final List<Map<String, dynamic>> filteredClientas = clientas.where((clienta) {
                      final nombre = clienta['nombre']!.toLowerCase();
                      final telefono = clienta['telefono']!.replaceAll(RegExp(r'[^0-9]'), '');
                      return nombre.contains(busqueda) ||
                          (busquedaNumeros.isNotEmpty && telefono.contains(busquedaNumeros));
                    }).toList();

                    if (filteredClientas.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron clientas con esa búsqueda',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredClientas.length,
                      itemBuilder: (context, index) {
                        final clienta = filteredClientas[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFD9A5B3),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              clienta['nombre'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('📞 ${clienta['telefono']}'),
                                if (clienta['correo'].isNotEmpty) Text('✉️ ${clienta['correo']}'),
                              ],
                            ),
                            trailing: const Icon(Icons.check_circle_outline, color: Color(0xFFD9A5B3)),
                            onTap: () {
                              setState(() {
                                clienteController.text = clienta['nombre'];
                                telefonoController.text = clienta['telefono'];
                                buscarController.clear();
                                textoBusqueda = '';
                              });
                              FocusScope.of(context).unfocus();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Clienta seleccionada: ${clienta['nombre']}'),
                                  backgroundColor: const Color(0xFFD9A5B3),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  })(),
                ),

              if (!puedeGestionarCitas)
                Expanded(
                  child: StreamBuilder(
                    stream: database.child('citas').onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final data = snapshot.data!.snapshot.value;

                      if (data == null) {
                        return const Center(
                          child: Text('Aun no tienes citas programadas'),
                        );
                      }

                      Map citas = data as Map;

                      final hoy = DateTime.now();
                      final hoyString = '${hoy.day}/${hoy.month}/${hoy.year}';

                      List items = citas.entries.where((entry) {
                        final cita = entry.value;
                        final esTrabajadora = cita['trabajadora']
                                .toString()
                                .toLowerCase()
                            ==
                            nombreUsuario.toLowerCase();
                        final esHoy = (cita['fecha'] ?? '').toString().trim() == hoyString;
                        return esTrabajadora && esHoy;
                      }).toList();

                      if (items.isEmpty) {
                        return const Center(
                          child: Text(
                            'Aun no tienes citas programadas para hoy',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final id = items[index].key;
                          final cita = items[index].value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 18),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: colorEstado(cita['estado']),
                                        child: const Icon(
                                          Icons.calendar_month,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cita['cliente'],
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(cita['servicio']),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorEstado(cita['estado']),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          cita['estado'].toString().toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  Text('Sede: ${cita['sede'] ?? 'No indicada'}'),
                                  Text('📅 ${cita['fecha']}'),
                                  Text('⏰ ${cita['hora']}'),
                                  Text('👩 ${cita['trabajadora']}'),
                                  Text('📞 ${cita['telefono']}'),
                                  Text('💰 S/ ${cita['precio']}'),
                                  Text(
                                      'Adelanto: S/ ${cita['adelanto'] ?? '20'} - ${cita['estadoPago'] ?? 'pendiente'}'),
                                  if ((cita['observaciones'] ?? '').toString().isNotEmpty)
                                    Text('Notas: ${cita['observaciones']}'),
                                  if (cita['estado'] != 'finalizada' && cita['estado'] != 'cancelada') ...[
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        onPressed: () {
                                          actualizarEstado(id, 'finalizada');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Servicio finalizado con éxito'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        icon: const Icon(Icons.done_all, color: Colors.white),
                                        label: const Text(
                                          'Finalizar Servicio',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
