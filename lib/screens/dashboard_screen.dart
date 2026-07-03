import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

import '../utils/page_transition.dart';

import 'citas_screen.dart';
import 'calendario_screen.dart';
import 'historial_screen.dart';
import 'profile_screen.dart';
import 'pagos_screen.dart';
import 'estadisticas_screen.dart';
import 'trabajadoras_screen.dart';
import 'servicios_screen.dart';
import 'alertas_admin_screen.dart';


class DashboardScreen
    extends StatefulWidget {

  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen>
  createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {

  final usuario =
      FirebaseAuth.instance.currentUser;

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  int totalCitas = 0;

  int totalServicios = 0;

  int totalTrabajadoras = 0;

  double ingresos = 0;

  int totalCanceladas = 0;

  StreamSubscription? _citasSubscription;
  StreamSubscription? _serviciosSubscription;
  StreamSubscription? _trabajadorasSubscription;

  @override
  void initState() {

    super.initState();

    cargarResumen();
  }

  @override
  void dispose() {
    _citasSubscription?.cancel();
    _serviciosSubscription?.cancel();
    _trabajadorasSubscription?.cancel();
    super.dispose();
  }

  void cargarResumen() {

    // CITAS

    _citasSubscription = database
        .child('citas')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      totalCitas = 0;
      totalCanceladas = 0;
      ingresos = 0;

      if (data != null) {

        Map citas =
        data as Map;

        totalCitas =
            citas.length;

        citas.forEach((key, value) {
          final estado = (value['estado'] ?? '').toString().toLowerCase();

          if (estado == 'finalizada') {
            ingresos +=
                double.tryParse(
                  value['precio']
                      .toString(),
                ) ??
                    0;
          } else if (estado == 'cancelada') {
            totalCanceladas++;
            ingresos += 20; // S/ 20 del anticipo quedan en caja
          }
        });
      }

      setState(() {});
    });

    // SERVICIOS

    _serviciosSubscription = database
        .child('servicios')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      totalServicios = 0;

      if (data != null) {

        Map servicios =
        data as Map;

        totalServicios =
            servicios.length;
      }

      setState(() {});
    });

    // TRABAJADORAS

    _trabajadorasSubscription = database
        .child('trabajadoras')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      totalTrabajadoras = 0;

      if (data != null) {

        Map trabajadoras =
        data as Map;

        totalTrabajadoras =
            trabajadoras.length;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {

    final themeProvider =
    Provider.of<ThemeProvider>(context);

    final bool oscuro =
        themeProvider.esOscuro;

    return Scaffold(

      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,

      drawer: Drawer(

        child: SafeArea(

          bottom: true,

          child: Column(

          children: [

            UserAccountsDrawerHeader(

              decoration:
              const BoxDecoration(

                gradient:
                LinearGradient(

                  colors: [

                    Color(0xFFD9A5B3),

                    Color(0xFFEFC3CF),
                  ],
                ),
              ),

              currentAccountPicture:
              CircleAvatar(

                backgroundColor:
                Colors.white,

                child: Text(

                  usuario?.email
                      ?.substring(0, 1)
                      .toUpperCase()

                      ??

                      'A',

                  style:
                  const TextStyle(

                    fontSize: 28,

                    fontWeight:
                    FontWeight.bold,

                    color:
                    Color(0xFFD9A5B3),
                  ),
                ),
              ),

              accountName:
              const Text(

                'Administrador',

                style: TextStyle(

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              accountEmail: Text(

                usuario?.email ??
                    '',
              ),
            ),

            drawerItem(

              context,

              Icons.calendar_month,

              'Gestión de Citas',

              const CitasScreen(),
            ),

            drawerItem(

              context,

              Icons.event,

              'Calendario',

              const CalendarioScreen(),
            ),

            drawerItem(

              context,

              Icons.groups,

              'Personal',

              const TrabajadorasScreen(),
            ),

            drawerItem(

              context,

              Icons.design_services,

              'Servicios',

              const ServiciosScreen(),
            ),

            drawerItem(

              context,

              Icons.bar_chart,

              'Estadísticas',

              const EstadisticasScreen(),
            ),

            drawerItem(

              context,

              Icons.history,

              'Historial',

              const HistorialScreen(),
            ),

            drawerItem(

              context,

              Icons.notifications_active,

              'Buzon de Alertas',

              const AlertasAdminScreen(),
            ),

            drawerItem(

              context,

              Icons.payment,

              'Método de Pago',

              const PagosScreen(),
            ),

            drawerItem(

              context,

              Icons.person,

              'Mi Perfil',

              const ProfileScreen(),
            ),

            const Spacer(),

            SwitchListTile(

              value: oscuro,

              activeColor:
              const Color(0xFFD9A5B3),

              title: const Text(
                'Modo Oscuro',
              ),

              secondary: Icon(

                oscuro

                    ? Icons.dark_mode

                    : Icons.light_mode,
              ),

              onChanged: (value) {

                themeProvider
                    .cambiarTema();
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
        ),
      ),

      appBar: AppBar(

        elevation: 0,

        centerTitle: true,

        title: const Text(

          'Panel Administrador',

          style: TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),

        actions: [

          IconButton(

            onPressed: () {

              Navigator.push(

                context,

                PageTransitionAnimation
                    .crearTransicion(

                  const ProfileScreen(),
                ),
              );
            },

            icon: const Icon(
              Icons.person,
            ),
          ),
        ],
      ),

      body: SafeArea(

        child: SingleChildScrollView(

          padding:
          const EdgeInsets.all(20),

          child: Column(

            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              // HEADER

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
                  BorderRadius.circular(
                      30),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.pink
                          .withOpacity(
                          0.15),

                      blurRadius: 15,

                      offset:
                      const Offset(0, 8),
                    ),
                  ],
                ),

                child: Row(

                  children: [

                    CircleAvatar(

                      radius: 38,

                      backgroundColor:
                      Colors.white,

                      child: Text(

                        usuario?.email
                            ?.substring(0, 1)
                            .toUpperCase()

                            ??

                            'A',

                        style:
                        const TextStyle(

                          fontSize: 30,

                          fontWeight:
                          FontWeight.bold,

                          color:
                          Color(0xFFD9A5B3),
                        ),
                      ),
                    ),

                    const SizedBox(
                        width: 20),

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [

                          const Text(

                            'Bienvenido 💖',

                            style: TextStyle(

                              color:
                              Colors.white,

                              fontSize: 28,

                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height: 8),

                          Text(

                            usuario?.email ??
                                '',

                            style:
                            const TextStyle(

                              color:
                              Colors.white70,

                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          const Text(

                            'Sistema profesional de gestión para Koko Studio ✨',

                            style: TextStyle(

                              color:
                              Colors.white70,

                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // PANEL GENERAL

              const Text(

                'Panel General',

                style: TextStyle(

                  fontSize: 24,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              GridView.count(

                shrinkWrap: true,

                physics:
                const NeverScrollableScrollPhysics(),

                crossAxisCount: 2,

                crossAxisSpacing: 16,

                mainAxisSpacing: 16,

                childAspectRatio: 1,

                children: [

                  itemMenu(

                    context,

                    'Gestión de Citas',

                    Icons.calendar_month,

                    const CitasScreen(),
                  ),

                  itemMenu(

                    context,

                    'Calendario',

                    Icons.event,

                    const CalendarioScreen(),
                  ),

                  itemMenu(

                    context,

                    'Personal',

                    Icons.groups,

                    const TrabajadorasScreen(),
                  ),

                  itemMenu(

                    context,

                    'Servicios',

                    Icons.design_services,

                    const ServiciosScreen(),
                  ),

                  itemMenu(

                    context,

                    'Estadísticas',

                    Icons.bar_chart,

                    const EstadisticasScreen(),
                  ),

                  itemMenu(

                    context,

                    'Historial',

                    Icons.history,

                    const HistorialScreen(),
                  ),

                  itemMenu(

                    context,

                    'Alertas',

                    Icons.notifications_active,

                    const AlertasAdminScreen(),
                  ),



                  itemMenu(

                    context,

                    'Método Pago',

                    Icons.payment,

                    const PagosScreen(),
                  ),

                  itemMenu(

                    context,

                    'Mi Perfil',

                    Icons.person,

                    const ProfileScreen(),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(
                    25),

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
                          .withOpacity(
                          0.05),

                      blurRadius: 10,

                      offset:
                      const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(

                  children: [

                    Icon(

                      Icons.favorite,

                      color:
                      Colors.pink,

                      size: 45,
                    ),

                    const SizedBox(
                        height: 15),

                    Text(

                      'Koko Studio',

                      style: TextStyle(

                        fontSize: 28,

                        fontWeight:
                        FontWeight.bold,

                        color:
                        Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color,
                      ),
                    ),

                    const SizedBox(
                        height: 10),

                    const Text(

                      'Sistema premium de gestión de citas, servicios y trabajadoras 💖',

                      textAlign:
                      TextAlign.center,

                      style: TextStyle(

                        fontSize: 16,

                        color:
                        Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemMenu(

      BuildContext context,

      String titulo,
      IconData icono,
      Widget pantalla,

      ) {

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          PageTransitionAnimation
              .crearTransicion(

            pantalla,
          ),
        );
      },

      child: Container(

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
                  .withOpacity(
                  0.05),

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

            CircleAvatar(

              radius: 30,

              backgroundColor:
              const Color(0xFFD9A5B3)
                  .withOpacity(0.15),

              child: Icon(

                icono,

                color:
                const Color(0xFFD9A5B3),

                size: 32,
              ),
            ),

            const SizedBox(height: 15),

            Padding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 5,
              ),

              child: Text(

                titulo,

                textAlign:
                TextAlign.center,

                style: TextStyle(

                  fontSize: 15,

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
          ],
        ),
      ),
    );
  }

  Widget resumenCard(

      BuildContext context,

      String titulo,
      String valor,
      IconData icono,
      Color color,

      ) {

    return Container(

      padding:
      const EdgeInsets.all(20),

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
                .withOpacity(
                0.05),

            blurRadius: 10,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(

        children: [

          CircleAvatar(

            radius: 24,

            backgroundColor:
            color.withOpacity(0.15),

            child: Icon(

              icono,

              color: color,
            ),
          ),

          const SizedBox(height: 15),

          Text(

            valor,

            style: TextStyle(

              fontSize: 24,

              fontWeight:
              FontWeight.bold,

              color: color,
            ),
          ),

          const SizedBox(height: 5),

          Text(

            titulo,

            style: TextStyle(

              color:
              Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget drawerItem(

      BuildContext context,

      IconData icono,
      String texto,
      Widget pantalla,

      ) {

    return ListTile(

      leading:
      Icon(icono),

      title:
      Text(texto),

      onTap: () {

        Navigator.push(

          context,

          PageTransitionAnimation
              .crearTransicion(

            pantalla,
          ),
        );
      },
    );
  }
}
