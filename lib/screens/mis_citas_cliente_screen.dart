import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MisCitasClienteScreen extends StatefulWidget {
  const MisCitasClienteScreen({
    super.key,
  });

  @override
  State<MisCitasClienteScreen> createState() =>
      _MisCitasClienteScreenState();
}

class _MisCitasClienteScreenState
    extends State<MisCitasClienteScreen> {
  final usuario =
      FirebaseAuth.instance.currentUser;

  final DatabaseReference database =
      FirebaseDatabase.instance.ref();

  String telefonoCliente = '';

  @override
  void initState() {
    super.initState();
    cargarCliente();
  }

  Future<void> cargarCliente() async {
    final uid =
        usuario?.uid;

    if (uid == null) return;

    final snapshot =
        await database
            .child('usuarios')
            .child(uid)
            .get();

    if (!snapshot.exists) return;

    final datos =
        snapshot.value as Map;

    setState(() {
      telefonoCliente =
          datos['telefono'] ?? '';
    });
  }

  Color colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return const Color(0xFF7E9CCB);
      case 'finalizada':
        return const Color(0xFF7BAE8D);
      case 'cancelada':
        return const Color(0xFFC97D7D);
      default:
        return const Color(0xFFD9A5B3);
    }
  }

  bool perteneceACliente(Map cita) {
    final uid =
        usuario?.uid;

    final telefonoCita =
        (cita['telefono'] ?? '')
            .toString()
            .replaceAll(RegExp(r'[^0-9]'), '');

    final telefonoUsuario =
        telefonoCliente
            .replaceAll(RegExp(r'[^0-9]'), '');

    return cita['clienteUid'] == uid ||
        (telefonoUsuario.isNotEmpty &&
            telefonoCita == telefonoUsuario);
  }

  bool esProgramada(Map cita) {
    final estado =
        (cita['estado'] ?? 'pendiente')
            .toString()
            .toLowerCase();

    return estado == 'pendiente' ||
        estado == 'confirmada';
  }

  String rangoHora(Map cita) {
    final inicio =
        (cita['horaInicio'] ??
                cita['hora'] ??
                '')
            .toString();

    final fin =
        (cita['horaFin'] ?? '')
            .toString();

    if (fin.isEmpty) {
      return inicio;
    }

    return '$inicio - $fin';
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
          'Mis Citas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder(
        stream:
            database
                .child('citas')
                .onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!
                  .snapshot
                  .value;

          if (data == null) {
            return mensajeVacio();
          }

          final citas =
              data as Map;

          final items =
              citas.entries.where((entry) {
            final cita =
                Map<dynamic, dynamic>.from(entry.value);

            return perteneceACliente(cita) &&
                esProgramada(cita);
          }).toList();

          if (items.isEmpty) {
            return mensajeVacio();
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(20),
            itemCount:
                items.length,
            itemBuilder: (context, index) {
              final cita =
                  Map<dynamic, dynamic>.from(
                items[index].value,
              );

              final estado =
                  (cita['estado'] ?? 'pendiente')
                      .toString();

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 18,
                ),
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
                        CircleAvatar(
                          backgroundColor:
                              colorEstado(estado),
                          child: const Icon(
                            Icons.calendar_month,
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
                                cita['servicio'] ?? '',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cita['sede'] ?? 'Sede no indicada',
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                colorEstado(estado),
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          child: Text(
                            estado.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text('Fecha: ${cita['fecha'] ?? ''}'),
                    Text('Hora: ${rangoHora(cita)}'),
                    Text('Especialista: ${cita['trabajadora'] ?? ''}'),
                    Text(
                      'Adelanto: S/ ${cita['adelanto'] ?? '20'} - ${cita['estadoPago'] ?? 'pendiente'}',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget mensajeVacio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Text(
          'Aun no tienes citas programadas',
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
