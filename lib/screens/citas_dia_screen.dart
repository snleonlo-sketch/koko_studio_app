import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_database_shim.dart';

import '../services/role_service.dart';

class CitasDiaScreen extends StatefulWidget {
  const CitasDiaScreen({
    super.key,
    required this.fecha,
  });

  final String fecha;

  @override
  State<CitasDiaScreen> createState() =>
      _CitasDiaScreenState();
}

class _CitasDiaScreenState extends State<CitasDiaScreen> {
  final database =
      FirebaseDatabase.instance.ref();

  final roleService =
      RoleService();

  final buscarController =
      TextEditingController();

  List<Map<String, dynamic>> citas = [];

  List<String> trabajadoras = [];

  String textoBusqueda = '';

  String? trabajadoraFiltro;

  String? sedeFiltro;

  String rolUsuario = '';

  String nombreUsuario = '';

  String sedeUsuario = '';

  Map<String, Map<String, dynamic>> observacionesClientas = {};

  Map<String, int> conteoTelefonos = {};

  bool cargando = true;

  StreamSubscription? _citasSubscription;
  StreamSubscription? _observacionesSubscription;

  @override
  void initState() {
    super.initState();
    iniciar();
  }

  @override
  void dispose() {
    buscarController.dispose();
    _citasSubscription?.cancel();
    _observacionesSubscription?.cancel();
    super.dispose();
  }

  Future<void> iniciar() async {
    final datos =
        await roleService.obtenerDatosUsuario();

    rolUsuario =
        (datos['rol'] ?? '').toString();

    nombreUsuario =
        (datos['nombre'] ?? '').toString();

    sedeUsuario =
        (datos['sede'] ?? '').toString();

    cargarObservacionesClientas();

    _citasSubscription = database.child('citas').onValue.listen((event) {
      final data =
          event.snapshot.value;

      final lista =
          <Map<String, dynamic>>[];

      final nombres =
          <String>{};

      final tempConteo = <String, int>{};

      if (data != null) {
        final mapa =
            data as Map;

        mapa.forEach((key, value) {
          if (value is Map) {
            final t = (value['telefono'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
            if (t.isNotEmpty) {
              tempConteo[t] = (tempConteo[t] ?? 0) + 1;
            }
          }
        });

        mapa.forEach((key, value) {
          if ((value['fecha'] ?? '').toString() !=
              widget.fecha) {
            return;
          }

          final trabajadora =
              (value['trabajadora'] ?? '').toString();

          final sede =
              (value['sede'] ?? '').toString();

          if (rolUsuario != 'admin' &&
              sedeUsuario.isNotEmpty &&
              sede.isNotEmpty &&
              sede != sedeUsuario) {
            return;
          }

          if (rolUsuario == 'trabajadora' &&
              trabajadora.toLowerCase() !=
                  nombreUsuario.toLowerCase()) {
            return;
          }

          nombres.add(trabajadora);

          lista.add({
            'id': key,
            'cliente': value['cliente'] ?? '',
            'telefono': value['telefono'] ?? '',
            'servicio': value['servicio'] ?? '',
            'trabajadora': trabajadora,
            'horaInicio':
                value['horaInicio'] ?? value['hora'] ?? '',
            'horaFin': value['horaFin'] ?? '',
            'estado': value['estado'] ?? 'pendiente',
            'sede': sede,
            'observaciones': value['observaciones'] ?? '',
          });
        });
      }

      setState(() {
        citas = lista;
        conteoTelefonos = tempConteo;
        trabajadoras = nombres.toList()..sort();
        cargando = false;
      });
    });
  }

  void cargarObservacionesClientas() {
    _observacionesSubscription = database.child('observaciones_clientas').onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        final Map temp = data as Map;
        final Map<String, Map<String, dynamic>> mapa = {};
        temp.forEach((key, value) {
          if (value is Map) {
            mapa[key.toString()] = Map<String, dynamic>.from(value);
          }
        });
        if (mounted) {
          setState(() {
            observacionesClientas = mapa;
          });
        }
      }
    });
  }

  List<Map<String, dynamic>> get citasFiltradas {
    return citas.where((cita) {
      final texto =
          textoBusqueda.toLowerCase().trim();

      final cumpleTexto =
          texto.isEmpty ||
              cita['cliente']
                  .toString()
                  .toLowerCase()
                  .contains(texto) ||
              cita['telefono']
                  .toString()
                  .toLowerCase()
                  .contains(texto) ||
              cita['servicio']
                  .toString()
                  .toLowerCase()
                  .contains(texto);

      final cumpleTrabajadora =
          trabajadoraFiltro == null ||
              trabajadoraFiltro!.isEmpty ||
              cita['trabajadora'] == trabajadoraFiltro;

      final cumpleSede =
          sedeFiltro == null ||
              sedeFiltro!.isEmpty ||
              cita['sede'] == sedeFiltro;

      return cumpleTexto && cumpleTrabajadora && cumpleSede;
    }).toList();
  }

  Color _colorEstado(String estado) {
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
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Citas del Dia',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fecha,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (rolUsuario != 'trabajadora') ...[
                      TextField(
                        controller: buscarController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          prefixIcon: const Icon(Icons.search),
                          hintText:
                              'Buscar cliente, celular o servicio',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            textoBusqueda = value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (rolUsuario == 'admin') ...[
                      DropdownButtonFormField<String>(
                        value: sedeFiltro,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              Theme.of(context).cardColor,
                          prefixIcon:
                              const Icon(Icons.store),
                          hintText: 'Filtrar sede',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: '',
                            child: Text('Todas las sedes'),
                          ),
                          DropdownMenuItem(
                            value: 'Comas',
                            child: Text('Comas'),
                          ),
                          DropdownMenuItem(
                            value: 'Carabayllo',
                            child: Text('Carabayllo'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            sedeFiltro =
                                (value == null ||
                                        value.isEmpty)
                                    ? null
                                    : value;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (rolUsuario != 'trabajadora')
                      DropdownButtonFormField<String>(
                        value: trabajadoraFiltro,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              Theme.of(context).cardColor,
                          prefixIcon:
                              const Icon(Icons.person_search),
                          hintText: 'Filtrar trabajadora',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Todas'),
                          ),
                          ...trabajadoras.map(
                            (nombre) => DropdownMenuItem(
                              value: nombre,
                              child: Text(nombre),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            trabajadoraFiltro =
                                (value == null ||
                                        value.isEmpty)
                                    ? null
                                    : value;
                          });
                        },
                      ),
                    const SizedBox(height: 20),
                    if (citasFiltradas.isEmpty)
                      _mensajeVacio(context)
                    else
                      ...citasFiltradas.map(_citaCard),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _mensajeVacio(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'No hay citas para esta seleccion.',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _badgeFrecuencia(String telefono) {
    final limpio = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    if (limpio.isEmpty) return const SizedBox();

    final int total = conteoTelefonos[limpio] ?? 0;
    final bool esFrecuente = total > 1;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: esFrecuente ? Colors.teal.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            esFrecuente ? Icons.verified_user : Icons.new_releases,
            size: 12,
            color: esFrecuente ? Colors.teal : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            esFrecuente ? 'Cliente Frecuente' : 'Cliente Nuevo',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: esFrecuente ? Colors.teal : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _citaCard(Map<String, dynamic> cita) {
    final color =
        _colorEstado(cita['estado'].toString());

    final limpio = (cita['telefono'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
    final obs = observacionesClientas[limpio];
    String? textoObservacionPrevia;
    if (obs != null) {
      final notaPrevia = (obs['nota'] ?? '').toString().trim();
      final creador = (obs['trabajadora'] ?? '').toString().trim();
      if (notaPrevia.isNotEmpty) {
        if (creador.toLowerCase() == nombreUsuario.toLowerCase()) {
          textoObservacionPrevia = 'Observación previa: $notaPrevia';
        } else {
          textoObservacionPrevia = 'Observación previa (por $creador): $notaPrevia';
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(
                  Icons.event_available,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      cita['cliente'].toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _badgeFrecuencia(cita['telefono']?.toString() ?? ''),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  cita['estado'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Servicio: ${cita['servicio']}'),
          Text('Horario: ${cita['horaInicio']} - ${cita['horaFin']}'),
          Text('Trabajadora: ${cita['trabajadora']}'),
          if (rolUsuario != 'trabajadora')
            Text('Telefono: ${cita['telefono']}'),
          if (cita['sede'].toString().isNotEmpty)
            Text('Sede: ${cita['sede']}'),
          if (textoObservacionPrevia != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                textoObservacionPrevia,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD9A5B3),
                ),
              ),
            ),
          if (cita['observaciones'].toString().isNotEmpty)
            Text('Nota para la atencion: ${cita['observaciones']}'),
        ],
      ),
    );
  }
}


