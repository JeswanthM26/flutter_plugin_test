import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/src/lint_codes.dart' as custom_lint;
import 'package:analyzer/dart/ast/ast.dart';

class MaxClassLines extends DartLintRule {
  MaxClassLines() : super(code: _code);

  static const maxLines = 300;

  static final custom_lint.LintCode _code = custom_lint.LintCode(
      name: 'max_class_lines',
      problemMessage: 'Class should not exceed $maxLines lines.',
      correctionMessage: 'Refactor your class to have fewer lines.',
      errorSeverity: ErrorSeverity.ERROR);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final CompilationUnit? root =
          node.thisOrAncestorOfType<CompilationUnit>();
      if (root == null) return;

      final lineInfo = root.lineInfo;
      final startLine = lineInfo.getLocation(node.offset).lineNumber;
      final endLine = lineInfo.getLocation(node.end).lineNumber;
      final lineCount = endLine - startLine + 1;

      final element = node.declaredElement;
      if (lineCount > maxLines && element != null) {
        reporter.atElement(element, code);
      }
    });
  }
}
