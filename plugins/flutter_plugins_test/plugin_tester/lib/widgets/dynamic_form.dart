import 'package:flutter/material.dart';
import '../models/plugin_metadata.dart';

class DynamicForm extends StatefulWidget {
  final List<PluginField> fields;
  final Map<String, dynamic> formData;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const DynamicForm({
    Key? key,
    required this.fields,
    required this.formData,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.formData);
  }

  void _updateField(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
    widget.onChanged(_formData);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.fields.map((field) {
        final value = _formData[field.key] ?? field.defaultValue;
        switch (field.type) {
          case 'text':
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                initialValue: value?.toString() ?? '',
                decoration: InputDecoration(
                  labelText: field.label,
                ),
                onChanged: (val) => _updateField(field.key, val),
              ),
            );
          case 'int':
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                initialValue: value?.toString() ?? '',
                decoration: InputDecoration(
                  labelText: field.label,
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) => _updateField(field.key, int.tryParse(val)),
              ),
            );
          case 'bool':
            return SwitchListTile(
              title: Text(field.label),
              value: value == true,
              onChanged: (val) => _updateField(field.key, val),
            );
          case 'dropdown':
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: DropdownButtonFormField<String>(
                value: value?.toString() ?? (field.options?.isNotEmpty == true ? field.options!.first : null),
                decoration: InputDecoration(labelText: field.label),
                items: field.options?.map((opt) => DropdownMenuItem(
                      value: opt,
                      child: Text(opt),
                    )).toList(),
                onChanged: (val) => _updateField(field.key, val),
              ),
            );
          case 'date':
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(field.label),
                subtitle: Text(value != null ? value.toString().split(' ').first : 'Select date'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: value is DateTime ? value : DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _updateField(field.key, picked);
                  }
                },
              ),
            );
          case 'color':
            // For simplicity, use a text field for color hex input
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextFormField(
                initialValue: value?.toString() ?? '',
                decoration: InputDecoration(
                  labelText: field.label + ' (Hex)',
                  hintText: '#RRGGBB',
                ),
                onChanged: (val) => _updateField(field.key, val),
              ),
            );
          default:
            return SizedBox.shrink();
        }
      }).toList(),
    );
  }
} 