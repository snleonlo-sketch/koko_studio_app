import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider
    extends ChangeNotifier {

  bool oscuro = false;

  ThemeProvider() {

    cargarTema();
  }

  ThemeMode get themeMode =>

      oscuro

          ? ThemeMode.dark

          : ThemeMode.light;

  bool get esOscuro => oscuro;

  Future<void>
  cargarTema() async {

    final prefs =

    await SharedPreferences
        .getInstance();

    oscuro =
        prefs.getBool('modo_oscuro')
            ?? false;

    notifyListeners();
  }

  Future<void>
  cambiarTema() async {

    oscuro = !oscuro;

    final prefs =

    await SharedPreferences
        .getInstance();

    await prefs.setBool(

      'modo_oscuro',

      oscuro,
    );

    notifyListeners();
  }
}