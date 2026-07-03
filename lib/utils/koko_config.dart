class KokoConfig {
  static const List<String> sedes = [
    'Comas',
    'Carabayllo',
  ];

  static const String whatsappComas = '51932124079';

  static const String whatsappCarabayllo = '51932124079';

  static String whatsappPorSede(String sede) {
    switch (sede) {
      case 'Carabayllo':
        return whatsappCarabayllo;
      case 'Comas':
      default:
        return whatsappComas;
    }
  }

  static const List<String> condicionesCita = [
    'El día de tu cita contamos con 10 minutos de tolerancia. Pasado este tiempo, la cita se pierde junto con el adelanto, ya que tenemos otras clientas agendadas.',
    'Si necesitas reprogramar, avísanos con 12 horas de anticipación. Te brindamos una sola reprogramación, sujeta a disponibilidad del studio.',
    'En caso de no asistir o no avisar dentro del plazo indicado, se perderá el turno y el anticipo.',
    'Para mantener un ambiente tranquilo y relajante, no asistir con niños ya que los servicios tardan más de 1 hora.',
    'Si agendas más de un servicio y decides cancelar alguno el mismo día, el adelanto se considerará como penalidad.',
    'Estacionamiento disponible según orden de llegada (sede Belaunde).',
    'Aceptamos tarjetas de crédito, débito, billeteras digitales y pagos POS.',
  ];

  static const String introCondiciones =
      'Hola, reina. Gracias por confiar en KOKO STUDIO, tu espacio de belleza en Lima Norte. A continuación, te compartimos información importante para que tu experiencia sea perfecta. Te pedimos leerla con calma:';

  static String condicionesComoTexto() {
    return condicionesCita
        .map((condicion) => '- $condicion')
        .join('\n');
  }

  static Uri whatsappUri({
    required String mensaje,
    String? sede,
  }) {
    final numero =
        whatsappPorSede(sede ?? sedes.first);

    return Uri.parse(
      'https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}',
    );
  }
}
