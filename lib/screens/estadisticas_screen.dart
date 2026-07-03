import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:printing/printing.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';

class EstadisticasScreen
    extends StatefulWidget {

  const EstadisticasScreen({
    super.key,
  });

  @override
  State<EstadisticasScreen>
  createState() =>
      _EstadisticasScreenState();
}

class _EstadisticasScreenState
    extends State<EstadisticasScreen> {

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  int totalCitas = 0;

  int totalTrabajadoras = 0;

  int totalServicios = 0;

  int totalClientas = 0;

  int totalCanceladasPeriodo = 0;

  double ingresosTotales = 0;

  String mesSeleccionado = '${DateTime.now().month}/${DateTime.now().year}';

  List<Map<String, dynamic>> citasDelMes = [];

  Map<String, double>
  ingresosPorTrabajadora = {};

  Map<String, int>
  serviciosRealizados = {};

  bool cargando = true;

  String filtroPeriodo = 'Mensual'; // Semanal, Quincenal, Mensual

  StreamSubscription? _citasSubscription;
  StreamSubscription? _trabajadorasSubscription;
  StreamSubscription? _serviciosSubscription;
  StreamSubscription? _clientasSubscription;

  @override
  void initState() {

    super.initState();

    cargarEstadisticas();
  }

  @override
  void dispose() {
    _citasSubscription?.cancel();
    _trabajadorasSubscription?.cancel();
    _serviciosSubscription?.cancel();
    _clientasSubscription?.cancel();
    super.dispose();
  }

  void cargarEstadisticas() {

    cargarCitas();

    cargarTrabajadoras();

    cargarServicios();

    cargarClientas();
  }

  String sedeSeleccionada = 'Todas';

  Map rawCitas = {};
  Map rawTrabajadoras = {};
  Map rawServicios = {};

  void cargarCitas() {
    _citasSubscription = database.child('citas').onValue.listen((event) {
      rawCitas = (event.snapshot.value as Map?) ?? {};
      actualizarEstadisticas();
    });
  }

  void cargarClientas() {
    _clientasSubscription = database
        .child('usuarios')
        .onValue
        .listen((event) {
      final data = event.snapshot.value;
      if (data != null) {
        Map map = data as Map;
        totalClientas = map.length;
      } else {
        totalClientas = 0;
      }
      setState(() {});
    });
  }

  List<Map<String, String>> obtenerMesesDisponibles() {
    final mesesNombres = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    List<Map<String, String>> list = [];
    DateTime fecha = DateTime.now();
    for (int i = 0; i < 12; i++) {
      int mes = fecha.month;
      int anio = fecha.year;
      String valor = '$mes/$anio';
      String nombre = '${mesesNombres[mes - 1]} $anio';
      list.add({'valor': valor, 'nombre': nombre});

      fecha = DateTime(fecha.year, fecha.month - 1, 1);
    }
    return list;
  }

  void cargarTrabajadoras() {
    _trabajadorasSubscription = database.child('trabajadoras').onValue.listen((event) {
      rawTrabajadoras = (event.snapshot.value as Map?) ?? {};
      actualizarEstadisticas();
    });
  }

  void cargarServicios() {
    _serviciosSubscription = database.child('servicios').onValue.listen((event) {
      rawServicios = (event.snapshot.value as Map?) ?? {};
      actualizarEstadisticas();
    });
  }

  void actualizarEstadisticas() {
    totalTrabajadoras = 0;
    rawTrabajadoras.forEach((key, value) {
      if (value != null) {
        final map = value as Map;
        final sede = (map['sede'] ?? '').toString();
        if (sedeSeleccionada == 'Todas' || sede == sedeSeleccionada) {
          totalTrabajadoras++;
        }
      }
    });

    totalServicios = 0;
    rawServicios.forEach((key, value) {
      if (value != null) {
        final map = value as Map;
        final sede = (map['sede'] ?? '').toString();
        if (sedeSeleccionada == 'Todas' || sede == sedeSeleccionada) {
          totalServicios++;
        }
      }
    });

    totalCitas = 0;
    totalCanceladasPeriodo = 0;
    ingresosTotales = 0;
    ingresosPorTrabajadora.clear();
    serviciosRealizados.clear();
    citasDelMes.clear();

    DateTime fechaInicio;
    DateTime fechaFin;

    if (filtroPeriodo == 'Semanal') {
      final hoy = DateTime.now();
      fechaFin = DateTime(hoy.year, hoy.month, hoy.day);
      fechaInicio = fechaFin.subtract(const Duration(days: 7));
    } else if (filtroPeriodo == 'Quincenal') {
      final hoy = DateTime.now();
      fechaFin = DateTime(hoy.year, hoy.month, hoy.day);
      fechaInicio = fechaFin.subtract(const Duration(days: 15));
    } else {
      List<String> mesAnioPartes = mesSeleccionado.split('/');
      int selMes = int.tryParse(mesAnioPartes[0]) ?? DateTime.now().month;
      int selAnio = int.tryParse(mesAnioPartes[1]) ?? DateTime.now().year;

      fechaInicio = DateTime(selAnio, selMes, 1);
      fechaFin = DateTime(selAnio, selMes + 1, 0);
    }

    rawCitas.forEach((key, value) {
      if (value != null) {
        final map = value as Map;
        final sede = (map['sede'] ?? '').toString();

        if (sedeSeleccionada != 'Todas' && sede != sedeSeleccionada) {
          return;
        }

        String fechaString = (map['fecha'] ?? '').toString();
        List<String> partes = fechaString.split('/');

        if (partes.length == 3) {
          int dia = int.tryParse(partes[0]) ?? 1;
          int mes = int.tryParse(partes[1]) ?? 1;
          int anio = int.tryParse(partes[2]) ?? 2026;

          DateTime fechaCita = DateTime(anio, mes, dia);

          if ((fechaCita.isAtSameMomentAs(fechaInicio) || fechaCita.isAfter(fechaInicio)) &&
              (fechaCita.isAtSameMomentAs(fechaFin) || fechaCita.isBefore(fechaFin))) {

            totalCitas++;

            double precio = double.tryParse(map['precio'].toString()) ?? 0;
            String estado = (map['estado'] ?? '').toString().toLowerCase();

            if (estado == 'finalizada') {
              ingresosTotales += precio;
              String trabajadora = map['trabajadora'].toString();
              ingresosPorTrabajadora[trabajadora] =
                  (ingresosPorTrabajadora[trabajadora] ?? 0) + precio;
            } else if (estado == 'cancelada') {
              totalCanceladasPeriodo++;
              ingresosTotales += 20; // S/ 20 de adelanto se quedan en caja
            }

            if (estado != 'cancelada') {
              String servicio = map['servicio'].toString();
              final servs = servicio.split(', ').map((e) => e.trim()).toList();
              for (final s in servs) {
                if (s.isNotEmpty) {
                  serviciosRealizados[s] =
                      (serviciosRealizados[s] ?? 0) + 1;
                }
              }
            }

            citasDelMes.add(Map<String, dynamic>.from(map));
          }
        }
      }
    });

    setState(() {
      cargando = false;
    });
  }

  final List<Color> coloresGrafico = [
    Colors.pink,
    Colors.purple,
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  List<PieChartSectionData> obtenerSeccionesPie() {
    if (serviciosRealizados.isEmpty) {
      return [
        PieChartSectionData(
          value: 1,
          title: 'Sin datos',
          color: Colors.grey,
          radius: 65,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        )
      ];
    }

    final ordenados = serviciosRealizados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int index = 0;
    return ordenados.map((entry) {
      final color = coloresGrafico[index % coloresGrafico.length];
      index++;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 70,
        color: color,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();
  }

  Widget construirLeyenda() {
    if (serviciosRealizados.isEmpty) return const SizedBox();

    final ordenados = serviciosRealizados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    int index = 0;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: ordenados.map((entry) {
        final color = coloresGrafico[index % coloresGrafico.length];
        index++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key} (${entry.value})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String obtenerNombreMesSeleccionado() {
    final mesesNombres = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    List<String> partes = mesSeleccionado.split('/');
    if (partes.length == 2) {
      int mes = int.tryParse(partes[0]) ?? 1;
      int anio = int.tryParse(partes[1]) ?? 2026;
      return '${mesesNombres[mes - 1]} $anio';
    }
    return mesSeleccionado;
  }

  Future<void> _seleccionarMesAnio(BuildContext context) async {
    int anioTemp = int.tryParse(mesSeleccionado.split('/')[1]) ?? DateTime.now().year;
    int mesTemp = int.tryParse(mesSeleccionado.split('/')[0]) ?? DateTime.now().month;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final anioActual = DateTime.now().year;
            final listaAnios = List<int>.generate(
              (anioActual - 2026) + 1,
              (index) => 2026 + index,
            );

            final mesesNombres = [
              'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
              'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
            ];

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: const Center(
                child: Text(
                  'Seleccionar Período 📅',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Año',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    children: listaAnios.map((anio) {
                      final esSeleccionado = anioTemp == anio;
                      return ChoiceChip(
                        label: Text('$anio'),
                        selected: esSeleccionado,
                        selectedColor: const Color(0xFFD9A5B3),
                        labelStyle: TextStyle(
                          color: esSeleccionado ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setDialogState(() {
                              anioTemp = anio;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const Divider(height: 30),
                  const Text(
                    'Mes',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 300,
                    height: 200,
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        final mes = index + 1;
                        final esSeleccionado = mesTemp == mes;
                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              mesTemp = mes;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: esSeleccionado
                                  ? const Color(0xFFD9A5B3)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              mesesNombres[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: esSeleccionado ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9A5B3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {'mes': mesTemp, 'anio': anioTemp});
                  },
                  child: const Text('Aceptar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        mesSeleccionado = '${result['mes']}/${result['anio']}';
        cargando = true;
      });
      actualizarEstadisticas();
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

          'Dashboard Ejecutivo',

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

          : SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Card(
              elevation: 0,
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['Semanal', 'Quincenal', 'Mensual'].map((periodo) {
                        final bool seleccionado = filtroPeriodo == periodo;
                        String label = '';
                        if (periodo == 'Semanal') label = 'Semana';
                        if (periodo == 'Quincenal') label = '15 Días';
                        if (periodo == 'Mensual') label = 'Mensual';

                        return ChoiceChip(
                          label: Text(label),
                          selected: seleccionado,
                          selectedColor: const Color(0xFFD9A5B3),
                          labelStyle: TextStyle(
                            color: seleccionado ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onSelected: (bool selected) {
                            if (selected) {
                              setState(() {
                                filtroPeriodo = periodo;
                              });
                              actualizarEstadisticas();
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const Divider(height: 15),
                    if (filtroPeriodo == 'Mensual')
                      ListTile(
                        leading: const Icon(Icons.calendar_today, color: Color(0xFFD9A5B3)),
                        title: const Text(
                          'Mes Seleccionado',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        subtitle: Text(
                          obtenerNombreMesSeleccionado(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD9A5B3),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_drop_down, color: Color(0xFFD9A5B3)),
                        onTap: () => _seleccionarMesAnio(context),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Row(
                          children: [
                            const Icon(Icons.date_range, color: Color(0xFFD9A5B3)),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filtroPeriodo == 'Semanal' ? 'Últimos 7 días' : 'Últimos 15 días',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  'Citas del periodo seleccionado',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 10),
                    DropdownButtonFormField<String>(
                      value: sedeSeleccionada,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.store, color: Color(0xFFD9A5B3)),
                        labelText: 'Sede Operativa',
                        labelStyle: TextStyle(color: Color(0xFFD9A5B3)),
                        border: InputBorder.none,
                      ),
                      items: ['Todas', 'Comas', 'Carabayllo'].map((sede) {
                        return DropdownMenuItem<String>(
                          value: sede,
                          child: Text(sede == 'Todas' ? 'Todas las sedes' : sede),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            sedeSeleccionada = value;
                          });
                          actualizarEstadisticas();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(

              width: double.infinity,

              padding:
              const EdgeInsets.all(25),

              decoration: BoxDecoration(

                gradient:
                const LinearGradient(

                  colors: [

                    Color(0xFFD9A5B3),

                    Color(0xFFEFC3CF),
                  ],
                ),

                borderRadius:
                BorderRadius.circular(30),

                boxShadow: [

                  BoxShadow(

                    color:
                    Colors.pink
                        .withOpacity(0.15),

                    blurRadius: 15,

                    offset:
                    const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const Text(

                    'Resumen General 💖',

                    style: TextStyle(

                      color:
                      Colors.white,

                      fontSize: 28,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(

                    'S/ ${ingresosTotales.toStringAsFixed(2)}',

                    style:
                    const TextStyle(

                      color:
                      Colors.white,

                      fontSize: 40,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(

                    'Ingresos acumulados (Citas Finalizadas)',

                    style: TextStyle(

                      color:
                      Colors.white70,

                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            GridView.count(

              shrinkWrap: true,

              physics:
              const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              childAspectRatio: 1.35,

              children: [

                tarjetaEstadistica(

                  'Citas del Ciclo',

                  totalCitas.toString(),

                  Icons.calendar_month,

                  Colors.pink,
                ),

                tarjetaEstadistica(

                  'Trabajadoras',

                  totalTrabajadoras
                      .toString(),

                  Icons.people,

                  Colors.purple,
                ),

                tarjetaEstadistica(

                  'Servicios',

                  totalServicios
                      .toString(),

                  Icons.spa,

                  Colors.orange,
                ),

                tarjetaEstadistica(

                  'Clientas',

                  totalClientas.toString(),

                  Icons.person,

                  Colors.green,
                ),

                tarjetaEstadistica(

                  'Cancelaciones',

                  totalCanceladasPeriodo.toString(),

                  Icons.cancel_presentation,

                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      final lista = citasDelMes.map((cita) {
                        return {
                          'cliente': cita['cliente'],
                          'telefono': cita['telefono'],
                          'servicio': cita['servicio'],
                          'trabajadora': cita['trabajadora'],
                          'fecha': cita['fecha'],
                          'hora': (cita['horaInicio'] ?? cita['hora'] ?? '').toString() +
                              (cita['horaFin'] != null && (cita['horaFin'] ?? '').toString().isNotEmpty
                                  ? ' - ${cita['horaFin']}'
                                  : ''),
                          'precio': cita['precio'],
                          'estado': cita['estado'],
                          'sede': cita['sede'] ?? 'No asignada',
                        };
                      }).toList();
                      await ExcelService.exportarCitas(citas: lista);
                    },
                    icon: const Icon(Icons.file_present, color: Colors.white),
                    label: const Text(
                      'Exportar Excel',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      final listInfo = obtenerMesesDisponibles();
                      final nombreMes = listInfo.firstWhere(
                          (m) => m['valor'] == mesSeleccionado,
                          orElse: () => {'nombre': 'Ciclo Actual'})['nombre']!;
                      
                      final nombreMesConSede = '$nombreMes (${sedeSeleccionada == "Todas" ? "Todas las sedes" : "Sede $sedeSeleccionada"})';
                      
                      final pdfBytes = await PdfService.generarReporteMensual(
                        mes: nombreMesConSede,
                        ingresos: ingresosTotales,
                        citas: totalCitas,
                        clientas: totalClientas,
                        ingresosTrabajadora: ingresosPorTrabajadora,
                        servicios: serviciosRealizados,
                      );
                      
                      await Printing.layoutPdf(
                        onLayout: (format) async => pdfBytes,
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text(
                      'Exportar PDF',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            Text(

              'Distribución de Servicios',

              style: TextStyle(

                fontSize: 24,

                fontWeight:
                FontWeight.bold,

                color:
                Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),

            const SizedBox(height: 20),

            Container(

              padding:
              const EdgeInsets.all(20),

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
                        .withOpacity(0.05),

                    blurRadius: 10,

                    offset:
                    const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  SizedBox(
                    height: 240,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 45,
                        sections: obtenerSeccionesPie(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  construirLeyenda(),
                ],
              ),
            ),

            const SizedBox(height: 35),

            Text(

              'Ingresos por Trabajadora',

              style: TextStyle(

                fontSize: 24,

                fontWeight:
                FontWeight.bold,

                color:
                Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),

            const SizedBox(height: 20),

            ingresosPorTrabajadora
                .isEmpty

                ? mensajeVacio(
              'No hay ingresos confirmados en este ciclo',
            )

                : Column(

              children:

              ingresosPorTrabajadora
                  .entries
                  .map((entry) {

                return tarjetaIngreso(

                  entry.key,

                  entry.value,
                );
              }).toList(),
            ),

            const SizedBox(height: 35),

            Text(

              'Servicios Más Solicitados (Top 3)',

              style: TextStyle(

                fontSize: 24,

                fontWeight:
                FontWeight.bold,

                color:
                Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),

            const SizedBox(height: 20),

            serviciosRealizados
                .isEmpty

                ? mensajeVacio(
              'No hay servicios registrados en este ciclo',
            )

                : Column(

              children:
              (serviciosRealizados.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
                  .take(3)
                  .map((entry) {

                return tarjetaServicio(

                  entry.key,

                  entry.value,
                );
              }).toList(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget tarjetaEstadistica(

      String titulo,
      String total,
      IconData icono,
      Color color,

      ) {

    return Container(

      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),

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
                .withOpacity(0.05),

            blurRadius: 10,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(

        mainAxisAlignment:
        MainAxisAlignment.center,

        children: [

          Container(

            padding:
            const EdgeInsets.all(7),

            decoration: BoxDecoration(

              color:
              color.withOpacity(0.15),

              shape:
              BoxShape.circle,
            ),

            child: Icon(

              icono,

              color: color,

              size: 20,
            ),
          ),

          const SizedBox(height: 4),

          Text(

            total,

            style: TextStyle(

              fontSize: 17,

              fontWeight:
              FontWeight.bold,

              color:
              Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.color,
            ),
          ),

          const SizedBox(height: 2),

          Text(

            titulo,

            textAlign:
            TextAlign.center,

            style: const TextStyle(

              color:
              Colors.grey,

              fontSize: 12,

              fontWeight:
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaIngreso(

      String nombre,
      double ingreso,

      ) {

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
        Theme.of(context)
            .cardColor,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black
                .withOpacity(0.05),

            blurRadius: 8,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Row(

        children: [

          CircleAvatar(

            backgroundColor:
            Colors.green
                .withOpacity(0.15),

            child: const Icon(

              Icons.attach_money,

              color:
              Colors.green,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(

            child: Text(

              nombre,

              style: TextStyle(

                fontSize: 18,

                fontWeight:
                FontWeight.bold,

                color:
                Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),
          ),

          Text(

            'S/ ${ingreso.toStringAsFixed(2)}',

            style: const TextStyle(

              fontSize: 18,

              color:
              Colors.green,

              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaServicio(

      String servicio,
      int cantidad,

      ) {

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),

      padding:
      const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
        Theme.of(context)
            .cardColor,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black
                .withOpacity(0.05),

            blurRadius: 8,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Row(

        children: [

          CircleAvatar(

            backgroundColor:
            Colors.pink
                .withOpacity(0.15),

            child: const Icon(

              Icons.spa,

              color:
              Colors.pink,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(

            child: Text(

              servicio,

              style: TextStyle(

                fontSize: 18,

                fontWeight:
                FontWeight.bold,

                color:
                Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),
          ),

          Container(

            padding:
            const EdgeInsets.symmetric(

              horizontal: 15,

              vertical: 8,
            ),

            decoration: BoxDecoration(

              color:
              const Color(0xFFD9A5B3),

              borderRadius:
              BorderRadius.circular(20),
            ),

            child: Text(

              '$cantidad citas',

              style: const TextStyle(

                color:
                Colors.white,

                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mensajeVacio(
      String texto) {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(25),

      decoration: BoxDecoration(

        color:
        Theme.of(context)
            .cardColor,

        borderRadius:
        BorderRadius.circular(20),
      ),

      child: Center(

        child: Text(

          texto,

          style: const TextStyle(

            fontSize: 16,

            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
