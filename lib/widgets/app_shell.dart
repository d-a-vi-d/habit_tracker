import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/home_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stufe 2: hier kommt die Weiche hin
    //  - lädt noch?          -> Ladeanzeige
    //  - Fehler?             -> Fehlerseite mit "Erneut versuchen"
    //  - nicht eingeloggt?   -> Start-/Login-Screen
    return const HomeScreen();
  }
}
