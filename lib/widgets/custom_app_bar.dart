import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final DateTime selectedDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;
  final VoidCallback toggleThemeMode;
  final bool isEditMode;
  final VoidCallback onToggleEditMode;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
    required this.toggleThemeMode,
    required this.isEditMode,
    required this.onToggleEditMode,
  });

  String _getWeekday(DateTime date) {
    const weekdays = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];
    return weekdays[date.weekday % 7];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        Row(
          children: [
            TextButton(
              onPressed: () async {
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDateTime,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  onDateTimeChanged(DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedDateTime.hour,
                    selectedDateTime.minute,
                  ));
                }
              },
              child: Text(
                "${_getWeekday(selectedDateTime)} ${selectedDateTime.day}.${selectedDateTime.month}",
                style: const TextStyle(fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () async {
                final TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                );
                if (pickedTime != null) {
                  onDateTimeChanged(DateTime(
                    selectedDateTime.year,
                    selectedDateTime.month,
                    selectedDateTime.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  ));
                }
              },
              child: Text(
                "${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}",
                style: const TextStyle(fontSize: 18),
              ),
            ),

            // Dropdown-Menü mit "..."
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'toggle_theme') {
                  toggleThemeMode();
                } else if (value == 'toggle_edit') {
                  onToggleEditMode();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'toggle_theme',
                  child: Row(
                    children: const [
                      Icon(Icons.brightness_6),
                      SizedBox(width: 8),
                      Text('Helligkeit wechseln'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle_edit',
                  child: Row(
                    children: [
                      Icon(isEditMode ? Icons.check : Icons.edit),
                      const SizedBox(width: 8),
                      Text(isEditMode ? 'Bearbeitung beenden' : 'Bearbeitungsmodus'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}


/*
AppBar(
        title: Text("Symptome"),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () async {
                  final DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (selectedDate != null) {
                    setState(() {
                      selectedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedDateTime?.hour ?? 0,
                        selectedDateTime?.minute ?? 0,
                      );
                    });
                  }
                },
                child: Text(
                  "${selectedDateTime != null ? "${_getWeekday(selectedDateTime!)} " : ''}"
                      "${selectedDateTime?.day ?? DateTime.now().day}.${selectedDateTime?.month ?? DateTime.now().month}",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
                  );

                  if (pickedTime != null) {
                    setState(() {
                      selectedDateTime = DateTime(
                        selectedDateTime?.year ?? DateTime.now().year,
                        selectedDateTime?.month ?? DateTime.now().month,
                        selectedDateTime?.day ?? DateTime.now().day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                },
                child: Text(
                  "${selectedDateTime?.hour ?? DateTime.now().hour}:${selectedDateTime?.minute ?? DateTime.now().minute}",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                icon: Icon(Icons.brightness_6),
                onPressed: widget.toggleThemeMode,
              ),
              IconButton(
                icon: Icon(isEditMode ? Icons.check : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditMode = !isEditMode;
                  });
                },
              ),
            ],
          ),
        ],
      ),
*/