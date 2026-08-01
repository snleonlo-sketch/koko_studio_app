import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/koko_config.dart';
import '../utils/page_transition.dart';

import 'dashboard_cliente_screen.dart';

class SeleccionarSedeScreen extends StatefulWidget {
  const SeleccionarSedeScreen({
    super.key,
  });

  @override
  State<SeleccionarSedeScreen> createState() =>
      _SeleccionarSedeScreenState();
}

class _SeleccionarSedeScreenState
    extends State<SeleccionarSedeScreen> {
  final usuario =
      FirebaseAuth.instance.currentUser;

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  bool guardando = false;

  Future<void> seleccionarSede(String sede) async {
    final uid =
        usuario?.uid;

    if (uid == null) return;

    setState(() {
      guardando = true;
    });

    await firestore
        .collection('usuarios')
        .doc(uid)
        .set({
      'sedePreferida': sede,
    }, SetOptions(merge: true));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageTransitionAnimation.crearTransicion(
        const DashboardClienteScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              const Text(
                'Elige tu sede',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Selecciona donde deseas atenderte hoy. Podras cambiarlo luego desde tu perfil.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 35),
              ...KokoConfig.sedes.map((sede) {
                final icono =
                    sede == 'Comas'
                        ? Icons.storefront
                        : Icons.spa;

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 18,
                  ),
                  child: GestureDetector(
                    onTap:
                        guardando
                            ? null
                            : () => seleccionarSede(sede),
                    child: Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFFD9A5B3),
                            Color(0xFFEFC3CF),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.pink.withOpacity(0.15),
                            blurRadius: 15,
                            offset:
                                const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor:
                                Colors.white,
                            child: Icon(
                              icono,
                              color:
                                  const Color(0xFFD9A5B3),
                              size: 34,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Text(
                              'Sede $sede',
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(),
              if (guardando)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFD9A5B3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

