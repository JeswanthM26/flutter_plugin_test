import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'rules/max_file_name_length.dart';
import 'rules/max_file_lines.dart';
import 'rules/max_class_lines.dart';
import 'rules/min_variable_name_length.dart';
import 'rules/max_method_lines.dart';
import 'rules/max_method_parameters.dart';
import 'rules/min_method_parameter_name_length.dart';

PluginBase createPlugin() => _APZCustomLint();

class _APZCustomLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        MaxFileNameLength(),
        MaxFileLines(),
        MaxClassLines(),
        MinVariableNameLength(),
        MaxMethodLines(),
        MaxMethodParameters(),
        MinMethodParameterNameLength(),
      ];
}
