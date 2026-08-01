import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabase {
  FirebaseDatabase._();

  static final FirebaseDatabase instance = FirebaseDatabase._();

  DatabaseReference ref([String? path]) {
    final segments = path == null || path.trim().isEmpty
        ? <String>[]
        : path.split('/').where((segment) => segment.isNotEmpty).toList();
    return DatabaseReference._(segments);
  }
}

class DatabaseReference {
  DatabaseReference._(this._segments);

  final List<String> _segments;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get key => _segments.isEmpty ? null : _segments.last;

  DatabaseReference child(String path) {
    final childSegments =
        path.split('/').where((segment) => segment.isNotEmpty).toList();
    return DatabaseReference._([..._segments, ...childSegments]);
  }

  DatabaseReference push() {
    if (!_isCollectionPath) {
      throw StateError('push() solo puede usarse sobre una coleccion.');
    }
    final doc = _collectionReference().doc();
    return child(doc.id);
  }

  Future<void> set(Map<String, dynamic> value) async {
    await _documentReference().set(value);
  }

  Future<void> update(Map<String, dynamic> value) async {
    await _documentReference().set(value, SetOptions(merge: true));
  }

  Future<void> remove() async {
    await _documentReference().delete();
  }

  Future<DataSnapshot> get() async {
    if (_isCollectionPath) {
      final snapshot = await _queryForCollection().get();
      final data = <String, dynamic>{};
      for (final doc in snapshot.docs) {
        data[doc.id] = doc.data();
      }
      return DataSnapshot(data.isEmpty ? null : data);
    }

    final snapshot = await _documentReference().get();
    return DataSnapshot(snapshot.exists ? snapshot.data() : null);
  }

  Stream<DatabaseEvent> get onValue {
    if (_isCollectionPath) {
      return _queryForCollection().snapshots().map((snapshot) {
        final data = <String, dynamic>{};
        for (final doc in snapshot.docs) {
          data[doc.id] = doc.data();
        }
        return DatabaseEvent(DataSnapshot(data.isEmpty ? null : data));
      });
    }

    return _documentReference().snapshots().map((snapshot) {
      return DatabaseEvent(
        DataSnapshot(snapshot.exists ? snapshot.data() : null),
      );
    });
  }

  bool get _isCollectionPath => _segments.length.isOdd;

  String _mappedCollection(String collection) {
    switch (collection) {
      case 'trabajadoras':
      case 'administrador':
        return 'personal';
      default:
        return collection;
    }
  }

  CollectionReference<Map<String, dynamic>> _collectionReference() {
    if (!_isCollectionPath) {
      throw StateError('La ruta no apunta a una coleccion.');
    }

    CollectionReference<Map<String, dynamic>>? collection;
    DocumentReference<Map<String, dynamic>>? document;

    for (var i = 0; i < _segments.length; i++) {
      final segment = _segments[i];
      if (i.isEven) {
        final collectionName = i == 0 ? _mappedCollection(segment) : segment;
        collection = document == null
            ? _firestore.collection(collectionName)
            : document.collection(collectionName);
      } else {
        document = collection!.doc(segment);
      }
    }

    return collection!;
  }

  DocumentReference<Map<String, dynamic>> _documentReference() {
    if (_isCollectionPath || _segments.isEmpty) {
      throw StateError('La ruta no apunta a un documento.');
    }

    CollectionReference<Map<String, dynamic>>? collection;
    DocumentReference<Map<String, dynamic>>? document;

    for (var i = 0; i < _segments.length; i++) {
      final segment = _segments[i];
      if (i.isEven) {
        final collectionName = i == 0 ? _mappedCollection(segment) : segment;
        collection = document == null
            ? _firestore.collection(collectionName)
            : document.collection(collectionName);
      } else {
        document = collection!.doc(segment);
      }
    }

    return document!;
  }

  Query<Map<String, dynamic>> _queryForCollection() {
    final collection = _collectionReference();
    if (_segments.length == 1 && _segments.first == 'trabajadoras') {
      return collection.where('rol', whereIn: ['trabajadora', 'recepcionista']);
    }
    if (_segments.length == 1 && _segments.first == 'administrador') {
      return collection.where('rol', isEqualTo: 'admin');
    }
    return collection;
  }
}

class DatabaseEvent {
  DatabaseEvent(this.snapshot);

  final DataSnapshot snapshot;
}

class DataSnapshot {
  DataSnapshot(this.value);

  final dynamic value;

  bool get exists => value != null;
}
