import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/platform/platform_rag_catalog.dart';
import 'package:kazumi/pages/platform/platform_rag_repository.dart';
import 'package:kazumi/utils/platform_storage.dart';

void main() {
  test('RAG document serializes and deserializes', () {
    const document = LocalRagDocument(
      title: '持久化测试',
      source: '用户导入',
      summary: '验证 JSON 转换。',
      content: '本地 RAG 资料需要保存到 Hive setting box。',
      tags: ['RAG', 'Hive'],
    );

    final restored = LocalRagDocument.fromJson(document.toJson());

    expect(restored.title, document.title);
    expect(restored.source, document.source);
    expect(restored.summary, document.summary);
    expect(restored.content, document.content);
    expect(restored.tags, document.tags);
  });

  test('RAG document normalizes persisted fields', () {
    final restored = LocalRagDocument.fromJson({
      'title': '  Flutter import note  ',
      'source': '   ',
      'summary': '  trims summary  ',
      'content': '  trims content  ',
      'tags': [' Flutter ', '', 'RAG', 'Flutter', ' RAG '],
    });

    expect(restored.title, 'Flutter import note');
    expect(restored.source, '用户导入');
    expect(restored.summary, 'trims summary');
    expect(restored.content, 'trims content');
    expect(restored.tags, ['Flutter', 'RAG']);
    expect(restored.toJson()['tags'], ['Flutter', 'RAG']);
  });

  test('RAG repository saves and loads imported documents', () async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformRagRepository(storage: storage);
    const document = LocalRagDocument(
      title: 'Flutter Widget Test',
      source: '用户导入',
      summary: '测试 RAG 仓储读写。',
      content: 'Widget test 可以验证导入入口和资料检索结果。',
      tags: ['Flutter', '测试'],
    );

    await repository.saveDocuments([document]);
    final loaded = await repository.loadDocuments();

    expect(
      storage.values.containsKey(PlatformSettingKey.platformRagDocuments),
      isTrue,
    );
    expect(loaded.length, 1);
    expect(loaded.first.title, document.title);
    expect(loaded.first.tags, document.tags);
  });

  test('RAG repository normalizes and filters documents before saving',
      () async {
    final storage = _MemoryPlatformRagStorage();
    final repository = PlatformRagRepository(storage: storage);
    const messyDocument = LocalRagDocument(
      title: '  Local import  ',
      source: '',
      summary: '  Summary  ',
      content: '  Searchable content  ',
      tags: [' RAG ', 'RAG', ''],
    );
    const emptyDocument = LocalRagDocument(
      title: '  ',
      source: 'User import',
      summary: '',
      content: '  ',
      tags: ['RAG'],
    );

    await repository.saveDocuments([messyDocument, emptyDocument]);
    final loaded = await repository.loadDocuments();

    expect(loaded.length, 1);
    expect(loaded.single.title, 'Local import');
    expect(loaded.single.source, '用户导入');
    expect(loaded.single.summary, 'Summary');
    expect(loaded.single.content, 'Searchable content');
    expect(loaded.single.tags, ['RAG']);
  });
}

class _MemoryPlatformRagStorage implements PlatformRagStorage {
  final Map<String, Object?> values = {};

  @override
  Object? get(String key, {Object? defaultValue}) {
    return values[key] ?? defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    values[key] = value;
  }
}
