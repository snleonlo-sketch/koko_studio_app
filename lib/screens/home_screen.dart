import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/role_service.dart';

import 'dashboard_screen.dart';
import 'dashboard_trabajadora.dart';

import 'citas_screen.dart';
import 'historial_screen.dart';
import 'profile_screen.dart';

class HomeScreen
    extends StatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen>
  createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  int paginaActual = 0;

  bool cargando = true;

  String rol = '';

  List<Widget> paginas = [];

  @override
  void initState() {

    super.initState();

    cargarRol();
  }

  Future<void> cargarRol() async {

    try {

      String rolUsuario =

      await RoleService()
          .obtenerRol();

      setState(() {

        rol = rolUsuario;

        if (rol == 'admin') {

          paginas = [

            const DashboardScreen(),

            const CitasScreen(),

            HistorialScreen(),

            const ProfileScreen(),
          ];

        } else {

          paginas = [

            const DashboardTrabajadoraScreen(),

            const CitasScreen(),

            HistorialScreen(),

            const ProfileScreen(),
          ];
        }

        cargando = false;
      });

    } catch (e) {

      setState(() {

        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    if (cargando) {

      return const Scaffold(

        body: Center(

          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      body:
      IndexedStack(

        index:
        paginaActual,

        children:
        paginas,
      ),

      bottomNavigationBar:

      Container(

        decoration: BoxDecoration(

          boxShadow: [

            BoxShadow(

              color:
              Colors.black
                  .withOpacity(0.08),

              blurRadius: 12,

              offset:
              const Offset(0, -2),
            ),
          ],
        ),

        child: BottomNavigationBar(

          currentIndex:
          paginaActual,

          onTap: (index) {

            setState(() {

              paginaActual = index;
            });
          },

          type:
          BottomNavigationBarType.fixed,

          selectedItemColor:
          const Color(0xFFD9A5B3),

          unselectedItemColor:
          Colors.grey,

          backgroundColor:
          Theme.of(context)
              .cardColor,

          elevation: 10,

          selectedLabelStyle:
          const TextStyle(

            fontWeight:
            FontWeight.bold,
          ),

          items: [

            const BottomNavigationBarItem(

              icon:
              Icon(Icons.home),

              label:
              'Inicio',
            ),

            const BottomNavigationBarItem(

              icon:
              Icon(Icons.calendar_month),

              label:
              'Citas',
            ),

            const BottomNavigationBarItem(

              icon:
              Icon(Icons.history),

              label:
              'Historial',
            ),

            BottomNavigationBarItem(

              icon: CircleAvatar(

                radius: 14,

                backgroundColor:
                const Color(0xFFD9A5B3),

                child: Text(

                  FirebaseAuth
                      .instance
                      .currentUser
                      ?.email
                      ?.substring(0, 1)
                      .toUpperCase()

                      ??

                      'U',

                  style:
                  const TextStyle(

                    color:
                    Colors.white,

                    fontWeight:
                    FontWeight.bold,

                    fontSize: 14,
                  ),
                ),
              ),

              label:
              'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}