import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/src/lint_codes.dart' as custom_lint;

class MinVariableNameLength extends DartLintRule {
  MinVariableNameLength() : super(code: _code);

  static const int minLength = 3;

  static final custom_lint.LintCode _code = custom_lint.LintCode(
      name: 'min_variable_name_length',
      problemMessage: 'Names should be at least $minLength characters long.',
      correctionMessage:
          'Use a more descriptive name instead of short names like "x" or "a".',
      errorSeverity: ErrorSeverity.ERROR);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclaration((node) {
      final paramLength = node.name.length;

      final element = node.declaredElement;
      if (paramLength < minLength && element != null) {
        reporter.atElement(element, code);
      }
    });
  }
}
