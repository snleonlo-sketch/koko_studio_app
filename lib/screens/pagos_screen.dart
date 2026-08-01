import 'package:flutter/material.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  String metodoAbierto = 'Yape';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Métodos de Pago',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
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
                      'Pagos Koko Studio ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Utiliza nuestros métodos rápidos para abonar tu reserva o liquidar tus consumos en salón.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Selecciona un método de pago',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // Yape QR
              _buildPaymentCard(
                id: 'Yape',
                titulo: 'Yape (QR)',
                subtitulo: 'Abono inmediato sin comisión',
                color: Colors.purple,
                icono: Icons.qr_code,
                contenido: _buildQrContent(
                  imagen: 'assets/images/yape.jpeg',
                  celular: '987 654 321',
                  titular: 'Koko Studio S.A.C.',
                  colorTema: Colors.purple,
                ),
              ),

              const SizedBox(height: 15),

              // Plin QR
              _buildPaymentCard(
                id: 'Plin',
                titulo: 'Plin (QR)',
                subtitulo: 'Transfiere gratis e instantáneo',
                color: Colors.teal,
                icono: Icons.qr_code_scanner,
                contenido: _buildQrContent(
                  isPlin: true,
                  celular: '987 654 321',
                  titular: 'Koko Studio S.A.C.',
                  colorTema: Colors.teal,
                ),
              ),

              const SizedBox(height: 15),

              // Tarjeta
              _buildPaymentCard(
                id: 'Tarjeta',
                titulo: 'Tarjeta de Crédito / Débito',
                subtitulo: 'Visa, Mastercard, AMEX y más',
                color: Colors.blue.shade700,
                icono: Icons.credit_card,
                contenido: _buildInformativoContent(
                  icono: Icons.credit_score,
                  colorTema: Colors.blue.shade700,
                  tituloDetalle: 'Pago con POS o Link de Pago',
                  descripcion:
                      'Aceptamos todas las tarjetas nacionales en recepción',
                ),
              ),

              const SizedBox(height: 15),

              // Efectivo
              _buildPaymentCard(
                id: 'Efectivo',
                titulo: 'Efectivo',
                subtitulo: 'Pago físico en salón',
                color: Colors.green.shade700,
                icono: Icons.payments,
                contenido: _buildInformativoContent(
                  icono: Icons.price_check,
                  colorTema: Colors.green.shade700,
                  tituloDetalle: 'Pago en Recepción',
                  descripcion:
                      'Puedes cancelar tu cita directamente en caja en cualquiera de nuestras sedes (Comas o Carabayllo).\n\n• Solo se aceptan pagos en Soles (S/).\n• Recuerda pedir tu comprobante de pago al finalizar.',
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard({
    required String id,
    required String titulo,
    required String subtitulo,
    required Color color,
    required IconData icono,
    required Widget contenido,
  }) {
    final esAbierto = metodoAbierto == id;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: esAbierto
              ? color.withOpacity(0.5)
              : Theme.of(context).dividerColor.withOpacity(0.05),
          width: esAbierto ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icono, color: color),
            ),
            title: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              subtitulo,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 13,
              ),
            ),
            trailing: Icon(
              esAbierto ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: color,
            ),
            onTap: () {
              setState(() {
                metodoAbierto = esAbierto ? '' : id;
              });
            },
          ),
          if (esAbierto) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: contenido,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQrContent({
    String? imagen,
    bool isPlin = false,
    required String celular,
    required String titular,
    required Color colorTema,
  }) {
    return Column(
      children: [
        if (imagen != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              imagen,
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: colorTema.withOpacity(0.2)),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.qr_code_2,
              size: 150,
              color: colorTema,
            ),
          ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: colorTema.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Celular:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    celular,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorTema,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Titular:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    titular,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'Escanea el código QR desde tu app bancaria y confirma el pago con recepción.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildInformativoContent({
    required IconData icono,
    required Color colorTema,
    required String tituloDetalle,
    required String descripcion,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorTema.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: colorTema),
              const SizedBox(width: 10),
              Text(
                tituloDetalle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorTema,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            descripcion,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}