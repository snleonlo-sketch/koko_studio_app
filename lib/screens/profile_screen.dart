import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/koko_config.dart';
import '../services/role_service.dart';

import 'login_screen.dart';

class ProfileScreen
    extends StatefulWidget {

  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  final user =
      FirebaseAuth.instance.currentUser;

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final RoleService roleService =
      RoleService();

  String nombre = '';

  String telefono = '';

  String rol = '';

  String sedePreferida =
      KokoConfig.sedes.first;

  bool cargando = true;

  @override
  void initState() {

    super.initState();

    cargarDatos();
  }

  Future<void> cargarDatos() async {

    try {

      if (user != null) {

        final datos =
            await roleService.obtenerDatosUsuario();

          nombre =
              datos['nombre'] ?? '';

          telefono =
              datos['telefono'] ?? '';

          rol =
              datos['rol'] ?? '';

          sedePreferida =
              datos['sedePreferida'] ??
                  datos['sede'] ??
                  KokoConfig.sedes.first;
      }

      setState(() {

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

      backgroundColor:
      const Color(0xFFFFF5F7),

      appBar: AppBar(

        title: const Text(

          'Mi Perfil',

          style: TextStyle(

            color: Colors.black,

            fontWeight:
            FontWeight.bold,
          ),
        ),

        backgroundColor:
        const Color(0xFFD9A5B3),
      ),

      body: SingleChildScrollView(

        child: Padding(

          padding:
          const EdgeInsets.all(25),

          child: Column(

            children: [

              const SizedBox(height: 20),

              Container(

                padding:
                const EdgeInsets.all(25),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(25),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black.withOpacity(0.05),

                      blurRadius: 10,

                      offset:
                      const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(

                  children: [

                    const CircleAvatar(

                      radius: 60,

                      backgroundColor:
                      Color(0xFFD9A5B3),

                      child: Icon(

                        Icons.person,

                        size: 70,

                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(

                      nombre.isEmpty
                          ? 'Usuario'
                          : nombre,

                      style: const TextStyle(

                        fontSize: 28,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(

                      user?.email ??
                          'Sin correo',

                      style: const TextStyle(

                        fontSize: 17,

                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(

                      padding:
                      const EdgeInsets.symmetric(

                        horizontal: 20,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(

                        color:
                        const Color(0xFFD9A5B3),

                        borderRadius:
                        BorderRadius.circular(30),
                      ),

                      child: Text(

                        rol.toUpperCase(),

                        style: const TextStyle(

                          color: Colors.white,

                          fontWeight:
                          FontWeight.bold,

                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Container(

                padding:
                const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                  boxShadow: [

                    BoxShadow(

                      color:
                      Colors.black.withOpacity(0.05),

                      blurRadius: 10,

                      offset:
                      const Offset(0, 4),
                    ),
                  ],
                ),

                child: Column(

                  children: [

                    itemInfo(

                      Icons.store,

                      'Negocio',

                      'Koko Studio',
                    ),

                    const Divider(),

                    itemInfo(

                      Icons.phone,

                      'Teléfono',

                      telefono.isEmpty
                          ? 'Sin telefono registrado'
                          : telefono,
                    ),

                    const Divider(),

                    itemInfo(

                      Icons.location_on,

                      'Ubicación',

                      'Lima, Perú',
                    ),

                    if (rol == 'cliente') ...[

                      const Divider(),

                      itemInfo(

                        Icons.storefront,

                        'Sede preferida',

                        sedePreferida,
                      ),

                      const SizedBox(height: 12),

                      Wrap(

                        spacing: 10,

                        children:
                        KokoConfig.sedes.map((sede) {

                          final seleccionada =
                              sede == sedePreferida;

                          return ChoiceChip(

                            selected:
                            seleccionada,

                            label:
                            Text(sede),

                            selectedColor:
                            const Color(0xFFD9A5B3),

                            labelStyle:
                            TextStyle(

                              color:
                              seleccionada
                                  ? Colors.white
                                  : Colors.black87,

                              fontWeight:
                              FontWeight.bold,
                            ),

                            onSelected: (_) async {

                              if (user == null) return;

                              await database
                                  .child('usuarios')
                                  .child(user!.uid)
                                  .update({

                                'sedePreferida': sede,
                              });

                              setState(() {

                                sedePreferida = sede;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton.icon(

                  onPressed: () async {

                    await FirebaseAuth
                        .instance
                        .signOut();

                    Navigator.pushAndRemoveUntil(

                      context,

                      MaterialPageRoute(

                        builder: (context) =>

                        const LoginScreen(),
                      ),

                          (route) => false,
                    );
                  },

                  icon: const Icon(

                    Icons.logout,

                    color: Colors.white,
                  ),

                  label: const Text(

                    'Cerrar Sesión',

                    style: TextStyle(

                      color: Colors.white,

                      fontWeight:
                      FontWeight.bold,

                      fontSize: 16,
                    ),
                  ),

                  style:
                  ElevatedButton.styleFrom(

                    backgroundColor:
                    Colors.red,

                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemInfo(

      IconData icono,
      String titulo,
      String valor,

      ) {

    return Row(

      children: [

        CircleAvatar(

          backgroundColor:
          const Color(0xFFD9A5B3),

          child: Icon(

            icono,

            color: Colors.white,
          ),
        ),

        const SizedBox(width: 15),

        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Text(

              titulo,

              style: const TextStyle(

                color: Colors.grey,

                fontSize: 14,
              ),
            ),

            const SizedBox(height: 5),

            Text(

              valor,

              style: const TextStyle(

                fontSize: 16,

                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
