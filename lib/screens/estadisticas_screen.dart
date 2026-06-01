import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

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

  double ingresosTotales = 0;

  Map<String, double>
  ingresosPorTrabajadora = {};

  Map<String, int>
  serviciosRealizados = {};

  bool cargando = true;

  @override
  void initState() {

    super.initState();

    cargarEstadisticas();
  }

  void cargarEstadisticas() {

    cargarCitas();

    cargarTrabajadoras();

    cargarServicios();
  }

  void cargarCitas() {

    database
        .child('citas')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      totalCitas = 0;

      ingresosTotales = 0;

      ingresosPorTrabajadora
          .clear();

      serviciosRealizados
          .clear();

      if (data != null) {

        Map citas =
        data as Map;

        totalCitas =
            citas.length;

        citas.forEach((key, value) {

          double precio =
              double.tryParse(

                value['precio']
                    .toString(),

              ) ?? 0;

          ingresosTotales +=
              precio;

          String trabajadora =
          value['trabajadora']
              .toString();

          ingresosPorTrabajadora[
          trabajadora] =

              (ingresosPorTrabajadora[
              trabajadora] ??
                  0)

                  +

                  precio;

          String servicio =
          value['servicio']
              .toString();

          serviciosRealizados[
          servicio] =

              (serviciosRealizados[
              servicio] ??
                  0)

                  +

                  1;
        });
      }

      setState(() {

        cargando = false;
      });
    });
  }

  void cargarTrabajadoras() {

    database
        .child('trabajadoras')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      if (data != null) {

        Map trabajadoras =
        data as Map;

        totalTrabajadoras =
            trabajadoras.length;

      } else {

        totalTrabajadoras = 0;
      }

      setState(() {});
    });
  }

  void cargarServicios() {

    database
        .child('servicios')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      if (data != null) {

        Map servicios =
        data as Map;

        totalServicios =
            servicios.length;

      } else {

        totalServicios = 0;
      }

      setState(() {});
    });
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

                    'Ingresos acumulados',

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

              childAspectRatio: 1.9,

              children: [

                tarjetaEstadistica(

                  'Total Citas',

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

                  'Ingresos',

                  'S/ ${ingresosTotales.toStringAsFixed(0)}',

                  Icons.attach_money,

                  Colors.green,
                ),
              ],
            ),

            const SizedBox(height: 35),

            Text(

              'Distribución General',

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

              height: 320,

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

              child: PieChart(

                PieChartData(

                  sectionsSpace: 5,

                  centerSpaceRadius: 55,

                  sections: [

                    PieChartSectionData(

                      value:
                      totalCitas.toDouble(),

                      title:
                      'Citas',

                      radius: 75,

                      color:
                      Colors.pink,

                      titleStyle:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    PieChartSectionData(

                      value:
                      totalTrabajadoras
                          .toDouble(),

                      title:
                      'Trab.',

                      radius: 75,

                      color:
                      Colors.purple,

                      titleStyle:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    PieChartSectionData(

                      value:
                      totalServicios
                          .toDouble(),

                      title:
                      'Serv.',

                      radius: 75,

                      color:
                      Colors.orange,

                      titleStyle:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
              'No hay ingresos aún',
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

              'Servicios Más Solicitados',

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
              'No hay servicios aún',
            )

                : Column(

              children:

              serviciosRealizados
                  .entries
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
        horizontal: 12,
        vertical: 10,
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
            const EdgeInsets.all(8),

            decoration: BoxDecoration(

              color:
              color.withOpacity(0.15),

              shape:
              BoxShape.circle,
            ),

            child: Icon(

              icono,

              color: color,

              size: 21,
            ),
          ),

          const SizedBox(height: 5),

          Text(

            total,

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
