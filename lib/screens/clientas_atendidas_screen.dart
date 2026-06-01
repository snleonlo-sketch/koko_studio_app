import 'package:firebase_database/firebase_database.dart';
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

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  Future<void> cargarUsuario() async {
    final datos =
        await roleService.obtenerDatosUsuario();

    setState(() {
      nombreTrabajadora =
          datos['nombre'] ?? '';
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
          : StreamBuilder(
              stream:
                  database.child('citas').onValue,
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

                  if (trabajadora !=
                          nombreTrabajadora.toLowerCase() ||
                      estado != 'finalizada') {
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

                    return tarjetaClienta(clienta);
                  },
                );
              },
            ),
    );
  }

  Widget tarjetaClienta(Map<String, dynamic> clienta) {
    final notaController =
        TextEditingController();

    final telefono =
        clienta['telefono'] ?? '';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 18),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.05),
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
          Row(
            children: [
              const CircleAvatar(
                backgroundColor:
                    Color(0xFFD9A5B3),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      clienta['cliente'] ?? '',
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
                '${clienta['atenciones']} atenciones',
                style: const TextStyle(
                  color: Color(0xFFD9A5B3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller:
                notaController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  'Observacion para recordar en su proxima visita',
              prefixIcon:
                  const Icon(Icons.notes),
              filled: true,
              fillColor:
                  Theme.of(context).scaffoldBackgroundColor,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(15),
                borderSide:
                    BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width:
                double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                guardarNota(
                  telefono: telefono,
                  nota: notaController.text.trim(),
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFD9A5B3),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
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
