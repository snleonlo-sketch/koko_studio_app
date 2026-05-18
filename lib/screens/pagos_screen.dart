import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PagosScreen
    extends StatelessWidget {

  const PagosScreen({
    super.key,
  });

  Future<void>
  abrirYape() async {

    final Uri url = Uri.parse(
      'https://yape.com.pe/',
    );

    await launchUrl(
      url,
      mode:
      LaunchMode.externalApplication,
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

          'Métodos de Pago',

          style: TextStyle(

            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(

        child: SingleChildScrollView(

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

                      'Pagos Rápidos 💖',

                      style: TextStyle(

                        color:
                        Colors.white,

                        fontSize: 30,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(

                      'Realiza tus pagos de manera rápida, segura y sencilla.',

                      style: TextStyle(

                        color:
                        Colors.white70,

                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              const Text(

                'Métodos Disponibles',

                style: TextStyle(

                  fontSize: 24,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              metodoPago(

                context,

                titulo: 'Yape',

                subtitulo:
                'Escanea el código QR',

                imagen:
                'assets/images/yape.jpeg',

                color:
                Colors.purple,

                icono:
                Icons.qr_code,

                onTap:
                abrirYape,
              ),

              const SizedBox(height: 20),

              metodoPago(

                context,

                titulo: 'Transferencia',

                subtitulo:
                'Pago bancario seguro',

                imagen:
                'assets/images/yape.jpeg',

                color:
                Colors.green,

                icono:
                Icons.account_balance,

                onTap:
                    () {},
              ),

              const SizedBox(height: 35),

              Container(

                width: double.infinity,

                padding:
                const EdgeInsets.all(25),

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

                    Icon(

                      Icons.favorite,

                      color:
                      Colors.pink,

                      size: 45,
                    ),

                    const SizedBox(height: 15),

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

                    const SizedBox(height: 10),

                    const Text(

                      'Gracias por confiar en nosotros 💖',

                      textAlign:
                      TextAlign.center,

                      style: TextStyle(

                        fontSize: 17,

                        color:
                        Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget metodoPago(

      BuildContext context, {

        required String titulo,
        required String subtitulo,
        required String imagen,
        required Color color,
        required IconData icono,
        required VoidCallback onTap,

      }) {

    return Container(

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

          ClipRRect(

            borderRadius:
            const BorderRadius.only(

              topLeft:
              Radius.circular(25),

              topRight:
              Radius.circular(25),
            ),

            child: Image.asset(

              imagen,

              height: 220,

              width:
              double.infinity,

              fit:
              BoxFit.cover,
            ),
          ),

          Padding(

            padding:
            const EdgeInsets.all(20),

            child: Column(

              children: [

                Row(

                  children: [

                    Container(

                      padding:
                      const EdgeInsets.all(12),

                      decoration: BoxDecoration(

                        color:
                        color.withOpacity(0.15),

                        shape:
                        BoxShape.circle,
                      ),

                      child: Icon(

                        icono,

                        color:
                        color,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(

                      child: Column(

                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          Text(

                            titulo,

                            style: TextStyle(

                              fontSize: 22,

                              fontWeight:
                              FontWeight.bold,

                              color:
                              Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(

                            subtitulo,

                            style:
                            const TextStyle(

                              color:
                              Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(

                  width: double.infinity,

                  height: 50,

                  child: ElevatedButton.icon(

                    onPressed:
                    onTap,

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      color,

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(
                            15),
                      ),
                    ),

                    icon: const Icon(

                      Icons.open_in_new,

                      color:
                      Colors.white,
                    ),

                    label: const Text(

                      'Abrir Método de Pago',

                      style: TextStyle(

                        color:
                        Colors.white,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}