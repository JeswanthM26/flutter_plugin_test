import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/src/lint_codes.dart' as custom_lint;

class MaxFileLines extends DartLintRule {
  MaxFileLines() : super(code: _code);

  static const maxLines = 500;

  static final custom_lint.LintCode _code = custom_lint.LintCode(
      name: 'max_file_lines',
      problemMessage: 'This file exceeds $maxLines lines.',
      correctionMessage: 'Consider splitting the file into smaller parts.',
      errorSeverity: ErrorSeverity.ERROR);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      final lineInfo = node.lineInfo;

      final totalLines = lineInfo.lineCount;
      if (totalLines > maxLines) {
        reporter.atOffset(offset: 0, length: 10, errorCode: _code);
      }
    });
  }
}
