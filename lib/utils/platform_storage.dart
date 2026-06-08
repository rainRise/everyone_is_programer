import 'dart:io';

import 'package:hive_ce/hive.dart';
import 'package:kazumi/utils/logger.dart';
import 'package:path_provider/path_provider.dart';

class PlatformStorage {
  static late Box<dynamic> setting;
  static String? _hivePath;

  static Future<void> init() async {
    await _prepareHivePath();

    if (Hive.isBoxOpen('setting')) {
      setting = Hive.box<dynamic>('setting');
      return;
    }

    setting = await _openBoxSafe<dynamic>('setting');
  }

  static Future<void> _prepareHivePath() async {
    _hivePath = '${(await getApplicationSupportDirectory()).path}/hive';
  }

  static Future<Box<T>> _openBoxSafe<T>(String boxName) async {
    try {
      return await Hive.openBox<T>(boxName);
    } catch (error) {
      PlatformLogger().e(
        'PlatformStorage: Box "$boxName" corrupted, attempting recovery',
        error: error,
      );
      await _deleteBoxFiles(boxName);

      try {
        final box = await Hive.openBox<T>(boxName);
        PlatformLogger().i(
          'PlatformStorage: Box "$boxName" recovered successfully (data lost)',
        );
        return box;
      } catch (recoveryError) {
        PlatformLogger().e(
          'PlatformStorage: Failed to recover box "$boxName"',
          error: recoveryError,
        );
        rethrow;
      }
    }
  }

  static Future<void> _deleteBoxFiles(String boxName) async {
    if (_hivePath == null) return;

    final boxFile = File('$_hivePath/$boxName.hive');
    final lockFile = File('$_hivePath/$boxName.lock');

    try {
      if (await boxFile.exists()) {
        await boxFile.delete();
        PlatformLogger().i(
          'PlatformStorage: Deleted corrupted box file: $boxName.hive',
        );
      }
      if (await lockFile.exists()) {
        await lockFile.delete();
        PlatformLogger().i('PlatformStorage: Deleted lock file: $boxName.lock');
      }
    } catch (error) {
      PlatformLogger().e(
        'PlatformStorage: Failed to delete box files for "$boxName"',
        error: error,
      );
    }
  }
}

class PlatformSettingKey {
  static const String themeMode = 'themeMode',
      themeColor = 'themeColor',
      oledEnhance = 'oledEnhance',
      displayMode = 'displayMode',
      defaultStartupPage = 'defaultStartupPage',
      platformCompletedLearningResources = 'platformCompletedLearningResources',
      platformRagDocuments = 'platformRagDocuments',
      platformRelaxSessions = 'platformRelaxSessions',
      showWindowButton = 'showWindowButton',
      useDynamicColor = 'useDynamicColor',
      exitBehavior = 'exitBehavior',
      useSystemFont = 'useSystemFont';
}
