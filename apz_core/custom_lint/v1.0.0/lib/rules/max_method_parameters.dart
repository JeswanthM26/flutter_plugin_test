import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/src/lint_codes.dart' as custom_lint;

class MaxMethodParameters extends DartLintRule {
  MaxMethodParameters() : super(code: _code);

  static const maxParams = 5;

  static final custom_lint.LintCode _code = custom_lint.LintCode(
      name: 'max_method_parameters',
      problemMessage:
          'Methods should not have more than $maxParams parameters.',
      correctionMessage:
          'Consider refactoring by using an object or named parameters.',
      errorSeverity: ErrorSeverity.ERROR);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
      final paramCount = node.parameters?.parameters.length ?? 0;

      final element = node.declaredElement;
      if (paramCount > maxParams && element != null) {
        reporter.atElement(element, code);
      }
    });
  }
}
