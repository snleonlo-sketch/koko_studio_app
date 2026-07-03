import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../themes/theme_provider.dart';
import '../utils/page_transition.dart';

import 'calendario_screen.dart';
import 'citas_screen.dart';
import 'historial_screen.dart';
import 'pagos_screen.dart';
import 'profile_screen.dart';

class DashboardRecepcionScreen extends StatelessWidget {
  const DashboardRecepcionScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final usuario =
        FirebaseAuth.instance.currentUser;

    final themeProvider =
        Provider.of<ThemeProvider>(context);

    final oscuro =
        themeProvider.esOscuro;

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      drawer: Drawer(
        child: SafeArea(
          bottom: true,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD9A5B3),
                      Color(0xFFEFC3CF),
                    ],
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    usuario?.email
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        'R',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD9A5B3),
                    ),
                  ),
                ),
                accountName: const Text(
                  'Recepcionista',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  usuario?.email ?? '',
                ),
              ),
              _drawerItem(
                context,
                Icons.calendar_month,
                'Gestión de Citas',
                const CitasScreen(),
              ),

              _drawerItem(
                context,
                Icons.event,
                'Calendario',
                const CalendarioScreen(),
              ),
              _drawerItem(
                context,
                Icons.history,
                'Historial',
                const HistorialScreen(),
              ),
              _drawerItem(
                context,
                Icons.payment,
                'Método de Pago',
                const PagosScreen(),
              ),
              _drawerItem(
                context,
                Icons.person,
                'Mi Perfil',
                const ProfileScreen(),
              ),
              const Spacer(),
              SwitchListTile(
                value: oscuro,
                activeColor: const Color(0xFFD9A5B3),
                title: const Text('Modo Oscuro'),
                secondary: Icon(
                  oscuro
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onChanged: (_) {
                  themeProvider.cambiarTema();
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
          'Panel Recepcion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                PageTransitionAnimation.crearTransicion(
                  const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD9A5B3),
                      Color(0xFFEFC3CF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Text(
                        usuario?.email
                                ?.substring(0, 1)
                                .toUpperCase() ??
                            'R',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD9A5B3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recepcion Koko Studio',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            usuario?.email ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Agenda, pagos y seguimiento de citas.',
                            style: TextStyle(
                              color: Colors.white70,
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
                'Operaciones',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _itemMenu(
                    context,
                    'Gestión de Citas',
                    Icons.calendar_month,
                    const CitasScreen(),
                  ),
                  _itemMenu(
                    context,
                    'Calendario',
                    Icons.event,
                    const CalendarioScreen(),
                  ),
                  _itemMenu(
                    context,
                    'Historial',
                    Icons.history,
                    const HistorialScreen(),
                  ),
                  _itemMenu(
                    context,
                    'Método Pago',
                    Icons.payment,
                    const PagosScreen(),
                  ),
                ],
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemMenu(
    BuildContext context,
    String titulo,
    IconData icono,
    Widget pantalla,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageTransitionAnimation.crearTransicion(
            pantalla,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor:
                  const Color(0xFFD9A5B3).withOpacity(0.15),
              child: Icon(
                icono,
                color: const Color(0xFFD9A5B3),
                size: 32,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context)
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

  Widget _drawerItem(
    BuildContext context,
    IconData icono,
    String texto,
    Widget pantalla,
  ) {
    return ListTile(
      leading: Icon(icono),
      title: Text(texto),
      onTap: () {
        Navigator.push(
          context,
          PageTransitionAnimation.crearTransicion(
            pantalla,
          ),
        );
      },
    );
  }
}
