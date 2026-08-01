import 'dart:async';
import '../services/firestore_database_shim.dart';
import 'package:flutter/material.dart';

import '../services/role_service.dart';

class ClientasAtendidasScreen extends StatefulWidget {
  const ClientasAtendidasScreen({
    super.key,
  });

  @override
  State<ClientasAtendidasScreen> createState() =>
      _ClientasAtendidasScreenState();
}

class _ClientasAtendidasScreenState
    extends State<ClientasAtendidasScreen> {
  final DatabaseReference database =
      FirebaseDatabase.instance.ref();

  final RoleService roleService =
      RoleService();

  String nombreTrabajadora = '';
  Map<String, String> notasClientas = {};
  DateTime fechaSeleccionada = DateTime.now();
  StreamSubscription? _notasSubscription;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
    cargarNotas();
  }

  @override
  void dispose() {
    _notasSubscription?.cancel();
    super.dispose();
  }

  Future<void> cargarUsuario() async {
    final datos =
        await roleService.obtenerDatosUsuario();

    setState(() {
      nombreTrabajadora =
          datos['nombre'] ?? '';
    });
  }

  void cargarNotas() {
    _notasSubscription = database.child('observaciones_clientas').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final Map temp = data as Map;
        final Map<String, String> mapaNotas = {};
        temp.forEach((key, value) {
          if (value is Map) {
            mapaNotas[key.toString()] = (value['nota'] ?? '').toString();
          }
        });
        if (mounted) {
          setState(() {
            notasClientas = mapaNotas;
          });
        }
      }
    });
  }

  String llaveTelefono(String telefono) {
    final limpio =
        telefono.replaceAll(RegExp(r'[^0-9]'), '');

    return limpio.isEmpty
        ? telefono
        : limpio;
  }

  Future<void> guardarNota({
    required String telefono,
    required String nota,
  }) async {
    await database
        .child('observaciones_clientas')
        .child(llaveTelefono(telefono))
        .update({
      'telefono': telefono,
      'nota': nota,
      'trabajadora': nombreTrabajadora,
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Observacion guardada'),
        backgroundColor: Color(0xFFD9A5B3),
      ),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2026),
      lastDate: DateTime(2035),
    );

    if (fecha != null && mounted) {
      setState(() {
        fechaSeleccionada = fecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Clientas Atendidas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: nombreTrabajadora.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: InkWell(
                    onTap: () => _seleccionarFecha(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFD9A5B3),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filtrar por fecha de atención',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD9A5B3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFFD9A5B3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: database.child('citas').onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final data =
                          snapshot.data!.snapshot.value;

                      if (data == null) {
                        return mensajeVacio();
                      }

                      final citas =
                          data as Map;

                      final Map<String, Map<String, dynamic>>
                          clientas = {};

                      citas.forEach((key, value) {
                        final cita =
                            Map<dynamic, dynamic>.from(value);

                        final trabajadora =
                            (cita['trabajadora'] ?? '')
                                .toString()
                                .toLowerCase();

                        final estado =
                            (cita['estado'] ?? '')
                                .toString()
                                .toLowerCase();

                        final fechaCita = (cita['fecha'] ?? '').toString();
                        final targetFecha = '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}';

                        if (trabajadora !=
                                nombreTrabajadora.toLowerCase() ||
                            estado != 'finalizada' ||
                            fechaCita != targetFecha) {
                          return;
                        }

                        final telefono =
                            (cita['telefono'] ?? '').toString();

                        final llave =
                            llaveTelefono(telefono);

                        clientas.putIfAbsent(llave, () {
                          return {
                            'cliente': cita['cliente'] ?? '',
                            'telefono': telefono,
                            'atenciones': 0,
                          };
                        });

                        clientas[llave]!['atenciones'] =
                            (clientas[llave]!['atenciones'] as int) + 1;
                      });

                      final items =
                          clientas.values.toList();

                      if (items.isEmpty) {
                        return mensajeVacio();
                      }

                      return ListView.builder(
                        padding:
                            const EdgeInsets.all(20),
                        itemCount:
                            items.length,
                        itemBuilder: (context, index) {
                          final clienta =
                              items[index];
                          final llave = llaveTelefono(clienta['telefono'] ?? '');
                          final notaInicial = notasClientas[llave] ?? '';

                          return TarjetaClientaWidget(
                            clienta: clienta,
                            notaInicial: notaInicial,
                            nombreTrabajadora: nombreTrabajadora,
                            onGuardar: (tel, nota) {
                              guardarNota(telefono: tel, nota: nota);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            )
    );
  }

  Widget mensajeVacio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          'Aun no tienes clientas atendidas',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

class TarjetaClientaWidget extends StatefulWidget {
  final Map<String, dynamic> clienta;
  final String notaInicial;
  final String nombreTrabajadora;
  final Function(String telefono, String nota) onGuardar;

  const TarjetaClientaWidget({
    super.key,
    required this.clienta,
    required this.notaInicial,
    required this.nombreTrabajadora,
    required this.onGuardar,
  });

  @override
  State<TarjetaClientaWidget> createState() => _TarjetaClientaWidgetState();
}

class _TarjetaClientaWidgetState extends State<TarjetaClientaWidget> {
  late TextEditingController _notaController;

  @override
  void initState() {
    super.initState();
    _notaController = TextEditingController(text: widget.notaInicial);
  }

  @override
  void didUpdateWidget(covariant TarjetaClientaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notaInicial != widget.notaInicial) {
      _notaController.text = widget.notaInicial;
    }
  }

  @override
  void dispose() {
    _notaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telefono = widget.clienta['telefono'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFD9A5B3),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.clienta['cliente'] ?? '',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      telefono,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${widget.clienta['atenciones']} atenciones',
                style: const TextStyle(
                  color: Color(0xFFD9A5B3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _notaController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Observacion para recordar en su proxima visita',
              prefixIcon: const Icon(Icons.notes),
              filled: true,
              fillColor: Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onGuardar(telefono, _notaController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD9A5B3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(
                Icons.save,
                color: Colors.white,
              ),
              label: const Text(
                'Guardar observacion',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


