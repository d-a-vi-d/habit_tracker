import 'package:flutter/material.dart';

class CheckboxList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Function(int, bool?) onChanged;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final bool isEditMode;

  const CheckboxList({
    super.key,
    required this.items,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index]['title'] ?? ''),
          trailing: isEditMode
              ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => onEdit(index),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => onDelete(index),
              ),
            ],
          )
              : null,
          leading: isEditMode
              ? null
              : Checkbox(
            value: items[index]['value'], // Allow value to be null
            tristate: true,
            onChanged: (value) => onChanged(index, value),
          ),
        );
      },
    );
  }
}