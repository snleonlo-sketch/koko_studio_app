import 'package:flutter/material.dart';
import '../services/firestore_database_shim.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/koko_config.dart';

class ServiciosClienteScreen
    extends StatefulWidget {

  const ServiciosClienteScreen({
    super.key,
  });

  @override
  State<ServiciosClienteScreen>
  createState() =>
      _ServiciosClienteScreenState();
}

class _ServiciosClienteScreenState
    extends State<ServiciosClienteScreen> {

  final DatabaseReference database =
  FirebaseDatabase.instance.ref();

  final usuario =
      FirebaseAuth.instance.currentUser;

  final TextEditingController
  buscarController =
  TextEditingController();

  String textoBusqueda = '';

  String sedeSeleccionada =
      KokoConfig.sedes.first;

  String nombreCliente = '';

  @override
  void initState() {

    super.initState();

    cargarCliente();
  }

  Future<void> cargarCliente() async {

    final uid =
        usuario?.uid;

    if (uid == null) return;

    final snapshot =
    await database
        .child('usuarios')
        .child(uid)
        .get();

    if (snapshot.exists) {

      final datos =
      snapshot.value as Map;

      setState(() {

        nombreCliente =
            datos['nombre'] ?? '';

        sedeSeleccionada =
            datos['sedePreferida'] ??
                KokoConfig.sedes.first;
      });
    }
  }

  Future<void> consultarServicio(String servicio) async {
    final nombre = nombreCliente.isNotEmpty ? nombreCliente : 'cliente';

    final mensaje = 'Hola Koko Studio, soy $nombre.\n\n'
        'Quisiera consultar por el servicio: $servicio.\n'
        'Sede de interes: $sedeSeleccionada.\n'
        'Me gustaria recibir orientacion sobre disponibilidad, '
        'tiempo aproximado y precio segun mi diseno.';

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

    return Scaffold(

      backgroundColor:
      Theme.of(context)
          .scaffoldBackgroundColor,

      appBar: AppBar(

        elevation: 0,

        centerTitle: true,

        title: const Text(

          'Servicios',

          style: TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child: Column(

          children: [

            Padding(

              padding:
              const EdgeInsets.all(20),

              child: Column(

                children: [

                  Container(

                    width: double.infinity,

                    padding:
                    const EdgeInsets.all(
                        25),

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
                          const Offset(
                              0,
                              8),
                        ),
                      ],
                    ),

                    child: const Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(

                          'Nuestros Servicios ',

                          style: TextStyle(

                            color:
                            Colors.white,

                            fontSize: 28,

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 10),

                        Text(

                          'Consulta disponibilidad y precio segun tu diseño',

                          style: TextStyle(

                            color:
                            Colors.white70,

                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(

                    controller:
                    buscarController,

                    onChanged:
                        (value) {

                      setState(() {

                        textoBusqueda =
                            value;
                      });
                    },

                    decoration:
                    InputDecoration(

                      hintText:
                      'Buscar servicio',

                      prefixIcon:
                      const Icon(
                        Icons.search,
                      ),

                      filled: true,

                      fillColor:
                      Theme.of(context)
                          .cardColor,

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                            15),

                        borderSide:
                        BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(

              child: StreamBuilder(

                stream:
                database
                    .child('servicios')
                    .onValue,

                builder:
                    (context, snapshot) {

                  if (!snapshot.hasData) {

                    return const Center(

                      child:
                      CircularProgressIndicator(),
                    );
                  }

                  final data =
                      snapshot.data!
                          .snapshot
                          .value;

                  if (data == null) {

                    return const Center(

                      child: Text(

                        'No hay servicios disponibles',

                        style: TextStyle(

                          fontSize: 18,

                          color:
                          Colors.grey,
                        ),
                      ),
                    );
                  }

                  Map servicios =
                  data as Map;

                  List items =
                  servicios.entries
                      .toList();

                  items =
                      items.where((item) {

                    final servicio =
                        item.value;

                    final sede =
                        (servicio['sede'] ?? '')
                            .toString();

                    return sede.isEmpty ||
                        sede == sedeSeleccionada;
                  }).toList();

                  if (textoBusqueda
                      .isNotEmpty) {

                    items =
                        items.where((item) {

                          final servicio =
                              item.value;

                          return servicio['nombre']
                              .toString()
                              .toLowerCase()
                              .contains(

                            textoBusqueda
                                .toLowerCase(),
                          );
                        }).toList();
                  }

                  return ListView.builder(

                    padding:
                    const EdgeInsets.all(
                        20),

                    itemCount:
                    items.length,

                    itemBuilder:
                        (context, index) {

                      final item =
                      items[index];

                      final servicio =
                          item.value;

                      return tarjetaServicio(
                        servicio,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tarjetaServicio(
      Map servicio) {

    return Container(

      margin:
      const EdgeInsets.only(
        bottom: 20,
      ),

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

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          if (servicio['imagen'] !=
              null &&
              servicio['imagen'] !=
                  '')

            ClipRRect(

              borderRadius:
              const BorderRadius.only(

                topLeft:
                Radius.circular(25),

                topRight:
                Radius.circular(25),
              ),

              child: Image.network(

                servicio['imagen'],

                height: 220,

                width:
                double.infinity,

                fit:
                BoxFit.cover,
              ),
            ),

          Padding(

            padding:
            const EdgeInsets.all(
                20),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [

                Row(

                  children: [

                    Expanded(

                      child: Text(

                        servicio['nombre'] ??
                            '',

                        style:
                        const TextStyle(

                          fontSize:
                          24,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                  ],
                ),

                const SizedBox(
                    height: 15),

                Text(

                  servicio['descripcion']
                      ?? '',

                  style:
                  const TextStyle(

                    fontSize: 16,

                    color:
                    Colors.grey,
                  ),
                ),

                const SizedBox(
                    height: 15),

                Row(

                  children: [

                    Container(

                      padding:
                      const EdgeInsets.symmetric(

                        horizontal:
                        15,

                        vertical:
                        10,
                      ),

                      decoration:
                      BoxDecoration(

                        color:
                        Colors.pink
                            .withOpacity(
                            0.1),

                        borderRadius:
                        BorderRadius.circular(
                            20),
                      ),

                      child: Row(

                        children: [

                          const Icon(

                            Icons.timer,

                            color:
                            Colors.pink,
                          ),

                          const SizedBox(
                              width:
                              8),

                          Text(

                            servicio['duracion']
                                ?? '',

                            style:
                            const TextStyle(

                              fontWeight:
                              FontWeight.bold,

                              color:
                              Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    ElevatedButton.icon(

                      onPressed: () {

                        consultarServicio(
                          servicio['nombre'] ?? '',
                        );

                        ScaffoldMessenger
                            .of(context)
                            .showSnackBar(

                          SnackBar(

                            backgroundColor:
                            const Color(
                                0xFFD9A5B3),

                            content:
                            Text(

                              'Seleccionaste '
                                  '${servicio['nombre']} ',
                            ),
                          ),
                        );
                      },

                      style:
                      ElevatedButton.styleFrom(

                        backgroundColor:
                        const Color(
                            0xFFD9A5B3),

                        shape:
                        RoundedRectangleBorder(

                          borderRadius:
                          BorderRadius.circular(
                              15),
                        ),
                      ),

                      icon: const Icon(

                        Icons.message,

                        color:
                        Colors.white,
                      ),

                      label: const Text(

                        'Consultar',

                        style: TextStyle(

                          color:
                          Colors.white,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


