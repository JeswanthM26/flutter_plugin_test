// Model for a single field in a plugin
class PluginField {
  final String key;
  final String label;
  final String type;
  final dynamic defaultValue;
  final List<String>? options;
  final bool optional;
  final bool required;
  final Map<String, dynamic>? dependsOn;

  PluginField({
    required this.key,
    required this.label,
    required this.type,
    this.defaultValue,
    this.options,
    this.optional = false,
    this.required = false,
    this.dependsOn,
  });

  factory PluginField.fromJson(Map<String, dynamic> json) {
    return PluginField(
      key: json['key']?.toString() ?? json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      defaultValue: json['default'] ?? json['defaultValue'],
      options: (json['options'] as List?)?.map((e) => e.toString()).toList(),
      optional: json['optional'] == true,
      required: json['required'] == true,
      dependsOn: json['dependsOn'] as Map<String, dynamic>?,
    );
  }

  bool get isRequired => required || !optional;
}

// Model for a plugin and its fields
class PluginMetadata {
  final String name;
  final List<PluginField> fields;

  PluginMetadata({
    required this.name,
    required this.fields,
  });

  factory PluginMetadata.fromJson(String name, Map<String, dynamic> json) {
    final fieldsJson = json['fields'] as List?;
    return PluginMetadata(
      name: name,
      fields: fieldsJson != null
          ? fieldsJson.map((e) => PluginField.fromJson(e)).toList()
          : [],
    );
  }
}

// Utility to parse the whole JSON map into a list of PluginMetadata
List<PluginMetadata> parsePluginMetadata(Map<String, dynamic> json) {
  return json.entries
      .map((entry) => PluginMetadata.fromJson(entry.key, entry.value))
      .toList();
} 