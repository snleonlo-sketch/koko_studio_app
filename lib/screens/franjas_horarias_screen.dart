import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../services/role_service.dart';

class FranjasHorariasScreen extends StatefulWidget {
  const FranjasHorariasScreen({
    super.key,
    required this.fecha,
  });

  final String fecha;

  @override
  State<FranjasHorariasScreen> createState() =>
      _FranjasHorariasScreenState();
}

class _FranjasHorariasScreenState
    extends State<FranjasHorariasScreen> {
  final database =
      FirebaseDatabase.instance.ref();

  final roleService =
      RoleService();

  List<Map<String, dynamic>> citas = [];

  List<String> trabajadoras = [];

  String? trabajadoraFiltro;

  String? sedeFiltro;

  String rolUsuario = '';

  String nombreUsuario = '';

  String sedeUsuario = '';

  bool cargando = true;

  @override
  void initState() {
    super.initState();
    iniciar();
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

    database.child('citas').onValue.listen((event) {
      final data =
          event.snapshot.value;

      final lista =
          <Map<String, dynamic>>[];

      final nombres =
          <String>{};

      if (data != null) {
        final mapa =
            data as Map;

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
          });
        });
      }

      lista.sort((a, b) {
        return _minutos(a['horaInicio'].toString())
            .compareTo(_minutos(b['horaInicio'].toString()));
      });

      setState(() {
        citas = lista;
        trabajadoras = nombres.toList()..sort();
        cargando = false;
      });
    });
  }

  int _minutos(String hora) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(hora.trim());

    if (match == null) {
      return 0;
    }

    var horas =
        int.tryParse(match.group(1) ?? '') ?? 0;

    final minutos =
        int.tryParse(match.group(2) ?? '') ?? 0;

    final periodo =
        match.group(3)?.toUpperCase();

    if (periodo == 'PM' && horas < 12) {
      horas += 12;
    }

    if (periodo == 'AM' && horas == 12) {
      horas = 0;
    }

    return horas * 60 + minutos;
  }

  List<Map<String, dynamic>> get citasFiltradas {
    return citas.where((cita) {
      final cumpleTrabajadora = trabajadoraFiltro == null ||
          trabajadoraFiltro!.isEmpty ||
          cita['trabajadora'] == trabajadoraFiltro;

      final cumpleSede = sedeFiltro == null ||
          sedeFiltro!.isEmpty ||
          cita['sede'] == sedeFiltro;

      return cumpleTrabajadora && cumpleSede;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Franjas Horarias',
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
                    const SizedBox(height: 8),
                    const Text(
                      'Los horarios que no aparecen ocupados pueden revisarse como libres.',
                    ),
                    const SizedBox(height: 18),
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
        'No hay franjas ocupadas para esta seleccion.',
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _citaCard(Map<String, dynamic> cita) {
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
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                const Color(0xFFD9A5B3).withOpacity(0.18),
            child: const Icon(
              Icons.schedule,
              color: Color(0xFFD9A5B3),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cita['horaInicio']} - ${cita['horaFin']}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text('${cita['trabajadora']}'),
                Text(
                  '${cita['cliente']} - ${cita['servicio']}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
