import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/special_exception.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

extension ErrorSnackbar on BuildContext {
  void showError(Object e) {
    final msg = switch (e) {
      SpecialException() => (e).errorMessage,
      // AuthException() => _translateAuthError(e),
      // PostgrestException() => _translatePostgrestError((e).code),
      SocketException() || HttpException() => 'Netzwerkfehler. Prüfe deine Verbindung.',
      _ => 'Ein unerwarteter Fehler ist aufgetreten.',
    };
    debugPrint("❗${e.toString()}");
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(msg)));
  }

  // String _translateAuthError(AuthException e) => switch (e.message) {
  //   String m
  //       when m.contains('already registered') ||
  //           m.contains('already exists') ||
  //           m.contains('already in use') ||
  //           m.contains('already been registered') =>
  //     'Diese E-Mail-Adresse ist bereits vergeben.',

  //   String m when m.contains('Password should be at least') =>
  //     'Das Passwort muss mindestens 6 Zeichen lang sein.',

  //   String m when m.contains('weak_password') => 'Passwort zu schwach.',

  //   String m when m.contains('New password should be different') =>
  //     'Das neue Passwort muss sich vom alten unterscheiden.',

  //   String m when m.contains('Email not confirmed') => 'E-Mail wurde noch nicht bestätigt.',

  //   String m when m.contains('Unable to validate email address') => 'Ungültige E-Mail-Adresse.',

  //   String m when m.contains('Email address') && m.contains('is invalid') =>
  //     'Ungültige E-Mail-Adresse.',

  //   _ => switch (e.statusCode) {
  //     '400' => 'Falsche E-Mail oder falsches Passwort.',
  //     '422' => 'Ungültige Eingabe.',
  //     '429' => 'Zu viele Versuche. Bitte warte kurz.',

  //     _ => 'Authentifizierungsfehler. Versuche es erneut.',
  //   },
  // };

  // String _translatePostgrestError(String? code) => switch (code) {
  //   'P0001' => 'Aktion nicht erlaubt.',
  //   '23505' => 'Dieser Eintrag existiert bereits.',
  //   '23503' => 'Referenzierter Eintrag existiert nicht.',
  //   '42501' => 'Keine Berechtigung für diese Aktion.',
  //   _ => 'Ein Datenbankfehler ist aufgetreten.',
  // };
}
