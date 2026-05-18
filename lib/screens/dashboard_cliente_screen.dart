import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

import '../utils/page_transition.dart';

import 'reservar_cita_screen.dart';
import 'servicios_cliente_screen.dart';
import 'historial_screen.dart';
import 'profile_screen.dart';
import 'pagos_screen.dart';

class DashboardClienteScreen
    extends StatefulWidget {

  const DashboardClienteScreen({
    super.key,
  });

  @override
  State<DashboardClienteScreen>
  createState() =>
      _DashboardClienteScreenState();
}

class _DashboardClienteScreenState
    extends State<DashboardClienteScreen> {

  final usuario =
      FirebaseAuth.instance.currentUser;

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  String nombreCliente = '';

  int totalReservas = 0;

  int totalServicios = 0;

  int citasPendientes = 0;

  @override
  void initState() {

    super.initState();

    cargarDatos();
  }

  Future<void>
  cargarDatos() async {

    final uid =
        usuario?.uid;

    if (uid == null) return;

    // DATOS CLIENTE

    final usuarioSnapshot =

    await database
        .child('usuarios')
        .child(uid)
        .get();

    if (usuarioSnapshot.exists) {

      Map datos =
      usuarioSnapshot.value as Map;

      nombreCliente =
          datos['nombre'] ?? '';
    }

    // SERVICIOS

    database
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

    // CITAS CLIENTE

    database
        .child('citas')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      totalReservas = 0;

      citasPendientes = 0;

      if (data != null) {

        Map citas =
        data as Map;

        citas.forEach((key, value) {

          if (value['clienteUid']
              == uid) {

            totalReservas++;

            if (value['estado']
                == 'pendiente') {

              citasPendientes++;
            }
          }
        });
      }

      setState(() {});
    });

    setState(() {});
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

                  nombreCliente
                      .isNotEmpty

                      ? nombreCliente
                      .substring(0, 1)
                      .toUpperCase()

                      : 'C',

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
              Text(

                nombreCliente,

                style: const TextStyle(

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

              'Reservar Cita',

              const ReservarCitaScreen(),
            ),

            drawerItem(

              context,

              Icons.design_services,

              'Servicios',

              const ServiciosClienteScreen(),
            ),

            drawerItem(

              context,

              Icons.history,

              'Mis Reservas',

              const HistorialScreen(),
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

            const SizedBox(height: 10),
          ],
        ),
      ),

      appBar: AppBar(

        elevation: 0,

        centerTitle: true,

        title: const Text(

          'Panel Cliente',

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

                decoration:
                BoxDecoration(

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

                        nombreCliente
                            .isNotEmpty

                            ? nombreCliente
                            .substring(0, 1)
                            .toUpperCase()

                            : 'C',

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

                          Text(

                            'Hola $nombreCliente 💖',

                            style: const TextStyle(

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

                            'Reserva tus servicios favoritos fácilmente ✨',

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

              const Text(

                'Panel Principal',

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

                    'Reservar Cita',

                    Icons.calendar_month,

                    const ReservarCitaScreen(),
                  ),

                  itemMenu(

                    context,

                    'Servicios',

                    Icons.design_services,

                    const ServiciosClienteScreen(),
                  ),

                  itemMenu(

                    context,

                    'Mis Reservas',

                    Icons.history,

                    const HistorialScreen(),
                  ),

                  itemMenu(

                    context,

                    'Método Pago',

                    Icons.payment,

                    const PagosScreen(),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(

                'Resumen General',

                style: TextStyle(

                  fontSize: 24,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Row(

                children: [

                  Expanded(

                    child: resumenCard(

                      context,

                      'Reservas',

                      totalReservas
                          .toString(),

                      Icons.calendar_month,

                      Colors.pink,
                    ),
                  ),

                  const SizedBox(
                      width: 15),

                  Expanded(

                    child: resumenCard(

                      context,

                      'Servicios',

                      totalServicios
                          .toString(),

                      Icons.design_services,

                      Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(

                children: [

                  Expanded(

                    child: resumenCard(

                      context,

                      'Pendientes',

                      citasPendientes
                          .toString(),

                      Icons.access_time,

                      Colors.purple,
                    ),
                  ),

                  const SizedBox(
                      width: 15),

                  Expanded(

                    child: resumenCard(

                      context,

                      'Cliente',

                      'VIP',

                      Icons.favorite,

                      Colors.green,
                    ),
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

                      'Gracias por confiar en nosotros 💖',

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