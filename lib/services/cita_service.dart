import 'package:firebase_database/firebase_database.dart';

import '../models/cita_model.dart';

class CitaService {

  final DatabaseReference citasRef =
  FirebaseDatabase.instance.ref(
    'citas',
  );

  Future<void> guardarCita(
      CitaModel cita,
      ) async {

    await citasRef
        .child(cita.id)
        .set(cita.toMap());
  }
}