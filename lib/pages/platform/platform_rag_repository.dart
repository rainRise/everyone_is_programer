import 'package:kazumi/pages/platform/platform_rag_catalog.dart';
import 'package:kazumi/utils/platform_storage.dart';

abstract class PlatformRagStorage {
  Object? get(String key, {Object? defaultValue});

  Future<void> put(String key, Object? value);
}

class HivePlatformRagStorage implements PlatformRagStorage {
  const HivePlatformRagStorage();

  @override
  Object? get(String key, {Object? defaultValue}) {
    return PlatformStorage.setting.get(key, defaultValue: defaultValue);
  }

  @override
  Future<void> put(String key, Object? value) async {
    await PlatformStorage.setting.put(key, value);
  }
}

class PlatformRagRepository {
  const PlatformRagRepository({
    this.storage = const HivePlatformRagStorage(),
  });

  final PlatformRagStorage storage;

  Future<List<LocalRagDocument>> loadDocuments() async {
    try {
      final raw = storage.get(
        PlatformSettingKey.platformRagDocuments,
        defaultValue: const [],
      );
      if (raw is! List) return const [];

      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(LocalRagDocument.fromJson)
          .where((document) => document.title.isNotEmpty)
          .where((document) => document.content.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveDocuments(List<LocalRagDocument> documents) async {
    try {
      final normalizedDocuments = documents
          .map((document) => document.normalized())
          .where((document) => document.title.isNotEmpty)
          .where((document) => document.content.isNotEmpty)
          .toList();
      await storage.put(
        PlatformSettingKey.platformRagDocuments,
        normalizedDocuments.map((document) => document.toJson()).toList(),
      );
    } catch (_) {}
  }
}
