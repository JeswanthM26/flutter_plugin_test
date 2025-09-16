import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:custom_lint_core/src/lint_codes.dart' as custom_lint;
import 'package:analyzer/dart/ast/ast.dart';

class MaxMethodLines extends DartLintRule {
  MaxMethodLines() : super(code: _code);

  static const maxLines = 80;

  static final custom_lint.LintCode _code = custom_lint.LintCode(
      name: 'max_method_lines',
      problemMessage: 'Methods should not exceed $maxLines lines.',
      correctionMessage: 'Refactor your method to have fewer lines.',
      errorSeverity: ErrorSeverity.ERROR);

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addMethodDeclaration((node) {
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

  @override
  List<Fix> getFixes() => [];
}
