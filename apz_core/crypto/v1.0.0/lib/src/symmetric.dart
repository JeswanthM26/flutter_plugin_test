part of "../apz_crypto.dart";

class _Symmetric {
  Uint8List encrypt({
    required final Uint8List textBytes,
    required final Uint8List symtKey,
    required final Uint8List symtIV,
  }) {
    try {
      final AEADParameters<CipherParameters> aeadParameters =
          AEADParameters<CipherParameters>(
            KeyParameter(symtKey),
            128,
            symtIV,
            Uint8List(0),
          );
      final BlockCipher cipher = BlockCipher(Constants.symtAlgo)
        ..init(true, aeadParameters);
      final Uint8List cipherData = cipher.process(
        Uint8List.fromList(textBytes),
      );
      return cipherData;
    } on Exception catch (_) {
      rethrow;
    }
  }

  Uint8List decrypt({
    required final Uint8List cipherData,
    required final Uint8List symtKey,
    required final Uint8List symtIV,
  }) {
    try {
      final AEADParameters<CipherParameters> aeadParameters =
          AEADParameters<CipherParameters>(
            KeyParameter(symtKey),
            128,
            symtIV,
            Uint8List(0),
          );
      final BlockCipher cipher = BlockCipher(Constants.symtAlgo)
        ..init(false, aeadParameters);
      final Uint8List decryptedBytes = cipher.process(cipherData);
      return decryptedBytes;
    } on Exception catch (_) {
      rethrow;
    }
  }
}
