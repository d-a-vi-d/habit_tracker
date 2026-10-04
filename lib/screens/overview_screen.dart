import 'package:flutter/material.dart';
import '../models/entry_model.dart';
import '../services/storage_service.dart';
import '../widgets/custom_app_bar.dart';

class OverviewScreen extends StatefulWidget {
  final PageController pageController;
  final VoidCallback toggleThemeMode;

  const OverviewScreen({
    super.key,
    required this.pageController,
    required this.toggleThemeMode,
  });

  @override
  _OverviewScreenState createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  DateTime selectedDateTime = DateTime.now();
  bool isEditMode = false;

  List<Entry> allEntries = [];
  String? selectedTrigger;
  String? selectedSymptom;
  List<String> allTriggers = [];
  List<String> allSymptoms = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await StorageService().getEntries();
    setState(() {
      allEntries = entries;
      // Alle Trigger außer 'nicht relevant'
      allTriggers = entries
          .expand((e) => e.triggers.keys)
          .where((t) => t != 'nicht relevant')
          .toSet()
          .toList();
      // Alle Symptome, unabhängig von Wert
      allSymptoms = entries
          .expand((e) => e.symptoms.keys)
          .toSet()
          .toList();
    });
  }

  // Analyse: Symptome nach Trigger (innerhalb 5h nach Trigger)
  Map<String, int> _analyzeFromTrigger(String trigger) {
    Map<String, int> result = {};
    for (var entry in allEntries) {
      if (entry.triggers.keys.contains(trigger)) {
        for (var other in allEntries) {
          final diff = other.date.difference(entry.date).inHours;
          if (diff > 0 && diff <= 5) {
            other.symptoms.forEach((symptom, value) {
              if (value == 'ja') {
                result[symptom] = (result[symptom] ?? 0) + 1;
              }
            });
          }
        }
      }
    }
    return result;
  }

  // Analyse: Trigger vor Symptom (innerhalb 5h vor Symptom)
  Map<String, int> _analyzeFromSymptom(String symptom) {
    Map<String, int> result = {};
    for (var entry in allEntries) {
      if (entry.symptoms[symptom] == 'ja') {
        for (var other in allEntries) {
          final diff = entry.date.difference(other.date).inHours;
          if (diff > 0 && diff <= 5) {
            for (var trigger in other.triggers.keys.where((t) => t != 'nicht relevant')) {
              result[trigger] = (result[trigger] ?? 0) + 1;
            }
          }
        }
      }
    }
    return result;
  }

  Widget _buildAnalysis() {
    if (selectedTrigger != null) {
      final analysis = _analyzeFromTrigger(selectedTrigger!);
      return _buildAnalysisList("Häufige Symptome nach Trigger", analysis);
    }
    if (selectedSymptom != null) {
      final analysis = _analyzeFromSymptom(selectedSymptom!);
      return _buildAnalysisList("Mögliche Trigger vor Symptom", analysis);
    }
    return const SizedBox.shrink();
  }

  Widget _buildAnalysisList(String title, Map<String, int> data) {
    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (sorted.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text("$title: Keine Daten gefunden."),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...sorted.take(5).map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text("${e.key}: ${e.value}x"),
        )),
      ],
    );
  }

  /// Baut die Tabelle mit Einträgen am selben Tag, gefiltert nach ausgewähltem Trigger oder Symptom
  Widget _buildEntriesTable() {
    if (selectedTrigger == null && selectedSymptom == null) return const SizedBox.shrink();

    // Filtern der Einträge, die am selben Tag vorkommen wie mindestens ein Entry mit dem Trigger oder Symptom
    Set<DateTime> relevantDates = {};

    if (selectedTrigger != null) {
      for (var e in allEntries) {
        if (e.triggers.keys.contains(selectedTrigger)) {
          relevantDates.add(DateTime(e.date.year, e.date.month, e.date.day));
        }
      }
    } else if (selectedSymptom != null) {
      for (var e in allEntries) {
        if (e.symptoms[selectedSymptom] == 'ja') {
          relevantDates.add(DateTime(e.date.year, e.date.month, e.date.day));
        }
      }
    }

    // Alle Einträge, die an den relevanten Tagen vorkommen, sortiert nach Datum & Zeit
    List<Entry> entriesFiltered = allEntries.where((e) =>
        relevantDates.contains(DateTime(e.date.year, e.date.month, e.date.day))
    ).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (entriesFiltered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: const Text("Keine Einträge am selben Tag gefunden."),
      );
    }

    // Spaltenüberschriften: Datum, Zeit, Trigger und Symptome (alle vorkommenden in filtered)
    // Um Übersicht zu behalten: Alle Trigger und Symptome aus den gefilterten Einträgen
    final triggersInFiltered = entriesFiltered
        .expand((e) => e.triggers.keys.where((t) => t != 'nicht relevant'))
        .toSet()
        .toList();
    final symptomsInFiltered = entriesFiltered
        .expand((e) => e.symptoms.entries.where((s) => s.value == 'ja').map((e) => e.key))
        .toSet()
        .toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Datum')),
          const DataColumn(label: Text('Zeit')),
          // Nur bei Trigger Auswahl zeigen wir Trigger-Spalten, bei Symptom-Auswahl nur Trigger + Symptome
          if (selectedTrigger != null)
            ...triggersInFiltered.map((t) => DataColumn(label: Text("Trig: $t"))),
          ...symptomsInFiltered.map((s) => DataColumn(label: Text("Symp: $s"))),
        ],
        rows: entriesFiltered.map((entry) {
          return DataRow(cells: [
            DataCell(Text("${entry.date.year}-${entry.date.month.toString().padLeft(2,'0')}-${entry.date.day.toString().padLeft(2,'0')}")),
            DataCell(Text("${entry.date.hour.toString().padLeft(2,'0')}:${entry.date.minute.toString().padLeft(2,'0')}")),
            if (selectedTrigger != null)
              ...triggersInFiltered.map((t) => DataCell(Text(entry.triggers.containsKey(t) ? "✓" : ""))),
            ...symptomsInFiltered.map((s) => DataCell(Text(entry.symptoms[s] == 'ja' ? "✓" : ""))),
          ]);
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Overview',
        selectedDateTime: selectedDateTime,
        onDateTimeChanged: (newDateTime) {
          setState(() {
            selectedDateTime = newDateTime;
          });
        },
        toggleThemeMode: widget.toggleThemeMode,
        isEditMode: isEditMode,
        onToggleEditMode: () {
          setState(() {
            isEditMode = !isEditMode;
          });
        },
      ),
      body: allEntries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              hint: const Text("Trigger oder Symptom auswählen"),
              value: selectedTrigger ?? selectedSymptom,
              items: [
                ...allTriggers.map(
                      (t) => DropdownMenuItem(
                    value: t,
                    child: Text("Trigger: $t"),
                  ),
                ),
                const DropdownMenuItem(
                  enabled: false,
                  child: Divider(thickness: 1),
                ),
                ...allSymptoms.map(
                      (s) => DropdownMenuItem(
                    value: s,
                    child: Text("Symptom: $s"),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  if (allTriggers.contains(value)) {
                    selectedTrigger = value;
                    selectedSymptom = null;
                  } else if (allSymptoms.contains(value)) {
                    selectedSymptom = value;
                    selectedTrigger = null;
                  }
                });
              },
              isExpanded: true,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnalysis(),
                  const SizedBox(height: 16),
                  _buildEntriesTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
