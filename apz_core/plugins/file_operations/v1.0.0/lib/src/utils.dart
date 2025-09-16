/// Returns true if a consecutive duplicate extension is found, false otherwise.
bool hasConsecutiveDuplicateExtension(final String fileName) {
  final int lastDotIndex = fileName.lastIndexOf(".");
  if (lastDotIndex == -1 || lastDotIndex == fileName.length - 1) {
    return false; // No extension or dot at the end
  }
  final String lastExtension = fileName.substring(lastDotIndex + 1);
  final int secondLastDotIndex = fileName.lastIndexOf(".", lastDotIndex - 1);
  if (secondLastDotIndex == -1) {
    return false; // Only one extension
  }
  final String potentialSecondExtension = fileName.substring(
    secondLastDotIndex + 1,
    lastDotIndex,
  );
  return potentialSecondExtension == lastExtension;
}

///  fun to validate file names based on allowed characters and double dots.
/// Allowed characters: `(`, `)`, digits `0-9`, `_`, `-`, `.`.
/// Double dots `..` are explicitly disallowed.
/// Returns true if the filename is valid, false otherwise.
bool isValidFileName(
  final String fileName,
  {final RegExp? allowedFileNameRegex}
) {
  if (fileName.contains("..")) {
    return false;
  }
  final List<String> nameParts = fileName.split(".");
  if (nameParts.length > 2) {
    return false;
  }
  final RegExp allowedChars =
      allowedFileNameRegex ?? RegExp(r"^[a-zA-Z0-9_\-(). ]+$");
  return allowedChars.hasMatch(fileName);
}
