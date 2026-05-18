import 'dart:io';

import 'package:excel/excel.dart';

import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';

class ExcelService {

  static Future<void>
  exportarCitas({

    required List<Map<String, dynamic>>
    citas,

  }) async {

    try {

      final excel =
      Excel.createExcel();

      final Sheet sheet =
      excel['Citas'];

      sheet.appendRow([

        TextCellValue('Cliente'),

        TextCellValue('Teléfono'),

        TextCellValue('Servicio'),

        TextCellValue('Trabajadora'),

        TextCellValue('Fecha'),

        TextCellValue('Hora'),

        TextCellValue('Precio'),

        TextCellValue('Estado'),
      ]);

      for (var cita in citas) {

        sheet.appendRow([

          TextCellValue(

            cita['cliente']
                .toString(),
          ),

          TextCellValue(

            cita['telefono']
                .toString(),
          ),

          TextCellValue(

            cita['servicio']
                .toString(),
          ),

          TextCellValue(

            cita['trabajadora']
                .toString(),
          ),

          TextCellValue(

            cita['fecha']
                .toString(),
          ),

          TextCellValue(

            cita['hora']
                .toString(),
          ),

          TextCellValue(

            cita['precio']
                .toString(),
          ),

          TextCellValue(

            cita['estado']
                .toString(),
          ),
        ]);
      }

      for (int i = 0; i < 8; i++) {

        sheet.setColumnWidth(
          i,
          25,
        );
      }

      final directory =

      await getApplicationDocumentsDirectory();

      final fechaActual =

          DateTime.now()
              .millisecondsSinceEpoch;

      final path =

          '${directory.path}/'
          'reporte_citas_$fechaActual.xlsx';

      final file = File(path);

      final bytes =
      excel.encode();

      if (bytes != null) {

        await file.writeAsBytes(
          bytes,
        );
      }

      await Share.shareXFiles(

        [XFile(path)],

        text:
        'Reporte de citas Koko Studio 💖',
      );

    } catch (e) {

      rethrow;
    }
  }
}