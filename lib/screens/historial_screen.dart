import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/excel_service.dart';
import '../services/pdf_service.dart';
import '../services/role_service.dart';
import 'citas_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final DatabaseReference citasRef =
      FirebaseDatabase.instance.ref().child('citas');

  final RoleService roleService = RoleService();

  final TextEditingController buscarController = TextEditingController();

  String textoBusqueda = '';
  String rolUsuario = '';
  String nombreUsuario = '';
  String sedeUsuario = '';
  DateTime fechaSeleccionada = DateTime.now();
  String sedeSeleccionada = 'Todas';

  int totalPendientes = 0;
  int totalConfirmadas = 0;
  int totalFinalizadas = 0;
  int totalCanceladas = 0;
  double ingresos = 0;

  bool get esAdmin => rolUsuario == 'admin';
  bool get esRecepcionista => rolUsuario == 'recepcionista';
  bool get puedeEditarCitas => esAdmin || esRecepcionista;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarUsuario() async {
    final datos = await roleService.obtenerDatosUsuario();

    if (!mounted) return;

    setState(() {
      rolUsuario = (datos['rol'] ?? '').toString();
      nombreUsuario = (datos['nombre'] ?? '').toString();
      sedeUsuario = (datos['sede'] ?? '').toString();
    });
  }

  Color colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return const Color(0xFF7E9CCB);
      case 'finalizada':
        return const Color(0xFF7BAE8D);
      case 'cancelada':
        return const Color(0xFFC97D7D);
      default:
        return const Color(0xFFD9A5B3);
    }
  }

  IconData iconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return Icons.check_circle;
      case 'finalizada':
        return Icons.done_all;
      case 'cancelada':
        return Icons.cancel;
      default:
        return Icons.access_time;
    }
  }

  String rangoHora(Map<String, dynamic> cita) {
    final inicio = (cita['horaInicio'] ?? cita['hora'] ?? '').toString();
    final fin = (cita['horaFin'] ?? '').toString();

    if (fin.isEmpty) return inicio;

    return '$inicio - $fin';
  }

  Future<void> registrarAlertaAdmin({
    required String accion, // 'creacion', 'edicion', 'eliminacion'
    required String motivo,
    required String cliente,
    required String servicio,
    required String trabajadora,
    required String fecha,
    required String hora,
    String? horaFin,
    required String telefono,
    required String precio,
    required String sede,
  }) async {
    try {
      final nuevaAlertaRef = FirebaseDatabase.instance.ref().child('alertas_admin').push();
      await nuevaAlertaRef.set({
        'fechaHora': DateTime.now().toIso8601String(),
        'sede': sede.isNotEmpty ? sede : 'Belaunde',
        'realizadoPor': nombreUsuario.isNotEmpty ? nombreUsuario : 'Administrador',
        'rol': rolUsuario.isNotEmpty ? rolUsuario : 'admin',
        'motivo': motivo,
        'cliente': cliente,
        'servicio': servicio,
        'trabajadora': trabajadora,
        'fecha': fecha,
        'hora': hora,
        'horaFin': horaFin ?? '',
        'accion': accion,
        'leida': false,
        'telefono': telefono,
        'precio': precio,
      });
    } catch (e) {
      print('Error al registrar alerta admin desde historial: $e');
    }
  }

  Future<void> cambiarEstado(String id, String estado) async {
    try {
      final snap = await citasRef.child(id).get();
      if (snap.exists && snap.value != null) {
        final Map map = snap.value as Map;
        await registrarAlertaAdmin(
          accion: 'edicion',
          motivo: 'Estado de cita cambiado a $estado desde historial',
          cliente: (map['cliente'] ?? '').toString(),
          servicio: (map['servicio'] ?? '').toString(),
          trabajadora: (map['trabajadora'] ?? '').toString(),
          fecha: (map['fecha'] ?? '').toString(),
          hora: (map['hora'] ?? '').toString(),
          horaFin: (map['horaFin'] ?? '').toString(),
          telefono: (map['telefono'] ?? '').toString(),
          precio: (map['precio'] ?? '').toString(),
          sede: (map['sede'] ?? '').toString(),
        );
      }
    } catch (e) {
      print('Error logging state update alert in historial: $e');
    }

    await citasRef.child(id).update({
      'estado': estado,
    });
  }

  Future<void> eliminarCita(String id) async {
    try {
      final snap = await citasRef.child(id).get();
      if (snap.exists && snap.value != null) {
        final Map map = snap.value as Map;
        await registrarAlertaAdmin(
          accion: 'eliminacion',
          motivo: 'Cita eliminada desde historial',
          cliente: (map['cliente'] ?? '').toString(),
          servicio: (map['servicio'] ?? '').toString(),
          trabajadora: (map['trabajadora'] ?? '').toString(),
          fecha: (map['fecha'] ?? '').toString(),
          hora: (map['hora'] ?? '').toString(),
          horaFin: (map['horaFin'] ?? '').toString(),
          telefono: (map['telefono'] ?? '').toString(),
          precio: (map['precio'] ?? '').toString(),
          sede: (map['sede'] ?? '').toString(),
        );
      }
    } catch (e) {
      print('Error logging deletion alert in historial: $e');
    }

    await citasRef.child(id).remove();
  }

  Future<String?> pedirMotivoEdicion() async {
    final controller = TextEditingController();

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Motivo de la edicion'),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Ejemplo: la clienta solicito cambiar el horario',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final texto = controller.text.trim();

                if (texto.isEmpty) return;

                Navigator.pop(context, texto);
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return motivo;
  }

  Future<void> abrirEdicionCita(Map<String, dynamic> cita) async {
    final motivo = esRecepcionista
        ? await pedirMotivoEdicion()
        : 'Edicion realizada por administrador';

    if (motivo == null || motivo.trim().isEmpty) return;
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitasScreen(
          citaEditar: cita,
          motivoEdicion: motivo,
        ),
      ),
    );
  }

  Future<void> enviarWhatsApp(
    String telefono,
    String cliente,
    String fecha,
    String hora,
    String servicio,
  ) async {
    String numero = telefono.replaceAll(RegExp(r'[^0-9]'), '');

    if (!numero.startsWith('51')) {
      numero = '51$numero';
    }

    final mensaje = 'Hola $cliente\n\n'
        'Te recordamos tu cita en Koko Studio.\n\n'
        'Fecha: $fecha\n'
        'Hora: $hora\n'
        'Servicio: $servicio\n\n'
        'Te esperamos.';

    final uri = Uri.parse(
      'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}',
    );

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> generarPDF(Map<String, dynamic> cita) async {
    final pdf = await PdfService.generarBoleta(
      cliente: cita['cliente'],
      servicio: cita['servicio'],
      fecha: cita['fecha'],
      hora: rangoHora(cita),
      precio: cita['precio'],
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf,
    );
  }

  Future<void> exportarExcel(List<Map<String, dynamic>> citasLista) async {
    final lista = citasLista.map((cita) {
      return {
        'cliente': cita['cliente'],
        'telefono': cita['telefono'],
        'servicio': cita['servicio'],
        'trabajadora': cita['trabajadora'],
        'fecha': cita['fecha'],
        'hora': rangoHora(cita),
        'precio': cita['precio'],
        'estado': cita['estado'],
      };
    }).toList();

    await ExcelService.exportarCitas(citas: lista);
  }

  List<Map<String, dynamic>> prepararCitas(Map<dynamic, dynamic> citas) {
    final citasLista = <Map<String, dynamic>>[];

    totalPendientes = 0;
    totalConfirmadas = 0;
    totalFinalizadas = 0;
    totalCanceladas = 0;
    ingresos = 0;

    final targetFechaString = '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}';

    citas.forEach((key, value) {
      final cita = Map<String, dynamic>.from(value as Map);
      final estado = (cita['estado'] ?? 'pendiente').toString();
      final sede = (cita['sede'] ?? '').toString();
      final fechaString = (cita['fecha'] ?? '').toString();

      if (esRecepcionista && sedeUsuario.isNotEmpty && sede != sedeUsuario) {
        return;
      }

      // Filtrado por sede para administrador
      if (esAdmin && sedeSeleccionada != 'Todas' && sede != sedeSeleccionada) {
        return;
      }

      // Filtrado por fecha diaria exacta
      if (fechaString != targetFechaString) {
        return;
      }

      if (estado == 'pendiente') totalPendientes++;
      if (estado == 'confirmada') totalConfirmadas++;
      if (estado == 'cancelada') {
        totalCanceladas++;
        ingresos += 20; // S/ 20 del anticipo no reembolsable quedan en caja
      }
      if (estado == 'finalizada') {
        totalFinalizadas++;
        ingresos += double.tryParse((cita['precio'] ?? '0').toString()) ?? 0;
      }

      citasLista.add({
        'id': key,
        'cliente': cita['cliente'] ?? '',
        'clienteUid': cita['clienteUid'],
        'telefono': cita['telefono'] ?? '',
        'servicio': cita['servicio'] ?? '',
        'trabajadora': cita['trabajadora'] ?? '',
        'sede': sede,
        'fecha': fechaString,
        'hora': cita['horaInicio'] ?? cita['hora'] ?? '',
        'horaInicio': cita['horaInicio'] ?? cita['hora'] ?? '',
        'horaFin': cita['horaFin'] ?? '',
        'estado': estado,
        'precio': (cita['precio'] ?? '').toString(),
        'adelanto': cita['adelanto'] ?? '20',
        'adelantoPagado': cita['adelantoPagado'] == true,
        'estadoPago': cita['estadoPago'] ?? '',
        'observaciones': cita['observaciones'] ?? '',
      });
    });

    // Ordenar cronológicamente por hora de inicio
    citasLista.sort((a, b) {
      return (a['horaInicio'] ?? '').toString().compareTo((b['horaInicio'] ?? '').toString());
    });

    if (textoBusqueda.trim().isEmpty) return citasLista;

    final busqueda = textoBusqueda.toLowerCase();
    final numero = textoBusqueda.replaceAll(RegExp(r'[^0-9]'), '');

    return citasLista.where((cita) {
      final cliente = cita['cliente'].toString().toLowerCase();
      final telefono =
          cita['telefono'].toString().replaceAll(RegExp(r'[^0-9]'), '');

      return cliente.contains(busqueda) ||
          (numero.isNotEmpty && telefono.contains(numero));
    }).toList();
  }

  Future<void> _seleccionarFechaHistorial(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2026),
      lastDate: DateTime(2035),
    );

    if (fecha != null && mounted) {
      setState(() {
        fechaSeleccionada = fecha;
      });
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
          'Historial de Citas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder(
        stream: citasRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ocurrio un error'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: Text(
                'No hay citas registradas',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final citas =
              snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

          final citasLista = prepararCitas(citas);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    TextField(
                      controller: buscarController,
                      onChanged: (value) {
                        setState(() {
                          textoBusqueda = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar clienta o celular',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _seleccionarFechaHistorial(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, color: Color(0xFFD9A5B3), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${fechaSeleccionada.day}/${fechaSeleccionada.month}/${fechaSeleccionada.year}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (esAdmin) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: sedeSeleccionada,
                                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD9A5B3)),
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Todas',
                                      child: Text('Todas las sedes'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Comas',
                                      child: Text('Comas'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Carabayllo',
                                      child: Text('Carabayllo'),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      sedeSeleccionada = value ?? 'Todas';
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: tarjetaResumen(
                            'Pendientes',
                            totalPendientes.toString(),
                            const Color(0xFFD9A5B3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: tarjetaResumen(
                            'Confirmadas',
                            totalConfirmadas.toString(),
                            const Color(0xFF7E9CCB),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: tarjetaResumen(
                            'Finalizadas',
                            totalFinalizadas.toString(),
                            const Color(0xFF7BAE8D),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: tarjetaResumen(
                            'Ingresos',
                            'S/ ${ingresos.toStringAsFixed(0)}',
                            const Color(0xFFB58AB8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          exportarExcel(citasLista);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: const Icon(
                          Icons.table_chart,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Exportar Excel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: citasLista.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay citas con ese filtro',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 90),
                        itemCount: citasLista.length,
                        itemBuilder: (context, index) {
                          return tarjetaHistorialCita(citasLista[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget tarjetaResumen(String titulo, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            valor,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            titulo,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaHistorialCita(Map<String, dynamic> cita) {
    final estado = (cita['estado'] ?? 'pendiente').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colorEstado(estado).withOpacity(0.18),
                  child: Icon(
                    iconoEstado(estado),
                    color: colorEstado(estado),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Clienta',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        (cita['cliente'] ?? '').toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado(estado),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    estado.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            datoCita('Servicio', cita['servicio']),
            datoCita('Trabajadora asignada', cita['trabajadora']),
            datoCita('Sede', cita['sede']),
            datoCita('Fecha', cita['fecha']),
            datoCita('Horario', rangoHora(cita)),
            datoCita('Telefono', cita['telefono']),
            datoCita('Precio', 'S/ ${cita['precio']}'),
            datoCita(
              'Adelanto',
              'S/ ${cita['adelanto']} - ${cita['estadoPago']}',
            ),
            if ((cita['observaciones'] ?? '').toString().trim().isNotEmpty)
              datoCita('Nota', cita['observaciones']),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (cita['estado'] != 'cancelada' && cita['estado'] != 'finalizada')
                  botonAccion(
                    texto: 'Cancelar',
                    icono: Icons.cancel,
                    color: Colors.red.shade700,
                    onPressed: () {
                      cambiarEstado(cita['id'], 'cancelada');
                    },
                  ),
                botonAccion(
                  texto: 'Confirmar',
                  icono: Icons.check,
                  color: Colors.blue,
                  onPressed: () {
                    cambiarEstado(cita['id'], 'confirmada');
                  },
                ),
                botonAccion(
                  texto: 'Finalizar',
                  icono: Icons.done_all,
                  color: Colors.green,
                  onPressed: () {
                    cambiarEstado(cita['id'], 'finalizada');
                  },
                ),

                if (puedeEditarCitas)
                  botonAccion(
                    texto: 'Editar',
                    icono: Icons.edit,
                    color: const Color(0xFFB58AB8),
                    onPressed: () {
                      abrirEdicionCita(cita);
                    },
                  ),
                if (esAdmin)
                  botonAccion(
                    texto: 'PDF',
                    icono: Icons.picture_as_pdf,
                    color: Colors.deepOrange,
                    onPressed: () {
                      generarPDF(cita);
                    },
                  ),
                if (esAdmin)
                  botonAccion(
                    texto: 'Eliminar',
                    icono: Icons.delete,
                    color: Colors.red,
                    onPressed: () {
                      eliminarCita(cita['id']);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget datoCita(String etiqueta, Object? valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 14,
          ),
          children: [
            TextSpan(
              text: '$etiqueta: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: (valor ?? '').toString()),
          ],
        ),
      ),
    );
  }

  Widget botonAccion({
    required String texto,
    required IconData icono,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
      ),
      onPressed: onPressed,
      icon: Icon(
        icono,
        color: Colors.white,
      ),
      label: Text(
        texto,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
