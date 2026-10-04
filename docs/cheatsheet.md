# Flutter/Dart Cheatsheet

Nachschlagewerk für die Vorlage. Wird nicht gebaut (liegt in `docs/`, nicht in `lib/`).
Annahmen: Dart 3, Riverpod 3 mit Codegen, Supabase.
Die Beispiele sind bewusst neutral (`Note`, `MyWidget`), nichts App-Spezifisches.

Inhalt: 1. Klassen und Konstruktoren · 2. Widgets · 3. Bedingungen und Listen · 4. Async und Fehler · 5. Auth über Provider (Stufe 2)

---

## 1. Klassen und Konstruktoren

```dart
class Note {
  final int? id; // nullable: noch nicht gespeichert
  final String title;
  final List<String> tags;
  final DateTime createdAt;

  // Reihenfolge beim Anlegen:
  //  1) Parameter / "this.xyz" (initializing formals)
  //  2) Initializer list (nach dem ":"): läuft VOR dem Body, kein Zugriff auf "this"
  //  3) Body ({ ... }): läuft NACH dem Anlegen der Felder
  Note({this.id, required this.title, List<String>? tags, DateTime? createdAt})
    : tags = tags ?? [],
      createdAt = createdAt ?? DateTime.now();

  Note copyWith({String? title, List<String>? tags}) =>
      Note(id: id, title: title ?? this.title, tags: tags ?? this.tags, createdAt: createdAt);
}
```

Regeln:

- `final`: wird genau einmal gesetzt und muss gesetzt sein, **bevor der Body läuft** (per `this.x` oder Initializer list).
- `late final`: darf stattdessen **einmalig im Body** gesetzt werden:

  ```dart
  class Example {
    late final String label;
    Example(int n) {
      label = 'Nr. $n'; // erlaubt, weil late final
      // weiterer Code, der NACH dem Anlegen laufen soll
    }
  }
  ```

- `required`: Pflicht bei benannten Parametern. Ohne `required` muss der Parameter nullable sein oder einen Default haben.
- `??` nimm links, außer es ist `null`, dann rechts. `??=` setzt nur, wenn `null`. `?.` ruft nur auf, wenn nicht `null`. `!` behauptet "nicht null" (stürzt ab, wenn doch).
- Default-Liste: `this.tags = const []` ist **unveränderlich** (`.add` wirft einen Fehler). `tags ?? []` erzeugt eine neue, veränderliche Liste.

---

## 2. Widgets

### Welches Gerüst?

| Brauche ich ... | Nimm |
|---|---|
| nur Parameter, kein eigener Zustand | `StatelessWidget` |
| eigenen Zustand, Controller oder Lifecycle (`initState`, `dispose`) | `StatefulWidget` |
| Provider lesen, sonst nichts | `ConsumerWidget` |
| Provider lesen **und** eigenen Zustand/Controller | `ConsumerStatefulWidget` |

### StatelessWidget

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const SafeArea(
        child: Padding(padding: EdgeInsets.all(15), child: Text('Inhalt')),
      ),
    );
  }
}
```

### StatefulWidget

```dart
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final _controller = TextEditingController();
  int _count = 0;

  @override
  void initState() {
    super.initState();
    // läuft einmal beim Start
  }

  @override
  void dispose() {
    _controller.dispose(); // Controller IMMER freigeben
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_count'),
        TextField(controller: _controller),
        TextButton(
          onPressed: () => setState(() => _count++),
          child: const Text('+1'),
        ),
      ],
    );
  }
}
```

### ConsumerWidget und ConsumerStatefulWidget (Riverpod)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyConsumer extends ConsumerWidget {
  const MyConsumer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final value = ref.watch(someProvider);   // in build: beobachten
    return const Placeholder();
  }
}

class MyConsumerStateful extends ConsumerStatefulWidget {
  const MyConsumerStateful({super.key});

  @override
  ConsumerState<MyConsumerStateful> createState() => _MyConsumerStatefulState();
}

class _MyConsumerStatefulState extends ConsumerState<MyConsumerStateful> {
  @override
  Widget build(BuildContext context) {
    // "ref" ist hier direkt als Feld verfügbar
    return const Placeholder();
  }
}
```

`ref` richtig benutzen:

- `ref.watch(provider)`: **in `build`**, baut das Widget bei Änderungen neu.
- `ref.read(provider.notifier).methode()`: **in Callbacks** (Button, `_submit`), liest einmalig und baut nicht neu.
- `ref.listen(provider, (prev, next) { ... })`: für **Seiteneffekte** (Snackbar zeigen, navigieren). Seiteneffekte gehören nie direkt in `build`, weil `build` mehrfach laufen kann.

### Eigene Widget-Klasse statt Hilfsfunktion

```dart
// Besser: eigene Klasse. const-fähig und mit eigenem Rebuild-Bereich.
class InfoTile extends StatelessWidget {
  const InfoTile({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [Text(label), const SizedBox(width: 8), Text(value)]);
  }
}

// Statt: Widget _buildTile(String label, String value) { ... }
// Diese Funktion läuft bei jedem Rebuild des Eltern-Widgets mit, ist nicht const
// und nicht einzeln testbar. Wichtig: Der Rückgabewert muss auch wirklich im
// Widget-Baum landen, sonst passiert nichts.
```

### Nach einem `await`: `mounted` prüfen

In einem `State` (oder `ConsumerState`): `if (!mounted) return;`.
In einem Builder-Callback oder bei einem `BuildContext`-Parameter: `if (!context.mounted) return;`.
Das Widget kann während des Wartens schon entfernt worden sein.

---

## 3. Bedingungen und Listen

```dart
final number = 1;

// Ternary (if/else als Ausdruck)
final label = number == 1 ? 'eins' : 'andere';

// Verschachtelte Ternarys sind schwer lesbar:
final oldStyle = number == 1
    ? [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))]
    : number == 2
    ? [IconButton(onPressed: () {}, icon: const Icon(Icons.close))]
    : null;

// Besser: switch-Ausdruck (Dart 3). "_" fängt alles Übrige ab.
final actions = switch (number) {
  1 => [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
  2 => [IconButton(onPressed: () {}, icon: const Icon(Icons.close))],
  _ => null,
};

// Als Funktion mit nullable Ergebnis
bool? hi() => switch (number) {
  1 => true,
  2 => false,
  _ => null,
};

// Auf Typen prüfen (so arbeitet auch error_snackbar.dart)
String describe(Object e) => switch (e) {
  FormatException() => 'Falsches Format',
  ArgumentError() => 'Falsches Argument',
  _ => 'Unbekannter Fehler',
};
```

### `if` und `for` direkt in Listen

```dart
Column(
  children: [
    const Text('Titel'),
    if (isAdmin) const Text('Nur für Admins'),
    for (final name in names) Text(name),

    // Mehrere Widgets pro Durchlauf: Spread "..." mit eigener Liste
    for (final name in names) ...[Text(name), const SizedBox(height: 8)],
  ],
)
```

Häufiger Fehler: `for` und `if` gelten nur für das **direkt folgende Element**.

```dart
// FALSCH: nur SizedBox gehört zur Schleife, "pair" ist beim ListTile unbekannt
for (final pair in favorites)
  const SizedBox(height: 10),
ListTile(title: Text(pair.asLowerCase)),

// RICHTIG: pro Durchlauf ein Element
for (final pair in favorites)
  ListTile(title: Text(pair.asLowerCase)),
```

---

## 4. Async und Fehler

```dart
// In einem State/ConsumerState
Future<void> _save() async {
  setState(() => _loading = true);
  try {
    await ref.read(someProvider.notifier).save();
    if (!mounted) return;
    // Erfolg anzeigen
  } catch (e) {
    if (!mounted) return;
    context.showError(e); // Extension aus utils/error_snackbar.dart
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}
```

- `finally` läuft immer, auch bei `return` im `try`.
- Button während des Ladens sperren: `onPressed: _loading ? null : _save`.
- `ScaffoldMessenger.of(context)` vor dem `await` zu holen ist die Alternative zum `mounted`-Check.

---

## 5. Auth über Provider (Stufe 2)

Idee: **Screens kennen Supabase nicht.** Ein Provider kapselt Supabase und hält den aktuellen Nutzer. Die `AppShell` schaut nur auf diesen Nutzer. Login und Signup navigieren **nie selbst**, die Shell wechselt von allein.

### Setup einmalig

```
flutter pub add supabase_flutter flutter_dotenv riverpod_annotation
flutter pub add dev:riverpod_generator dev:build_runner
dart run build_runner build --delete-conflicting-outputs
```

In der `pubspec.yaml` (bei `.env` als Asset):

```yaml
flutter:
  assets:
    - .env
```

`.env` gehört in die `.gitignore`, im Repo liegt nur `.env.example`. In die App darf nur der **Publishable/Anon-Key**, nie der `service_role`-Key.

`main.dart`:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('SUPABASE_ANON_KEY'),
  );
  runApp(const ProviderScope(child: MyApp()));
}
```

### `lib/providers/auth_provider.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

/// Hält den eingeloggten Nutzer (null = ausgeloggt).
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  GoTrueClient get _auth => Supabase.instance.client.auth;

  @override
  User? build() {
    final sub = _auth.onAuthStateChange.listen((data) {
      state = data.session?.user;
    });
    ref.onDispose(sub.cancel);
    return _auth.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password) {
    return _auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

Der Provider heißt nach der Generierung `authProvider` (der Namensteil `Notifier` entfällt). Steht in der `.g.dart` ein anderer Name, nimm den.

### `lib/screens/auth_screen.dart` (Login und Signup in einem Screen)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../utils/error_snackbar.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;
  bool _hidden = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final auth = ref.read(authProvider.notifier);
    try {
      if (_isLogin) {
        await auth.signIn(_email.text.trim(), _password.text);
      } else {
        final res = await auth.signUp(_email.text.trim(), _password.text);
        if (!mounted) return;
        if (res.session == null) {
          // E-Mail-Bestätigung ist aktiv: es gibt noch keine Session
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bitte bestätige deine E-Mail-Adresse.')),
          );
        }
      }
      // Kein Navigator: die AppShell wechselt selbst, sobald ein Nutzer da ist.
    } catch (e) {
      if (!mounted) return;
      context.showError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-Mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _password,
                obscureText: _hidden,
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(_hidden ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_isLogin ? 'Anmelden' : 'Registrieren'),
                ),
              ),
              TextButton(
                onPressed: _loading ? null : () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'Noch kein Konto? Registrieren' : 'Schon ein Konto? Anmelden',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

Warum ein Screen mit Umschalter statt zwei Screens: Läge Signup per `Navigator.push` über Login, bliebe es nach dem Login oben auf dem Stack liegen, obwohl die Shell längst zum Home-Screen gewechselt hat.

Farben kommen aus dem Theme (`FilledButton` nimmt die Primärfarbe), nicht hart aus `Colors.blue`, damit Dark Mode funktioniert.

### `AppShell` mit Weiche

```dart
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    if (user == null) return const AuthScreen();
    return const HomeScreen();
  }
}
```

Ausloggen irgendwo in der App: `ref.read(authProvider.notifier).signOut();`

### Wenn Fehler angezeigt werden sollen

`error_snackbar.dart` in Stufe 2 um zwei Zweige im `switch` ergänzen: `AuthException` (Meldungen übersetzen) und `PostgrestException` (nach `code`), jeweils mit eigener `_translate…`-Methode.
