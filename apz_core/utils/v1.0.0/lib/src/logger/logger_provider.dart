import "dart:io";
import "package:apz_preference/apz_preference.dart";
import "package:apz_utils/src/logger/logger.dart";
import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:path_provider/path_provider.dart";

const String _kLogLevelKey = "apz_log_level";
const String _kFileLoggingEnabledKey = "apz_file_logging_enabled";

/// APZLoggerProvider is a singleton class that provides logging functionality
class APZLoggerProvider extends ChangeNotifier implements APZLogger {
  /// Factory constructor to ensure a single instance of APZLoggerProvider
  factory APZLoggerProvider() => _instance;

  APZLoggerProvider._internal() {
    _initLogger();
  }
  static final APZLoggerProvider _instance = APZLoggerProvider._internal();

  late Logger _logger;
  ApzPreference? _prefs;
  String? _logFilePath;
  bool _fileLoggingEnabled = false;
  APZLogLevel _currentLevel = APZLogLevel.info;
  bool _isInitialized = false;

  /// Return [APZLoggerProvider] is initialized or not.
  bool get isInitialized => _isInitialized;

  /// Initializes the logger provider, loading preferences and
  /// setting up the logger.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      _prefs = ApzPreference();

      final int? savedLogLevel =
          await _prefs?.getData(_kLogLevelKey, int) as int?;
      _currentLevel = _getLevelFromInt(savedLogLevel ?? APZLogLevel.info.index);

      final bool? savedFileLogging =
          await _prefs?.getData(_kFileLoggingEnabledKey, bool) as bool?;
      _fileLoggingEnabled = savedFileLogging ?? false;

      if (_fileLoggingEnabled) {
        await enableFileLogging();
      } else {
        _setupLogger();
      }

      _isInitialized = true;
      notifyListeners();
    } on Exception catch (e) {
      debugPrint("Error initializing logger: $e");
      _setupLogger(); // Setup with default values if initialization fails
    }
  }

  void _setupLogger() {
    _logger = Logger(
      filter: ProductionFilter(),
      printer: PrettyPrinter(
        methodCount: 3,
        colors: false,
        printEmojis: false,
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      level: _currentLevel.toLevel(),
      output: _fileLoggingEnabled && _logFilePath != null
          ? MultiOutput(<LogOutput?>[
              ConsoleOutput(),
              FileOutput(file: File(_logFilePath!)),
            ])
          : ConsoleOutput(),
    );

    /// Log a test message to verify logger is working
    debugPrint("Logger setup complete with level: $_currentLevel");
  }

  void _initLogger() {
    _setupLogger();
  }

  void _checkInitialization() {
    if (!_isInitialized) {
      throw StateError(
        """APZLoggerProvider not initialized. Call initialize() first and await its completion.""",
      );
    }
  }

  APZLogLevel _getLevelFromInt(final int index) =>
      APZLogLevel.values.firstWhere(
        (final APZLogLevel level) => level.index == index,
        orElse: () => APZLogLevel.info,
      );

  @override
  void debug(
    final Object message, [
    final Object? error,
    final StackTrace? stackTrace,
  ]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(
    final Object message, [
    final Object? error,
    final StackTrace? stackTrace,
  ]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(
    final Object message, [
    final Object? error,
    final StackTrace? stackTrace,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  @override
  Future<void> setLogLevel(final APZLogLevel level) async {
    _checkInitialization();
    _currentLevel = level;
    await _prefs?.saveData(_kLogLevelKey, level.index);
    _setupLogger();
    notifyListeners();
  }

  @override
  APZLogLevel getLogLevel() {
    _checkInitialization();
    return _currentLevel;
  }

  /// Returns a list of all available log levels
  List<APZLogLevel> get apzLogLevel => APZLogLevel.values.toList();

  @override
  Future<void> enableFileLogging() async {
    _checkInitialization();
    if (!_fileLoggingEnabled) {
      final Directory directory = await getApplicationDocumentsDirectory();
      _logFilePath = "${directory.path}/apz_logs/app.log";

      // Create the logs directory if it doesn't exist
      final Directory logDir = Directory("${directory.path}/apz_logs");

      /// Check if the directory exists before creating it
      // ignore: avoid_slow_async_io
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      _fileLoggingEnabled = true;
      await _prefs?.saveData(_kFileLoggingEnabledKey, true);
      _setupLogger();
      notifyListeners();
    }
  }

  @override
  Future<void> disableFileLogging() async {
    _checkInitialization();
    if (_fileLoggingEnabled) {
      _fileLoggingEnabled = false;
      await _prefs?.saveData(_kFileLoggingEnabledKey, false);
      _setupLogger();
      notifyListeners();
    }
  }

  @override
  bool isFileLoggingEnabled() {
    _checkInitialization();
    return _fileLoggingEnabled;
  }

  @override
  String? getLogFilePath() {
    _checkInitialization();
    return _logFilePath;
  }

  @override
  Future<void> clearLogs() async {
    _checkInitialization();
    if (_logFilePath != null) {
      final File file = File(_logFilePath!);

      /// Check if the file exists before attempting to delete it
      // ignore: avoid_slow_async_io
      final bool fileExists = await file.exists();
      if (fileExists) {
        await file.delete();
      }
      notifyListeners();
    }
  }
}
