import 'dart:async';
import 'package:flutter/material.dart';
import '../services/firestore_database_shim.dart';

import '../utils/koko_config.dart';

class AlertasAdminScreen extends StatefulWidget {
  const AlertasAdminScreen({super.key});

  @override
  State<AlertasAdminScreen> createState() =>
      _AlertasAdminScreenState();
}

class _AlertasAdminScreenState extends State<AlertasAdminScreen> {
  final alertasRef =
      FirebaseDatabase.instance.ref().child('alertas_admin');

  StreamSubscription<DatabaseEvent>? _alertasSubscription;
  List<Map<String, dynamic>> _todasLasAlertas = [];
  bool _cargando = true;

  String filtroSede = 'Todas';
  bool recientesPrimero = true;
  String buscarTexto = '';
  final TextEditingController buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _alertasSubscription = alertasRef.onValue.listen((event) {
      if (mounted) {
        setState(() {
          _cargando = false;
          final value = event.snapshot.value;
          if (value != null) {
            List<Map<String, dynamic>> temp = [];
            try {
              if (value is Map) {
                value.forEach((key, val) {
                  if (val is Map) {
                    final alerta = Map<String, dynamic>.from(val);
                    alerta['id'] = key.toString();
                    temp.add(alerta);
                  }
                });
              } else if (value is List) {
                for (int i = 0; i < value.length; i++) {
                  final val = value[i];
                  if (val is Map) {
                    final alerta = Map<String, dynamic>.from(val);
                    alerta['id'] = i.toString();
                    temp.add(alerta);
                  }
                }
              }
            } catch (e) {
              print('Error al procesar alertas: $e');
            }
            _todasLasAlertas = temp;
          } else {
            _todasLasAlertas = [];
          }
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _cargando = false;
        });
      }
    });
  }

  DateTime fechaAlerta(Map alerta) {
    return DateTime.tryParse(
          (alerta['fechaHora'] ?? '').toString(),
        ) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  String textoFecha(String valor) {
    final fecha = DateTime.tryParse(valor);
    if (fecha == null) {
      return valor;
    }
    return '${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  Future<void> marcarLeida(String id) async {
    await alertasRef.child(id).update({
      'leida': true,
    });
  }

  @override
  void dispose() {
    _alertasSubscription?.cancel();
    buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Buzón de Alertas',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFD9A5B3),
            labelColor: Color(0xFF4E363B),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(
                icon: Icon(Icons.mark_email_unread_outlined),
                text: 'Nuevas',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Historial',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTabNuevas(),
            _buildTabLeidas(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNuevas() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final alertas = _todasLasAlertas.where((alerta) {
      final sede = (alerta['sede'] ?? '').toString();
      final leida = alerta['leida'] == true;
      return !leida && (filtroSede == 'Todas' || sede.toLowerCase() == filtroSede.toLowerCase());
    }).toList();

    alertas.sort((a, b) {
      final comparacion = fechaAlerta(a).compareTo(fechaAlerta(b));
      return recientesPrimero ? -comparacion : comparacion;
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: filtroSede,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    prefixIcon: const Icon(Icons.store),
                    labelText: 'Sede',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    'Todas',
                    ...KokoConfig.sedes,
                  ].map((sede) {
                    return DropdownMenuItem(
                      value: sede,
                      child: Text(sede),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      filtroSede = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: recientesPrimero ? 'Recientes primero' : 'Antiguas primero',
                onPressed: () {
                  setState(() {
                    recientesPrimero = !recientesPrimero;
                  });
                },
                icon: Icon(
                  recientesPrimero ? Icons.arrow_downward : Icons.arrow_upward,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: alertas.isEmpty
              ? const Center(
                  child: Text('No hay nuevas alertas para esta sede'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: alertas.length,
                  itemBuilder: (context, index) {
                    return _buildAlertaCard(alertas[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTabLeidas() {
    if (_cargando) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final alertas = _todasLasAlertas.where((alerta) {
      final sede = (alerta['sede'] ?? '').toString();
      final leida = alerta['leida'] == true;

      if (!leida) return false;
      if (filtroSede != 'Todas' && sede.toLowerCase() != filtroSede.toLowerCase()) return false;

      if (buscarTexto.isNotEmpty) {
        final cliente = (alerta['cliente'] ?? '').toString().toLowerCase();
        final servicio = (alerta['servicio'] ?? '').toString().toLowerCase();
        final trabajadora = (alerta['trabajadora'] ?? '').toString().toLowerCase();
        final motivo = (alerta['motivo'] ?? '').toString().toLowerCase();
        final realizadoPor = (alerta['realizadoPor'] ?? '').toString().toLowerCase();

        return cliente.contains(buscarTexto) ||
            servicio.contains(buscarTexto) ||
            trabajadora.contains(buscarTexto) ||
            motivo.contains(buscarTexto) ||
            realizadoPor.contains(buscarTexto);
      }

      return true;
    }).toList();

    alertas.sort((a, b) {
      final comparacion = fechaAlerta(a).compareTo(fechaAlerta(b));
      return recientesPrimero ? -comparacion : comparacion;
    });

    // Grouping logic for "Leídas"
    List<dynamic> itemsConCabeceras = [];
    String? ultimaFecha;
    for (var alerta in alertas) {
      final fecha = DateTime.tryParse((alerta['fechaHora'] ?? '').toString());
      final fechaString = fecha != null ? '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}' : 'Otras fechas';
      if (fechaString != ultimaFecha) {
        ultimaFecha = fechaString;
        itemsConCabeceras.add(fechaString);
      }
      itemsConCabeceras.add(alerta);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: buscarController,
            decoration: InputDecoration(
              hintText: 'Buscar por cliente, servicio, trabajadora, motivo...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: buscarTexto.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          buscarController.clear();
                          buscarTexto = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                buscarTexto = value.trim().toLowerCase();
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: filtroSede,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    prefixIcon: const Icon(Icons.store),
                    labelText: 'Sede',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    'Todas',
                    ...KokoConfig.sedes,
                  ].map((sede) {
                    return DropdownMenuItem(
                      value: sede,
                      child: Text(sede),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      filtroSede = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: recientesPrimero ? 'Recientes primero' : 'Antiguas primero',
                onPressed: () {
                  setState(() {
                    recientesPrimero = !recientesPrimero;
                  });
                },
                icon: Icon(
                  recientesPrimero ? Icons.arrow_downward : Icons.arrow_upward,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: alertas.isEmpty
              ? const Center(
                  child: Text('No se encontraron alertas leídas con los filtros actuales'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: itemsConCabeceras.length,
                  itemBuilder: (context, index) {
                    final item = itemsConCabeceras[index];
                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Color(0xFFD9A5B3), size: 20),
                            const SizedBox(width: 8),
                            Text(
                              item,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD9A5B3),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Divider(
                                color: const Color(0xFFD9A5B3).withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return _buildAlertaCard(item as Map<String, dynamic>);
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlertaCard(Map<String, dynamic> alerta) {
    final leida = alerta['leida'] == true;
    final accion = (alerta['accion'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: leida ? Colors.transparent : const Color(0xFFD9A5B3),
          width: 1.4,
        ),
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
              CircleAvatar(
                backgroundColor: const Color(0xFFD9A5B3).withOpacity(0.18),
                child: Icon(
                  accion == 'eliminacion'
                      ? Icons.delete
                      : accion == 'creacion'
                          ? Icons.add
                          : Icons.edit,
                  color: const Color(0xFFD9A5B3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  accion.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!leida)
                TextButton(
                  onPressed: () {
                    marcarLeida(
                      alerta['id'].toString(),
                    );
                  },
                  child: const Text('Marcar leida'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          dato('Fecha alerta', textoFecha((alerta['fechaHora'] ?? '').toString())),
          dato('Sede', alerta['sede']),
          dato('Realizado por', '${alerta['realizadoPor'] ?? ''} (${alerta['rol'] ?? ''})'),
          dato('Motivo', alerta['motivo']),
          dato('Clienta', alerta['cliente']),
          dato('Servicio', alerta['servicio']),
          dato('Trabajadora asignada', alerta['trabajadora']),
          dato('Fecha cita', alerta['fecha']),
          dato('Horario', '${alerta['hora'] ?? ''} - ${alerta['horaFin'] ?? ''}'),
        ],
      ),
    );
  }

  Widget dato(String etiqueta, Object? valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$etiqueta: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: (valor ?? '').toString()),
          ],
        ),
      ),
    );
  }
}


