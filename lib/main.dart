import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  /// Wait for flutter to initialize
  WidgetsFlutterBinding.ensureInitialized();

  /// Disable landscape mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(TwakeMobileApp()));
}

class TwakeMobileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
