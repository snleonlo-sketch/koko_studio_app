import 'dart:typed_data';

import 'package:intl/intl.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {

  static Future<Uint8List>
  generarBoleta({

    required String cliente,
    required String servicio,
    required String fecha,
    required String hora,
    required String precio,

  }) async {

    final pdf = pw.Document();

    final fechaActual =

    DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(
      DateTime.now(),
    );

    pdf.addPage(

      pw.Page(

        pageFormat:
        PdfPageFormat.a4,

        margin:
        const pw.EdgeInsets.all(30),

        build: (context) {

          return pw.Column(

            crossAxisAlignment:
            pw.CrossAxisAlignment.start,

            children: [

              pw.Container(

                width:
                double.infinity,

                padding:
                const pw.EdgeInsets.all(25),

                decoration: pw.BoxDecoration(

                  color:
                  PdfColors.pink100,

                  borderRadius:
                  pw.BorderRadius.circular(15),
                ),

                child: pw.Column(

                  children: [

                    pw.Text(

                      'KOKO STUDIO',

                      style: pw.TextStyle(

                        fontSize: 30,

                        fontWeight:
                        pw.FontWeight.bold,

                        color:
                        PdfColors.pink900,
                      ),
                    ),

                    pw.SizedBox(height: 8),

                    pw.Text(

                      'Boleta de Atención',

                      style: const pw.TextStyle(

                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 35),

              pw.Text(

                'Información del Cliente',

                style: pw.TextStyle(

                  fontSize: 22,

                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 20),

              item(
                'Cliente',
                cliente,
              ),

              item(
                'Servicio',
                servicio,
              ),

              item(
                'Fecha',
                fecha,
              ),

              item(
                'Hora',
                hora,
              ),

              item(
                'Monto Total',
                'S/ $precio',
              ),

              pw.SizedBox(height: 30),

              pw.Container(

                width:
                double.infinity,

                padding:
                const pw.EdgeInsets.all(18),

                decoration: pw.BoxDecoration(

                  color:
                  PdfColors.grey200,

                  borderRadius:
                  pw.BorderRadius.circular(12),
                ),

                child: pw.Column(

                  crossAxisAlignment:
                  pw.CrossAxisAlignment.start,

                  children: [

                    pw.Text(

                      'Detalles de Emisión',

                      style: pw.TextStyle(

                        fontSize: 18,

                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 12),

                    pw.Text(
                      'Fecha de emisión: $fechaActual',
                    ),

                    pw.SizedBox(height: 5),

                    pw.Text(
                      'Estado: Pagado',
                    ),

                    pw.SizedBox(height: 5),

                    pw.Text(
                      'Método: Atención Presencial',
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              pw.Divider(),

              pw.SizedBox(height: 10),

              pw.Center(

                child: pw.Column(

                  children: [

                    pw.Text(

                      'Gracias por confiar en Koko Studio ',

                      style: pw.TextStyle(

                        fontSize: 18,

                        fontWeight:
                        pw.FontWeight.bold,

                        color:
                        PdfColors.pink700,
                      ),
                    ),

                    pw.SizedBox(height: 10),

                    pw.Text(

                      'Belleza • Elegancia • Profesionalismo',

                      style: const pw.TextStyle(

                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget item(

      String titulo,
      String valor,

      ) {

    return pw.Container(

      margin:
      const pw.EdgeInsets.only(
        bottom: 15,
      ),

      padding:
      const pw.EdgeInsets.all(15),

      decoration: pw.BoxDecoration(

        border: pw.Border.all(

          color:
          PdfColors.grey300,
        ),

        borderRadius:
        pw.BorderRadius.circular(10),
      ),

      child: pw.Row(

        crossAxisAlignment:
        pw.CrossAxisAlignment.start,

        children: [

          pw.Expanded(

            flex: 2,

            child: pw.Text(

              titulo,

              style: pw.TextStyle(

                fontWeight:
                pw.FontWeight.bold,

                fontSize: 16,
              ),
            ),
          ),

          pw.Expanded(

            flex: 3,

            child: pw.Text(

              valor,

              style: const pw.TextStyle(

                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<Uint8List> generarReporteMensual({
    required String mes,
    required double ingresos,
    required int citas,
    required int clientas,
    required Map<String, double> ingresosTrabajadora,
    required Map<String, int> servicios,
  }) async {

    final pdf = pw.Document();

    pdf.addPage(

      pw.Page(

        pageFormat:
        PdfPageFormat.a4,

        margin:
        const pw.EdgeInsets.all(30),

        build: (context) {

          return pw.Column(

            crossAxisAlignment:
            pw.CrossAxisAlignment.start,

            children: [

              pw.Container(

                width:
                double.infinity,

                padding:
                const pw.EdgeInsets.all(25),

                decoration: pw.BoxDecoration(

                  color:
                  PdfColors.pink100,

                  borderRadius:
                  pw.BorderRadius.circular(15),
                ),

                child: pw.Column(

                  children: [

                    pw.Text(

                      'KOKO STUDIO',

                      style: pw.TextStyle(

                        fontSize: 28,

                        fontWeight:
                        pw.FontWeight.bold,

                        color:
                        PdfColors.pink900,
                      ),
                    ),

                    pw.SizedBox(height: 5),

                    pw.Text(

                      'Reporte Ejecutivo Mensual - $mes',

                      style: const pw.TextStyle(

                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 25),

              pw.Text(

                'Resumen Mensual de Actividades',

                style: pw.TextStyle(

                  fontSize: 18,

                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 15),

              pw.Row(

                mainAxisAlignment:
                pw.MainAxisAlignment.spaceBetween,

                children: [

                  pw.Container(

                    width: 150,

                    padding: const pw.EdgeInsets.all(12),

                    decoration: pw.BoxDecoration(

                      border: pw.Border.all(
                        color: PdfColors.grey300,
                      ),

                      borderRadius:
                      pw.BorderRadius.circular(10),
                    ),

                    child: pw.Column(

                      children: [

                        pw.Text(
                          'Total Ingresos',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 5),

                        pw.Text(
                          'S/ ${ingresos.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.Container(

                    width: 150,

                    padding: const pw.EdgeInsets.all(12),

                    decoration: pw.BoxDecoration(

                      border: pw.Border.all(
                        color: PdfColors.grey300,
                      ),

                      borderRadius:
                      pw.BorderRadius.circular(10),
                    ),

                    child: pw.Column(

                      children: [

                        pw.Text(
                          'Total Citas',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 5),

                        pw.Text(
                          '$citas',
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.Container(

                    width: 150,

                    padding: const pw.EdgeInsets.all(12),

                    decoration: pw.BoxDecoration(

                      border: pw.Border.all(
                        color: PdfColors.grey300,
                      ),

                      borderRadius:
                      pw.BorderRadius.circular(10),
                    ),

                    child: pw.Column(

                      children: [

                        pw.Text(
                          'Clientas en la App',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 5),

                        pw.Text(
                          '$clientas',
                          style: pw.TextStyle(
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              pw.Text(

                'Ingresos por Especialista (Citas Finalizadas)',

                style: pw.TextStyle(

                  fontSize: 16,

                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              ingresosTrabajadora.isEmpty

                  ? pw.Text('No se registraron ingresos en este ciclo.')

                  : pw.Column(

                children:
                ingresosTrabajadora.entries.map((entry) {

                  return pw.Padding(

                    padding:
                    const pw.EdgeInsets.symmetric(
                      vertical: 5,
                    ),

                    child: pw.Row(

                      mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,

                      children: [

                        pw.Text(
                          entry.key,
                          style: const pw.TextStyle(
                            fontSize: 13,
                          ),
                        ),

                        pw.Text(
                          'S/ ${entry.value.toStringAsFixed(2)}',
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green700,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              pw.SizedBox(height: 30),

              pw.Text(

                'Demanda de Servicios Realizados',

                style: pw.TextStyle(

                  fontSize: 16,

                  fontWeight:
                  pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              servicios.isEmpty

                  ? pw.Text('No se registraron servicios en este ciclo.')

                  : pw.Column(

                children:
                servicios.entries.map((entry) {

                  return pw.Padding(

                    padding:
                    const pw.EdgeInsets.symmetric(
                      vertical: 5,
                    ),

                    child: pw.Row(

                      mainAxisAlignment:
                      pw.MainAxisAlignment.spaceBetween,

                      children: [

                        pw.Text(
                          entry.key,
                          style: const pw.TextStyle(
                            fontSize: 13,
                          ),
                        ),

                        pw.Text(
                          '${entry.value} citas',
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              pw.Spacer(),

              pw.Divider(),

              pw.SizedBox(height: 10),

              pw.Center(

                child: pw.Text(
                  'Gracias por tu gran gestión en Koko Studio ',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}