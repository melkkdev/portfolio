import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/common/image_paths.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ImagePaths.init();
  runApp(const PortfolioApp());
}
