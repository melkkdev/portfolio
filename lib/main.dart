import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/portfolio_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter Web debug mode hot-restart produces a spurious
  // "Trying to render a disposed EngineFlutterView" assertion.
  // This assertion is disabled in release mode, so it never reaches production.
  if (kDebugMode) {
    FlutterError.onError = (details) {
      final msg = details.exceptionAsString();
      if (msg.contains('isDisposed') && msg.contains('EngineFlutterView')) return;
      FlutterError.presentError(details);
    };
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  PortfolioState? state;
  try {
    state = await PortfolioState.load();
  } catch (e) {
    debugPrint('Firestore load failed: $e');
  }

  runApp(PortfolioApp(state: state));
}
