import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'data/portfolio_state.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  PortfolioState? state;
  try {
    state = await PortfolioState.load();
  } catch (e) {
    debugPrint('Firestore load failed: $e');
  }

  runApp(PortfolioApp(state: state));
}
