import 'package:flutter/material.dart';
import '../widgets/checkbox_list.dart';
import '../widgets/custom_app_bar.dart';
import '../models/entry_model.dart';
import '../services/storage_service.dart';

class SymptomScreen extends StatefulWidget {
  final PageController pageController;
  final VoidCallback toggleThemeMode;

  const SymptomScreen({
    super.key,
    required this.pageController,
    required this.toggleThemeMode,
  });

  @override
  _SymptomScreenState createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final List<Map<String, dynamic>> symptoms = [
    {"title": "Müdigkeit", "value": null},
    {"title": "Trockene Haut", "value": null},
    {"title": "Verdauungsprobleme", "value": null},
  ];

  DateTime selectedDateTime = DateTime.now();
  bool isEditMode = false;

  void saveEntry() async {
    final entry = Entry(
      date: selectedDateTime,
      triggers: {},
      symptoms: {
        "Müdigkeit": symptoms[0]["value"]?.toString() ?? '',
        "Trockene Haut": symptoms[1]["value"]?.toString() ?? '',
        "Verdauungsprobleme": symptoms[2]["value"]?.toString() ?? '',
      },
    );
    await StorageService().saveEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Eintrag gespeichert!")),
    );
  }

  void _addSymptom() {
    String newSymptomName = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isEditMode ? 'Edit Symptom' : 'Add Symptom'),
          content: TextField(
            onChanged: (value) {
              newSymptomName = value;
            },
            decoration: const InputDecoration(hintText: "Enter symptom name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newSymptomName.trim().isNotEmpty) {
                  setState(() {
                    symptoms.add({'title': newSymptomName, 'value': null});
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _editSymptom(int index) {
    String editedSymptomName = symptoms[index]['title'];
    final controller = TextEditingController(text: editedSymptomName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Symptom'),
          content: TextField(
            controller: controller,
            onChanged: (value) {
              editedSymptomName = value;
            },
            decoration: const InputDecoration(hintText: "Enter symptom name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (editedSymptomName.trim().isNotEmpty) {
                  setState(() {
                    symptoms[index]['title'] = editedSymptomName;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSymptom(int index) {
    setState(() {
      symptoms.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Symptome',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CheckboxList(
              items: symptoms,
              onChanged: (index, value) {
                setState(() {
                  symptoms[index]['value'] = value;
                });
              },
              onEdit: _editSymptom,
              onDelete: _deleteSymptom,
              isEditMode: isEditMode,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _addSymptom,
                  child: Text(isEditMode ? "Edit Symptom" : "Add Symptom"),
                ),
                ElevatedButton(
                  onPressed: saveEntry,
                  child: const Text("Speichern"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
