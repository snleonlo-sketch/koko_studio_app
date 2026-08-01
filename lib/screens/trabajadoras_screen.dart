import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../services/firestore_database_shim.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../utils/koko_config.dart';

class TrabajadorasScreen extends StatefulWidget {
  const TrabajadorasScreen({
    super.key,
  });

  @override
  State<TrabajadorasScreen> createState() => _TrabajadorasScreenState();
}

class _TrabajadorasScreenState extends State<TrabajadorasScreen> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController horaEntradaController = TextEditingController();
  final TextEditingController horaSalidaController = TextEditingController();

  bool cargando = false;

  String sedeSeleccionada = KokoConfig.sedes.first;

  String rolSeleccionado = 'trabajadora';

  final List<String> rolesOperativos = [
    'trabajadora',
    'recepcionista',
  ];

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    telefonoController.dispose();
    horaEntradaController.dispose();
    horaSalidaController.dispose();
    super.dispose();
  }

  Future<void> seleccionarHora(
    TextEditingController controller,
  ) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      controller.text = hora.format(context);
    }
  }

  Future<void> guardarTrabajadora() async {
    if (nombreController.text.trim().isEmpty ||
        correoController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        telefonoController.text.trim().isEmpty ||
        sedeSeleccionada.isEmpty ||
        rolSeleccionado.isEmpty ||
        horaEntradaController.text.trim().isEmpty ||
        horaSalidaController.text.trim().isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: 'Campos vacíos',
        desc: 'Complete todos los campos',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    setState(() {
      cargando = true;
    });

    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;
    User? usuarioCreado;

    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'crearPersonal${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: correoController.text.trim(),
        password: passwordController.text.trim(),
      );

      usuarioCreado = credential.user;
      await guardarPerfilPersonal(usuarioCreado!.uid);

      limpiarCampos();

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: 'Éxito',
        desc: 'Personal registrado correctamente',
        btnOkOnPress: () {},
      ).show();
    } on FirebaseAuthException catch (e) {
      String mensaje = 'No se pudo crear la cuenta';

      switch (e.code) {
        case 'email-already-in-use':
          final recuperado = await recuperarPerfilPersonalExistente(
            secondaryAuth,
          );

          if (recuperado) {
            limpiarCampos();

            if (!mounted) return;

            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: 'Perfil recuperado',
              desc:
                  'El correo ya existía en Authentication y ahora también quedó guardado en Personal.',
              btnOkOnPress: () {},
            ).show();
            return;
          }

          mensaje =
              'Ese correo ya existe en Authentication, pero no se pudo vincular con Personal. Verifica que la contraseña ingresada sea la misma de esa cuenta.';
          break;
        case 'invalid-email':
          mensaje = 'El correo no tiene un formato válido';
          break;
        case 'weak-password':
          mensaje = 'La contraseña debe tener al menos 6 caracteres';
          break;
        default:
          mensaje = e.message ?? mensaje;
      }

      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          desc: mensaje,
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        desc: '$e',
        btnOkOnPress: () {},
      ).show();
    } finally {
      try {
        if (usuarioCreado != null) {
          final doc = await firestore
              .collection('personal')
              .doc(usuarioCreado.uid)
              .get();

          if (!doc.exists) {
            await usuarioCreado.delete();
          }
        }

        await secondaryAuth?.signOut();
        await secondaryApp?.delete();
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }

  Future<void> guardarPerfilPersonal(String uid) async {
    await firestore.collection('personal').doc(uid).set({
      'nombre': nombreController.text.trim(),
      'correo': correoController.text.trim().toLowerCase(),
      'telefono': telefonoController.text.trim(),
      'rol': rolSeleccionado,
      'sede': sedeSeleccionada,
      'horaEntrada': horaEntradaController.text.trim(),
      'horaSalida': horaSalidaController.text.trim(),
      'activo': true,
      'authUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> recuperarPerfilPersonalExistente(
    FirebaseAuth? secondaryAuth,
  ) async {
    if (secondaryAuth == null) return false;

    try {
      final credential = await secondaryAuth.signInWithEmailAndPassword(
        email: correoController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user?.uid;
      if (uid == null) return false;

      await guardarPerfilPersonal(uid);
      return true;
    } catch (_) {
      return false;
    }
  }

  void limpiarCampos() {
    nombreController.clear();
    correoController.clear();
    passwordController.clear();
    telefonoController.clear();
    horaEntradaController.clear();
    horaSalidaController.clear();

    sedeSeleccionada = KokoConfig.sedes.first;
    rolSeleccionado = 'trabajadora';

    setState(() {});
  }

  Future<void> eliminarTrabajadora(String id) async {
    await database.child('trabajadoras').child(id).remove();

    if (!mounted) return;

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      title: 'Eliminada',
      desc: 'Registro eliminado correctamente',
      btnOkOnPress: () {},
    ).show();
  }

  Future<void> editarTrabajadora(
    String id,
    Map trabajadora,
  ) async {
    final nombreEditar = TextEditingController(
      text: (trabajadora['nombre'] ?? '').toString(),
    );
    final correoEditar = TextEditingController(
      text: (trabajadora['correo'] ?? '').toString(),
    );
    final telefonoEditar = TextEditingController(
      text: (trabajadora['telefono'] ?? '').toString(),
    );
    final horaEntradaEditar = TextEditingController(
      text: (trabajadora['horaEntrada'] ?? '').toString(),
    );
    final horaSalidaEditar = TextEditingController(
      text: (trabajadora['horaSalida'] ?? '').toString(),
    );

    String sedeEditar = KokoConfig.sedes.contains(trabajadora['sede'])
        ? trabajadora['sede']
        : KokoConfig.sedes.first;

    String rolEditar = rolesOperativos.contains(trabajadora['rol'])
        ? trabajadora['rol']
        : 'trabajadora';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text('Editar personal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    campoEditar(nombreEditar, 'Nombre'),
                    const SizedBox(height: 12),
                    campoEditar(correoEditar, 'Correo'),
                    const SizedBox(height: 12),
                    campoEditar(telefonoEditar, 'Teléfono'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: rolEditar,
                      decoration: decoracionInput(
                        'Rol',
                        Icons.badge,
                      ),
                      items: rolesOperativos.map((rol) {
                        return DropdownMenuItem(
                          value: rol,
                          child: Text(nombreRol(rol)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          rolEditar = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: sedeEditar,
                      decoration: decoracionInput(
                        'Sede',
                        Icons.store,
                      ),
                      items: KokoConfig.sedes.map((sede) {
                        return DropdownMenuItem(
                          value: sede,
                          child: Text(sede),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          sedeEditar = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        await seleccionarHora(horaEntradaEditar);
                        setDialogState(() {});
                      },
                      child: AbsorbPointer(
                        child: campoEditar(
                          horaEntradaEditar,
                          'Hora entrada',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        await seleccionarHora(horaSalidaEditar);
                        setDialogState(() {});
                      },
                      child: AbsorbPointer(
                        child: campoEditar(
                          horaSalidaEditar,
                          'Hora salida',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9A5B3),
                  ),
                  onPressed: () async {
                    await database.child('trabajadoras').child(id).update({
                      'nombre': nombreEditar.text.trim(),
                      'correo': correoEditar.text.trim(),
                      'telefono': telefonoEditar.text.trim(),
                      'rol': rolEditar,
                      'sede': sedeEditar,
                      'horaEntrada': horaEntradaEditar.text.trim(),
                      'horaSalida': horaSalidaEditar.text.trim(),
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Guardar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    nombreEditar.dispose();
    correoEditar.dispose();
    telefonoEditar.dispose();
    horaEntradaEditar.dispose();
    horaSalidaEditar.dispose();
  }

  void mostrarListaTrabajadoras() {
    String filtroSede = 'Todas';
    String filtroRol = 'Todos';
    String busqueda = '';
    final buscarListaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 18,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 18,
                ),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Personal operativo',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: buscarListaController,
                        decoration: decoracionInput(
                          'Buscar por nombre, correo o teléfono',
                          Icons.search,
                        ),
                        onChanged: (value) {
                          setSheetState(() {
                            busqueda = value.toLowerCase();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: filtroSede,
                              decoration: InputDecoration(
                                labelText: 'Sede',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: [
                                'Todas',
                                ...KokoConfig.sedes,
                              ].map((sede) {
                                return DropdownMenuItem(
                                  value: sede,
                                  child: Text(sede),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setSheetState(() {
                                  filtroSede = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: filtroRol,
                              decoration: InputDecoration(
                                labelText: 'Rol',
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: Theme.of(context).cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'Todos',
                                  child: Text('Todos'),
                                ),
                                ...rolesOperativos.map((rol) {
                                  return DropdownMenuItem(
                                    value: rol,
                                    child: Text(nombreRol(rol)),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                setSheetState(() {
                                  filtroRol = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder(
                          stream: database.child('trabajadoras').onValue,
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final data = snapshot.data!.snapshot.value;

                            if (data == null) {
                              return mensajeVacio();
                            }

                            final mapa = data as Map;
                            final items = mapa.entries.where((entry) {
                              final trabajador = entry.value as Map;
                              final nombre = (trabajador['nombre'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              final correo = (trabajador['correo'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              final telefono = (trabajador['telefono'] ?? '')
                                  .toString()
                                  .toLowerCase();
                              final sede =
                                  (trabajador['sede'] ?? '').toString();
                              final rol = (trabajador['rol'] ?? 'trabajadora')
                                  .toString();

                              final cumpleBusqueda = busqueda.isEmpty ||
                                  nombre.contains(busqueda) ||
                                  correo.contains(busqueda) ||
                                  telefono.contains(busqueda);
                              final cumpleSede =
                                  filtroSede == 'Todas' || sede == filtroSede;
                              final cumpleRol =
                                  filtroRol == 'Todos' || rol == filtroRol;

                              return cumpleBusqueda && cumpleSede && cumpleRol;
                            }).toList();

                            if (items.isEmpty) {
                              return mensajeVacio();
                            }

                            return ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final id = items[index].key;
                                final trabajadora = items[index].value as Map;

                                return tarjetaTrabajadora(
                                  id,
                                  trabajadora,
                                  cerrarLista: () {
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      buscarListaController.dispose();
    });
  }

  String nombreRol(String rol) {
    switch (rol) {
      case 'recepcionista':
        return 'Recepcionista';
      case 'trabajadora':
      default:
        return 'Trabajadora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Personal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestion de Personal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Administra recepcionistas y especialistas por sede.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              campoTexto(
                nombreController,
                'Nombre completo',
                Icons.person,
              ),
              const SizedBox(height: 15),
              campoTexto(
                correoController,
                'Correo electronico',
                Icons.email,
              ),
              const SizedBox(height: 15),
              campoTexto(
                passwordController,
                'Contraseña referencial',
                Icons.lock,
                oculto: true,
              ),
              const SizedBox(height: 15),
              campoTexto(
                telefonoController,
                'Teléfono',
                Icons.phone,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: rolSeleccionado,
                decoration: decoracionInput(
                  'Rol',
                  Icons.badge,
                ),
                items: rolesOperativos.map((rol) {
                  return DropdownMenuItem(
                    value: rol,
                    child: Text(nombreRol(rol)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    rolSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: sedeSeleccionada,
                decoration: decoracionInput(
                  'Sede',
                  Icons.store,
                ),
                items: KokoConfig.sedes.map((sede) {
                  return DropdownMenuItem(
                    value: sede,
                    child: Text(sede),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    sedeSeleccionada = value;
                  });
                },
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        seleccionarHora(horaEntradaController);
                      },
                      child: AbsorbPointer(
                        child: campoTexto(
                          horaEntradaController,
                          'Hora entrada',
                          Icons.access_time,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        seleccionarHora(horaSalidaController);
                      },
                      child: AbsorbPointer(
                        child: campoTexto(
                          horaSalidaController,
                          'Hora salida',
                          Icons.access_time_filled,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: cargando ? null : guardarTrabajadora,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD9A5B3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: cargando
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Guardar Personal',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: mostrarListaTrabajadoras,
                  icon: const Icon(Icons.people_alt),
                  label: const Text('Ver lista de personal'),
                ),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget tarjetaTrabajadora(
    String id,
    Map trabajadora, {
    required VoidCallback cerrarLista,
  }) {
    final rol = (trabajadora['rol'] ?? 'trabajadora').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFD9A5B3).withOpacity(0.85),
            child: Icon(
              rol == 'recepcionista' ? Icons.support_agent : Icons.spa,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trabajadora['nombre'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(nombreRol(rol)),
                Text('Sede: ${trabajadora['sede'] ?? 'No asignada'}'),
                Text(trabajadora['correo'] ?? ''),
                Text('Tel: ${trabajadora['telefono'] ?? ''}'),
                Text(
                  '${trabajadora['horaEntrada'] ?? ''} - ${trabajadora['horaSalida'] ?? ''}',
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'Editar',
                onPressed: () {
                  editarTrabajadora(id, trabajadora);
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Eliminar',
                onPressed: () async {
                  cerrarLista();
                  await eliminarTrabajadora(id);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget mensajeVacio() {
    return const Center(
      child: Text(
        'No hay registros para mostrar',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget campoTexto(
    TextEditingController controller,
    String texto,
    IconData icono, {
    bool oculto = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: oculto,
      decoration: decoracionInput(texto, icono),
    );
  }

  Widget campoEditar(
    TextEditingController controller,
    String texto,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: texto,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  InputDecoration decoracionInput(
    String texto,
    IconData icono,
  ) {
    return InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icono),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
