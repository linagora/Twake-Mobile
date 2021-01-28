import 'package:sentry_flutter/sentry_flutter.dart';

final SentryClient _sentry = SentryClient(
  SentryOptions(
      dsn:
          'https://2efc542ea1da4785aefcb93d55538e14@o310327.ingest.sentry.io/5544661'),
);

bool get isInDebugMode {
  // Assume you're in production mode.
  bool inDebugMode = false;

  // Assert expressions are only evaluated during development. They are ignored
  // in production. Therefore, this code only sets `inDebugMode` to true
  // in a development environment.
  assert(inDebugMode = true);
  print('IN DEBUG: $inDebugMode');

  return inDebugMode;
}

Future<void> reportError(dynamic error, dynamic stackTrace) async {
  // Print the exception to the console.
  print('Caught error: $error');
  if (isInDebugMode) {
    // Print the full stacktrace in debug mode.
    print(stackTrace);
  } else {
    // Send the Exception and Stacktrace to Sentry in Production mode.
    _sentry.captureException(
      error,
      stackTrace: stackTrace,
    );
  }
}
