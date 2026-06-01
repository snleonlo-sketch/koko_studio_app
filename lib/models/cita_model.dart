class CitaModel {

  String id;
  String cliente;
  String telefono;
  String servicio;
  String trabajadora;
  String fecha;
  String hora;

  CitaModel({

    required this.id,
    required this.cliente,
    required this.telefono,
    required this.servicio,
    required this.trabajadora,
    required this.fecha,
    required this.hora,
  });

  Map<String, dynamic> toMap() {

    return {

      'id': id,
      'cliente': cliente,
      'telefono': telefono,
      'servicio': servicio,
      'trabajadora': trabajadora,
      'fecha': fecha,
      'hora': hora,
    };
  }

  factory CitaModel.fromMap(
      Map<dynamic, dynamic> map,
      ) {

    return CitaModel(

      id: map['id'],
      cliente: map['cliente'],
      telefono: map['telefono'],
      servicio: map['servicio'],
      trabajadora: map['trabajadora'],
      fecha: map['fecha'],
      hora: map['hora'],
    );
  }
}