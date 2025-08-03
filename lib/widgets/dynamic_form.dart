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

  @override
  void didUpdateWidget(DynamicForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update form data if the widget's formData changes
    if (oldWidget.formData != widget.formData) {
      _formData = Map<String, dynamic>.from(widget.formData);
    }
  }

  void _updateField(String key, dynamic value) {
    setState(() {
      _formData[key] = value;
    });
    widget.onChanged(_formData);
  }

  Widget _buildFieldLabel(PluginField field) {
    return Row(
      children: [
        Text(
          field.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
        if (field.isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.fields.length,
      itemBuilder: (context, index) {
        final field = widget.fields[index];
        final value = _formData[field.key] ?? field.defaultValue;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel(field),
              const SizedBox(height: 8),
              _buildFieldWidget(field, value),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldWidget(PluginField field, dynamic value) {
    switch (field.type) {
      case 'text':
        return TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
            suffixIcon: field.isRequired ? const Icon(Icons.star, color: Colors.red, size: 16) : null,
          ),
          onChanged: (val) => _updateField(field.key, val),
        );
        
      case 'int':
      case 'number':
        return TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
            suffixIcon: field.isRequired ? const Icon(Icons.star, color: Colors.red, size: 16) : null,
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) => _updateField(field.key, int.tryParse(val)),
        );
        
      case 'double':
        return TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            hintText: 'Enter ${field.label.toLowerCase()}',
            suffixIcon: field.isRequired ? const Icon(Icons.star, color: Colors.red, size: 16) : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (val) => _updateField(field.key, double.tryParse(val)),
        );
        
      case 'bool':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (field.isRequired) ...[
                      const Icon(Icons.star, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      field.label,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value == true,
                onChanged: (val) => _updateField(field.key, val),
                activeColor: const Color(0xFF3F51B5),
              ),
            ],
          ),
        );
        
      case 'dropdown':
        return DropdownButtonFormField<String>(
          value: value?.toString() ?? (field.options?.isNotEmpty == true ? field.options!.first : null),
          decoration: InputDecoration(
            hintText: 'Select ${field.label.toLowerCase()}',
            suffixIcon: field.isRequired ? const Icon(Icons.star, color: Colors.red, size: 16) : null,
          ),
          items: field.options?.map((opt) => DropdownMenuItem(
            value: opt,
            child: Text(opt),
          )).toList(),
          onChanged: (val) => _updateField(field.key, val),
        );
        
      case 'date':
        return InkWell(
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? value.toString().split(' ').first : 'Select date',
                    style: TextStyle(
                      color: value != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
                if (field.isRequired) ...[
                  const Icon(Icons.star, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.calendar_today, color: Color(0xFF3F51B5)),
              ],
            ),
          ),
        );
        
      case 'color':
        return TextFormField(
          initialValue: value?.toString() ?? '',
          decoration: InputDecoration(
            labelText: '${field.label} (Hex)',
            hintText: '#RRGGBB',
            suffixIcon: field.isRequired ? const Icon(Icons.star, color: Colors.red, size: 16) : null,
          ),
          onChanged: (val) => _updateField(field.key, val),
        );
        
      case 'switch':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (field.isRequired) ...[
                      const Icon(Icons.star, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      field.label,
                      style: const TextStyle(fontSize: 16),
                    ),
                    
                  ],
                ),
              ),
              Switch(
                value: value == true,
                onChanged: (val) => _updateField(field.key, val),
                activeColor: const Color(0xFF3F51B5),
              ),
            ],
          ),
        );
        
      default:
        return const SizedBox.shrink();
    }
  }
} 