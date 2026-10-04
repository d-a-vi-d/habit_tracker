import 'package:flutter/material.dart';
import '../widgets/checkbox_list.dart';
import '../widgets/custom_app_bar.dart';
import '../models/entry_model.dart';
import '../services/storage_service.dart';
import '../widgets/slider_widget.dart';

class TriggerScreen extends StatefulWidget {
  final PageController pageController;
  final VoidCallback toggleThemeMode;

  const TriggerScreen({super.key, required this.pageController, required this.toggleThemeMode});

  @override
  _TriggerScreenState createState() => _TriggerScreenState();
}

class _TriggerScreenState extends State<TriggerScreen> {
  final List<Map<String, dynamic>> triggers_short = [
    {"title": "Weizen", "value": null},
    {"title": "Kohlenhydrate", "value": null},
    {"title": "Zucker", "value": null},
  ];

  final List<Map<String, dynamic>> triggers_long = [
    {"title": "Trinken", "value": 0.0, "start": 0.0, "end": 3000.0, "step": 250.0},
    {"title": "Draussen", "value": 0.0, "start": 0.0, "end": 3.0, "step": 0.2},
    {"title": "Schlafen", "value": 0.0, "start": 0.0, "end": 12.0, "step": 0.25},
  ];

  DateTime selectedDateTime = DateTime.now();
  bool isEditMode = false;

  String _getWeekday(DateTime date) {
    const weekdays = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    return weekdays[date.weekday % 7];
  }

  void saveShortTriggers() async {
    final entry = Entry(
      date: DateTime(
        selectedDateTime.year ?? DateTime.now().year,
        selectedDateTime.month ?? DateTime.now().month,
        selectedDateTime.day ?? DateTime.now().day,
        selectedDateTime.hour ?? 0,
        selectedDateTime.minute ?? 0,
      ),
      triggers: {
        "Weizen": triggers_short[0]["value"],
        "Kohlenhydrate": triggers_short[1]["value"],
        "Zucker": triggers_short[2]["value"],
      },
      symptoms: {},
    );
    await StorageService().saveEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Eintrag gespeichert!")),
    );
  }

  void saveLongTriggers() async {
    final entry = Entry(
      date: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      triggers: {
        "Trinken": triggers_long[0]["value"],
        "Draussen": triggers_long[1]["value"],
        "Schlafen": triggers_long[2]["value"],
      },
      symptoms: {},
    );
    await StorageService().saveEntry(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Eintrag gespeichert!")),
    );
  }

  void _addTrigger() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTriggerName = '';
        String triggerType = 'short';
        double startValue = 0.0;
        double endValue = 100.0;
        double stepValue = 1.0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditMode ? 'Edit Trigger' : 'Add Trigger'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: triggerType,
                    onChanged: (String? newValue) {
                      setState(() {
                        triggerType = newValue!;
                      });
                    },
                    items: <String>['short', 'long']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    onChanged: (value) {
                      newTriggerName = value;
                    },
                    decoration: InputDecoration(hintText: "Enter trigger name"),
                  ),
                  if (triggerType == 'long') ...[
                    TextField(
                      onChanged: (value) {
                        startValue = double.tryParse(value) ?? 0.0;
                      },
                      decoration: InputDecoration(hintText: "Enter start value"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      onChanged: (value) {
                        endValue = double.tryParse(value) ?? 100.0;
                      },
                      decoration: InputDecoration(hintText: "Enter end value"),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      onChanged: (value) {
                        stepValue = double.tryParse(value) ?? 1.0;
                      },
                      decoration: InputDecoration(hintText: "Enter step value"),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (triggerType == 'short') {
                        triggers_short.add({'title': newTriggerName, 'value': null});
                      } else {
                        triggers_long.add({
                          'title': newTriggerName,
                          'value': startValue,
                          'start': startValue,
                          'end': endValue,
                          'step': stepValue,
                        });
                      }
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editLongTrigger(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedTriggerName = triggers_long[index]['title'];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Trigger'),
              content: TextField(
                onChanged: (value) {
                  editedTriggerName = value;
                },
                decoration: InputDecoration(hintText: "Enter trigger name"),
                controller: TextEditingController(text: triggers_long[index]['title']),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      triggers_long[index]['title'] = editedTriggerName;
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Trigger',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CheckboxList(
                    items: triggers_short,
                    onChanged: (index, value) {
                      setState(() {
                        triggers_short[index]["value"] = value;
                      });
                    },
                    onEdit: (index) {
                      // Edit Funktion für kurze Trigger (kann ergänzt werden)
                    },
                    onDelete: (index) {
                      setState(() {
                        triggers_short.removeAt(index);
                      });
                    },
                    isEditMode: isEditMode,
                  ),
                ),
                if (!isEditMode)
                  ElevatedButton(
                    onPressed: saveShortTriggers,
                    child: Text("Speichern"),
                  ),
              ],
            ),
            Column(
              children: [
                ...triggers_long.map((item) {
                  int index = triggers_long.indexOf(item);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SliderWidget(
                          value: item['value'] ?? item['start'],
                          min: item['start'],
                          max: item['end'],
                          divisions: ((item['end'] - item['start']) / item['step']).round(),
                          label: "${item['title']}: ${item['value']?.toStringAsFixed(1) ?? item['start'].toStringAsFixed(1)}",
                          onChanged: (value) => setState(() => item['value'] = value),
                        ),
                      ),
                      if (isEditMode)
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editLongTrigger(index),
                        ),
                    ],
                  );
                }),
                if (!isEditMode)
                  ElevatedButton(
                    onPressed: saveLongTriggers,
                    child: Text("Speichern"),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _addTrigger,
                  child: Text("Add Trigger"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
