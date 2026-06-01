class KokoConfig {
  static const List<String> sedes = [
    'Comas',
    'Carabayllo',
  ];

  static const String whatsappReservas = '51932124079';

  static const List<String> condicionesCita = [
    'La cita se confirma con S/ 20 de adelanto.',
    'El adelanto se descuenta del monto final del servicio.',
    'Si la clienta no asiste, el adelanto no se devuelve.',
    'Los cambios de horario deben avisarse con anticipacion.',
    'La puntualidad ayuda a respetar la agenda de todas las clientas.',
  ];

  static String condicionesComoTexto() {
    return condicionesCita
        .map((condicion) => '- $condicion')
        .join('\n');
  }

  static Uri whatsappUri({
    required String mensaje,
  }) {
    return Uri.parse(
      'https://wa.me/$whatsappReservas?text=${Uri.encodeComponent(mensaje)}',
    );
  }
}
