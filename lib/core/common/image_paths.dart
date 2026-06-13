import 'package:flutter/services.dart';

class ImagePaths {
  static const String _base = 'assets/images';
  static List<String> _assets = [];

  static Future<void> init() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    _assets = manifest.listAssets()
        .where((p) => p.startsWith('$_base/'))
        .toList()
      ..sort();
  }

  static List<String> _group(String prefix) =>
      _assets.where((p) => p.contains('/${prefix}_')).toList();

  static List<String> get copickHero => copickCollector.take(3).toList();
  static List<String> get copickCollector => _group('copick_collector');
  static List<String> get copickAdmin => _group('copick_admin');
  static List<String> get copickDesktop => _group('copick_desktop');
  static List<String> get soil => _group('soil');
  static List<String> get coupley => _group('coupley');
}
