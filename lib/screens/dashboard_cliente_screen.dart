import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_database_shim.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../themes/theme_provider.dart';

import '../utils/page_transition.dart';
import '../utils/koko_config.dart';

import 'servicios_cliente_screen.dart';
import 'mis_citas_cliente_screen.dart';
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

  String telefonoCliente = '';

  int totalReservas = 0;

  int totalServicios = 0;

  int citasConfirmadas = 0;

  String sedeSeleccionada =
      KokoConfig.sedes.first;

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

    await recargarDatosCliente();

    // CITAS CLIENTE

    database
        .child('citas')
        .onValue
        .listen((event) {

      final data =
          event.snapshot.value;

      totalReservas = 0;

      totalServicios = 0;

      citasConfirmadas = 0;

      final serviciosCliente =
      <String>{};

      if (data != null) {

        Map citas =
        data as Map;

        citas.forEach((key, value) {

          final telefonoCita =
              (value['telefono'] ?? '')
                  .toString()
                  .replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );

          final telefonoUsuario =
              telefonoCliente
                  .replaceAll(
                RegExp(r'[^0-9]'),
                '',
              );

          final esCitaCliente =
              value['clienteUid'] == uid ||
                  (telefonoUsuario.isNotEmpty &&
                      telefonoCita == telefonoUsuario);

          if (esCitaCliente) {

            totalReservas++;

            final servicio =
                (value['servicio'] ?? '')
                    .toString();

            if (servicio.isNotEmpty) {

              serviciosCliente.add(servicio);
            }

            if (value['estado']
                == 'confirmada') {

              citasConfirmadas++;
            }
          }
        });

        totalServicios =
            serviciosCliente.length;
      }

      setState(() {});
    });

    setState(() {});
  }

  Future<void> recargarDatosCliente() async {

    final uid =
        usuario?.uid;

    if (uid == null) return;

    final usuarioSnapshot =

    await database
        .child('usuarios')
        .child(uid)
        .get();

    if (usuarioSnapshot.exists) {

      Map datos =
      usuarioSnapshot.value as Map;

      setState(() {

        nombreCliente =
            datos['nombre'] ?? '';

        telefonoCliente =
            datos['telefono'] ?? '';

        sedeSeleccionada =
            datos['sedePreferida'] ??
                KokoConfig.sedes.first;
      });
    }
  }

  Future<void> guardarSede(
      String sede) async {

    final uid =
        usuario?.uid;

    setState(() {

      sedeSeleccionada = sede;
    });

    if (uid == null) return;

    await database
        .child('usuarios')
        .child(uid)
        .update({

      'sedePreferida': sede,
    });
  }

  Future<void> solicitarPorWhatsApp({
    String? servicio,
  }) async {
    final nombre = nombreCliente.isNotEmpty ? nombreCliente : 'cliente';

    final mensaje = 'Hola Koko Studio, soy $nombre.\n\n'
        'Quisiera consultar una cita en la sede $sedeSeleccionada.\n'
        '${servicio != null ? 'Servicio de interes: $servicio.\n' : ''}'
        'Me gustaria recibir orientacion sobre disponibilidad, '
        'tiempo aproximado y precio segun el diseno.';

    String numeroDestino = KokoConfig.whatsappPorSede(sedeSeleccionada);
    try {
      final snapshot = await database.child('trabajadoras').get();
      if (snapshot.exists && snapshot.value != null) {
        final Map trabajadorasMap = snapshot.value as Map;
        for (var entry in trabajadorasMap.values) {
          final Map map = entry as Map;
          final rol = (map['rol'] ?? '').toString().toLowerCase();
          final sede = (map['sede'] ?? '').toString().toLowerCase();
          final tel = (map['telefono'] ?? '').toString().trim();
          if (rol == 'recepcionista' &&
              sede == sedeSeleccionada.toLowerCase() &&
              tel.isNotEmpty) {
            String cleanTel = tel.replaceAll(RegExp(r'[^0-9]'), '');
            if (cleanTel.length == 9) {
              cleanTel = '51$cleanTel';
            }
            if (cleanTel.isNotEmpty) {
              numeroDestino = cleanTel;
              break;
            }
          }
        }
      }
    } catch (e) {
      print('Error al obtener numero de recepcionista: $e');
    }

    final uri = Uri.parse(
      'https://wa.me/$numeroDestino?text=${Uri.encodeComponent(mensaje)}',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
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

              'Solicitar por WhatsApp',

              null,
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

              'Mis Citas',

              const MisCitasClienteScreen(),
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
              ).then((_) {

                recargarDatosCliente();
              });
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

                            'Hola $nombreCliente ',

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

                            'Elige tu sede y consulta tu cita por WhatsApp',

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

              condicionesCard(),

              const SizedBox(height: 30),

              const Text(

                'Accesos principales',

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

                    'Solicitar por WhatsApp',

                    Icons.message,

                    null,
                  ),

                  itemMenu(

                    context,

                    'Servicios',

                    Icons.design_services,

                    const ServiciosClienteScreen(),
                  ),

                  itemMenu(

                    context,

                    'Mis Citas',

                    Icons.history,

                    const MisCitasClienteScreen(),
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

                'Tu actividad en Koko Studio',

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

                      'Confirmadas',

                      citasConfirmadas
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

                      sedeSeleccionada,

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

                      'Gracias por confiar en nosotros ',

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
      Widget? pantalla,

      ) {

    return GestureDetector(

      onTap: () {

        if (pantalla == null) {

          solicitarPorWhatsApp();

          return;
        }

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
      Widget? pantalla,

      ) {

    return ListTile(

      leading:
      Icon(icono),

      title:
      Text(texto),

      onTap: () {

        Navigator.pop(context);

        if (pantalla == null) {

          solicitarPorWhatsApp();

          return;
        }

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

  Widget sedeSelector() {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(20),

      decoration:
      BoxDecoration(

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

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Text(

            'Selecciona la sede donde deseas atenderte',

            style: TextStyle(

              fontSize: 17,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 15),

          Wrap(

            spacing: 12,

            runSpacing: 12,

            children:
            KokoConfig.sedes.map((sede) {

              final seleccionada =
                  sede == sedeSeleccionada;

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
                      : Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color,

                  fontWeight:
                  FontWeight.bold,
                ),

                onSelected:
                    (_) => guardarSede(sede),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget condicionesCard() {

    return Container(

      width: double.infinity,

      padding:
      const EdgeInsets.all(25),

      decoration:
      BoxDecoration(

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

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const Row(

            children: [

              Icon(

                Icons.info,

                color:
                Color(0xFFD9A5B3),
              ),

              SizedBox(width: 10),

              Expanded(

                child: Text(

                  'Condiciones para tu cita',

                  style: TextStyle(

                    fontSize: 22,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          const Text(

            KokoConfig.introCondiciones,

            style: TextStyle(

              fontSize: 15,

              color:
              Colors.grey,
            ),
          ),

          const SizedBox(height: 15),

          ...KokoConfig.condicionesCita.map((condicion) {

            return Padding(

              padding:
              const EdgeInsets.only(
                bottom: 10,
              ),

              child: Row(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  const Icon(

                    Icons.check_circle,

                    size: 18,

                    color:
                    Colors.green,
                  ),

                  const SizedBox(width: 10),

                  Expanded(

                    child: Text(

                      condicion,

                      style:
                      const TextStyle(

                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}


