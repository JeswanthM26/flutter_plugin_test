import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/src/lint_codes.dart' as custom_lint;

class MaxFileNameLength extends DartLintRule {
  MaxFileNameLength() : super(code: _code);

  static const int maxFileNameLength = 40;

  static final custom_lint.LintCode _code = custom_lint.LintCode(
      name: 'max_file_name_length',
      problemMessage:
          'File name should not exceed $maxFileNameLength characters.',
      correctionMessage:
          'Rename the file to be shorter than $maxFileNameLength characters.',
      errorSeverity: ErrorSeverity.ERROR);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      var fileName = node.declaredElement?.source.shortName ?? "";
      fileName = fileName.replaceAll(".dart", "");
      final fileNameLength = fileName.length;
      if (fileNameLength > maxFileNameLength) {
        reporter.atOffset(offset: 0, length: 10, errorCode: _code);
      }
    });
  }
}
