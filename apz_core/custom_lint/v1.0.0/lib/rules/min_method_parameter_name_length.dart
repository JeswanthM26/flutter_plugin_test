import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/src/lint_codes.dart' as custom_lint;

class MinMethodParameterNameLength extends DartLintRule {
  MinMethodParameterNameLength() : super(code: _code);

  static const int minLength = 3;

  static final custom_lint.LintCode _code = custom_lint.LintCode(
      name: 'min_method_parameter_name_length',
      problemMessage:
          'Parameter names should be at least $minLength characters long.',
      correctionMessage:
          'Use a more descriptive name instead of short names like "x" or "a".',
      errorSeverity: ErrorSeverity.ERROR);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFormalParameter((node) {
      final paramLength = node.name?.length ?? 0;

      final element = node.declaredElement;
      if (paramLength < minLength && element != null) {
        reporter.atElement(element, code);
      }
    });
  }
}
