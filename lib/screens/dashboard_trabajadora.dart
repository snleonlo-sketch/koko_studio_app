import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_database_shim.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';

import '../utils/page_transition.dart';
import '../services/role_service.dart';

import 'citas_screen.dart';
import 'calendario_screen.dart';
import 'profile_screen.dart';
import 'pagos_screen.dart';
import 'clientas_atendidas_screen.dart';

class DashboardTrabajadoraScreen
    extends StatefulWidget {

  const DashboardTrabajadoraScreen({
    super.key,
  });

  @override
  State<DashboardTrabajadoraScreen>
  createState() =>
      _DashboardTrabajadoraScreenState();
}

class _DashboardTrabajadoraScreenState
    extends State<DashboardTrabajadoraScreen> {

  final usuario =
      FirebaseAuth.instance.currentUser;

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final RoleService roleService =
  RoleService();

  String nombreTrabajadora = '';

  String sedeTrabajadora = '';

  @override
  void initState() {
    super.initState();
    cargarDatosTrabajadora();
  }

  Future<void> cargarDatosTrabajadora() async {
    final datos = await roleService.obtenerDatosUsuario();
    if (mounted) {
      setState(() {
        nombreTrabajadora = datos['nombre'] ?? '';
        sedeTrabajadora = datos['sede'] ?? '';
      });
    }
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

                      'T',

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

                'Trabajadora',

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

              'Mis Citas',

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

              Icons.history,

              'Clientas Atendidas',

              const ClientasAtendidasScreen(),
            ),

            drawerItem(

              context,

              Icons.payment,

              'Método de Pago',

              const PagosScreen(),
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

          'Panel Trabajadora',

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

                        usuario?.email
                            ?.substring(0, 1)
                            .toUpperCase()

                            ??

                            'T',

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

                            'Bienvenida ',

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

                            'Gestiona tus citas y atención profesionalmente ',

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

                    'Mis Citas',

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

                    'Clientas Atendidas',

                    Icons.people,

                    const ClientasAtendidasScreen(),
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

                      'Sistema profesional de gestión de citas ',

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


