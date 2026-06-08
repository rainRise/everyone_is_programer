import 'dart:io';

import 'package:flutter/material.dart';

enum CodeAuditSeverity {
  high,
  medium,
  low,
}

extension CodeAuditSeverityLabel on CodeAuditSeverity {
  String get label {
    return switch (this) {
      CodeAuditSeverity.high => '高危',
      CodeAuditSeverity.medium => '中危',
      CodeAuditSeverity.low => '低危',
    };
  }

  Color color(ColorScheme colorScheme) {
    return switch (this) {
      CodeAuditSeverity.high => colorScheme.error,
      CodeAuditSeverity.medium => colorScheme.tertiary,
      CodeAuditSeverity.low => colorScheme.secondary,
    };
  }
}

class CodeAuditRule {
  const CodeAuditRule({
    required this.id,
    required this.title,
    required this.severity,
    required this.pattern,
    required this.description,
    required this.suggestion,
  });

  final String id;
  final String title;
  final CodeAuditSeverity severity;
  final RegExp pattern;
  final String description;
  final String suggestion;
}

class CodeAuditFinding {
  const CodeAuditFinding({
    required this.rule,
    required this.filePath,
    required this.lineNumber,
    required this.lineText,
  });

  final CodeAuditRule rule;
  final String filePath;
  final int lineNumber;
  final String lineText;
}

class CodeAuditProjectReport {
  const CodeAuditProjectReport({
    required this.rootPath,
    required this.scannedFileCount,
    required this.skippedFileCount,
    required this.findings,
  });

  final String rootPath;
  final int scannedFileCount;
  final int skippedFileCount;
  final List<CodeAuditFinding> findings;
}

final localCodeAuditRules = [
  CodeAuditRule(
    id: 'hardcoded-secret',
    title: '疑似硬编码密钥',
    severity: CodeAuditSeverity.high,
    pattern: RegExp(
      r'''(api[_-]?key|token|password|secret)\s*[:=]\s*["'][^"']{6,}["']''',
      caseSensitive: false,
    ),
    description: '代码中出现疑似密钥、Token 或密码，存在泄露风险。',
    suggestion: '改用环境变量、系统凭据管理或安全配置中心，并立即轮换已暴露凭据。',
  ),
  CodeAuditRule(
    id: 'private-key-material',
    title: '私钥材料暴露',
    severity: CodeAuditSeverity.high,
    pattern: RegExp(
      r'-----BEGIN [A-Z ]*PRIVATE KEY-----',
      caseSensitive: false,
    ),
    description: '代码中出现 PEM/OpenSSH 私钥块头，可能直接暴露可用于签名、登录或解密的敏感材料。',
    suggestion: '立即移除私钥内容，改用安全密钥库或运行时注入，并轮换对应证书、SSH key 或服务凭据。',
  ),
  CodeAuditRule(
    id: 'dynamic-eval',
    title: '动态 eval 调用',
    severity: CodeAuditSeverity.high,
    pattern: RegExp(r'\beval\s*\(', caseSensitive: false),
    description: '动态执行字符串代码会扩大注入攻击面。',
    suggestion: '删除 eval，改用明确的解析器、白名单映射或结构化表达式求值。',
  ),
  CodeAuditRule(
    id: 'sql-string-interpolation',
    title: 'SQL 字符串拼接',
    severity: CodeAuditSeverity.high,
    pattern: RegExp(
      r'''\b(select|insert|update|delete)\b.*(\$[A-Za-z_]\w*|\+)''',
      caseSensitive: false,
    ),
    description: 'SQL 语句中出现字符串插值或拼接，可能让外部输入直接进入查询并造成注入风险。',
    suggestion: '改用参数化查询、预编译语句或 ORM 参数绑定，并避免把用户输入直接拼进 SQL 字符串。',
  ),
  CodeAuditRule(
    id: 'command-string-interpolation',
    title: '命令字符串拼接',
    severity: CodeAuditSeverity.high,
    pattern: RegExp(
      r'''\b(Process\.(run|start)|exec|spawn)\s*\([^;\n]*(\$[A-Za-z_]\w*|\+)''',
      caseSensitive: false,
    ),
    description: '命令执行调用中出现字符串插值或拼接，可能让外部输入进入 shell 或子进程参数并造成命令注入。',
    suggestion: '避免通过 shell 拼接命令，改用固定可执行文件、参数数组、白名单参数映射，并对用户输入做严格校验。',
  ),
  CodeAuditRule(
    id: 'plain-http',
    title: '明文 HTTP 地址',
    severity: CodeAuditSeverity.medium,
    pattern: RegExp(r'http://', caseSensitive: false),
    description: '明文 HTTP 可能导致请求被窃听或篡改。',
    suggestion: '优先改为 HTTPS，并检查证书校验和重定向策略。',
  ),
  CodeAuditRule(
    id: 'wildcard-cors',
    title: '过宽 CORS 配置',
    severity: CodeAuditSeverity.medium,
    pattern: RegExp(
      r'''(Access-Control-Allow-Origin[^;\n]*["']\*["']|origin\s*:\s*["']\*["'])''',
      caseSensitive: false,
    ),
    description: '代码允许任意来源跨域访问，可能扩大浏览器侧数据暴露或跨站请求风险。',
    suggestion: '改为明确的可信来源白名单，并按接口敏感度限制方法、请求头和凭据策略。',
  ),
  CodeAuditRule(
    id: 'cookie-secure-disabled',
    title: 'Cookie Secure 被关闭',
    severity: CodeAuditSeverity.medium,
    pattern: RegExp(
      r'''((cookie|session|CookieOptions|Set-Cookie)[^;\n]*(secure\s*[:=]\s*false|\.secure\s*=\s*false)|(secure\s*[:=]\s*false|\.secure\s*=\s*false)[^;\n]*(cookie|session))''',
      caseSensitive: false,
    ),
    description: 'Cookie 或会话配置关闭了 Secure 标记，可能让凭据在非 HTTPS 连接中泄露。',
    suggestion:
        '生产环境应启用 Secure Cookie，并配合 HttpOnly、SameSite 和 HTTPS-only 部署策略。',
  ),
  CodeAuditRule(
    id: 'csrf-disabled',
    title: 'CSRF 防护被关闭',
    severity: CodeAuditSeverity.medium,
    pattern: RegExp(
      r'''\b(csrf|csrfProtection|xsrf|antiForgery)\b\s*[:=]\s*false''',
      caseSensitive: false,
    ),
    description: '代码显式关闭了 CSRF/XSRF 防护，可能让基于 Cookie 的表单或状态变更接口暴露在跨站请求风险中。',
    suggestion: '生产环境应启用 CSRF token、SameSite Cookie、来源校验或框架内置的防护中间件。',
  ),
  CodeAuditRule(
    id: 'jwt-none-algorithm',
    title: 'JWT none 算法启用',
    severity: CodeAuditSeverity.high,
    pattern: RegExp(
      r'''((jwt|jsonwebtoken)[^;\n]*["']?(alg|algorithm)["']?\s*[:=]\s*["']none["']|["']?(alg|algorithm)["']?\s*[:=]\s*["']none["'][^;\n]*(jwt|jsonwebtoken))''',
      caseSensitive: false,
    ),
    description: 'JWT 配置使用 none 算法会绕过签名校验，可能让伪造 token 被服务端接受。',
    suggestion: '禁用 none 算法，只允许固定的强签名算法，并在验签时校验 issuer、audience、过期时间和密钥来源。',
  ),
  CodeAuditRule(
    id: 'tls-verification-disabled',
    title: 'TLS 校验被关闭',
    severity: CodeAuditSeverity.high,
    pattern: RegExp(
      r'''(badCertificateCallback\s*=\s*[^;]*=>\s*true|rejectUnauthorized\s*:\s*false|verify\s*=\s*false|NODE_TLS_REJECT_UNAUTHORIZED\s*=\s*["']?0)''',
      caseSensitive: false,
    ),
    description: '代码关闭了 TLS/证书校验，可能允许中间人攻击或伪造服务端证书。',
    suggestion: '恢复默认 TLS 校验，使用可信 CA 或证书固定策略，调试例外应通过环境隔离而不是提交到代码中。',
  ),
  CodeAuditRule(
    id: 'weak-hash',
    title: '弱哈希算法',
    severity: CodeAuditSeverity.medium,
    pattern: RegExp(r'\b(md5|sha1)\s*(\(|\.)', caseSensitive: false),
    description: '代码调用 MD5 或 SHA1 等弱哈希算法，在密码、签名或完整性校验场景中容易产生碰撞风险。',
    suggestion: '优先改用 SHA-256/ SHA-512、HMAC 或专用密码哈希方案，并确认调用场景是否需要抗碰撞或抗篡改能力。',
  ),
  CodeAuditRule(
    id: 'weak-randomness',
    title: '非加密随机数',
    severity: CodeAuditSeverity.medium,
    pattern: RegExp(
      r'\b(Math\.random|Random\s*\(|random\.random\s*\()',
      caseSensitive: false,
    ),
    description: '代码使用非加密随机数生成器，若用于 token、验证码、密钥或会话标识会产生可预测风险。',
    suggestion: '安全敏感场景应改用系统安全随机源或加密库提供的 CSPRNG，并区分测试随机数与生产凭据生成。',
  ),
  CodeAuditRule(
    id: 'debug-mode-enabled',
    title: '调试模式开启',
    severity: CodeAuditSeverity.medium,
    pattern: RegExp(
      r'''(["']?\b(debug|debugMode|isDebug|enableDebug)\b["']?\s*[:=]\s*true|\.debug\s*=\s*true)''',
      caseSensitive: false,
    ),
    description: '配置中开启调试模式可能暴露错误栈、内部路径、接口细节或额外日志。',
    suggestion: '生产环境应关闭调试模式，并通过环境隔离、日志分级和错误脱敏保留必要的诊断能力。',
  ),
  CodeAuditRule(
    id: 'debug-print',
    title: '调试输出残留',
    severity: CodeAuditSeverity.low,
    pattern: RegExp(r'\b(print|console\.log)\s*\(', caseSensitive: false),
    description: '调试输出可能泄露运行状态、用户数据或内部实现细节。',
    suggestion: '生产环境改用可分级、可脱敏的日志系统，并移除无用输出。',
  ),
];

List<CodeAuditFinding> scanCodeSnippet(
  String source, {
  String filePath = 'snippet.txt',
  Iterable<String>? enabledRuleIds,
}) {
  final findings = <CodeAuditFinding>[];
  final lines = source.split(RegExp(r'\r?\n'));
  final rules = _enabledRules(enabledRuleIds);

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    for (final rule in rules) {
      if (rule.pattern.hasMatch(line)) {
        findings.add(
          CodeAuditFinding(
            rule: rule,
            filePath: filePath,
            lineNumber: i + 1,
            lineText: line.trim(),
          ),
        );
      }
    }
  }

  findings.sort((a, b) {
    final severityCompare = a.rule.severity.index.compareTo(
      b.rule.severity.index,
    );
    if (severityCompare != 0) return severityCompare;
    return a.lineNumber.compareTo(b.lineNumber);
  });

  return findings;
}

Future<CodeAuditProjectReport> scanCodeProject(
  String rootPath, {
  int maxFiles = 120,
  Iterable<String>? enabledRuleIds,
}) async {
  final root = Directory(rootPath.trim());
  if (!await root.exists()) {
    throw FileSystemException('项目路径不存在', rootPath);
  }

  final findings = <CodeAuditFinding>[];
  var scannedFileCount = 0;
  var skippedFileCount = 0;

  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!_isAuditableSourceFile(entity.path)) continue;
    if (_isIgnoredPath(entity.path)) {
      skippedFileCount++;
      continue;
    }
    if (scannedFileCount >= maxFiles) {
      skippedFileCount++;
      continue;
    }

    try {
      final source = await entity.readAsString();
      findings.addAll(
        scanCodeSnippet(
          source,
          filePath: _relativePath(root.path, entity.path),
          enabledRuleIds: enabledRuleIds,
        ),
      );
      scannedFileCount++;
    } on FileSystemException {
      skippedFileCount++;
    } on FormatException {
      skippedFileCount++;
    }
  }

  findings.sort((a, b) {
    final severityCompare = a.rule.severity.index.compareTo(
      b.rule.severity.index,
    );
    if (severityCompare != 0) return severityCompare;
    final fileCompare = a.filePath.compareTo(b.filePath);
    if (fileCompare != 0) return fileCompare;
    return a.lineNumber.compareTo(b.lineNumber);
  });

  return CodeAuditProjectReport(
    rootPath: root.path,
    scannedFileCount: scannedFileCount,
    skippedFileCount: skippedFileCount,
    findings: findings,
  );
}

List<CodeAuditRule> _enabledRules(Iterable<String>? enabledRuleIds) {
  if (enabledRuleIds == null) return localCodeAuditRules;

  final enabled = enabledRuleIds.toSet();
  return localCodeAuditRules
      .where((rule) => enabled.contains(rule.id))
      .toList(growable: false);
}

String formatCodeAuditReport(List<CodeAuditFinding> findings) {
  final buffer = StringBuffer()
    ..writeln('# 本地代码审计报告')
    ..writeln()
    ..writeln('- 风险总数：${findings.length}')
    ..writeln('- 高危：${_countSeverity(findings, CodeAuditSeverity.high)}')
    ..writeln('- 中危：${_countSeverity(findings, CodeAuditSeverity.medium)}')
    ..writeln('- 低危：${_countSeverity(findings, CodeAuditSeverity.low)}')
    ..writeln();

  if (findings.isEmpty) {
    buffer.writeln('未命中本地规则。');
    return buffer.toString();
  }

  for (var i = 0; i < findings.length; i++) {
    final finding = findings[i];
    buffer
      ..writeln('## ${i + 1}. ${finding.rule.title}')
      ..writeln()
      ..writeln('- 严重级别：${finding.rule.severity.label}')
      ..writeln('- 位置：`${finding.filePath}:${finding.lineNumber}`')
      ..writeln('- 说明：${finding.rule.description}')
      ..writeln('- 建议：${finding.rule.suggestion}')
      ..writeln()
      ..writeln('```text')
      ..writeln(finding.lineText)
      ..writeln('```')
      ..writeln();
  }

  return buffer.toString();
}

String formatCodeAuditProjectReport(
  CodeAuditProjectReport report, {
  Iterable<CodeAuditRule>? enabledRules,
}) {
  final rules = (enabledRules ?? localCodeAuditRules).toList(growable: false);
  final buffer = StringBuffer()
    ..writeln('# 项目代码审计报告')
    ..writeln()
    ..writeln('## 扫描摘要')
    ..writeln()
    ..writeln('- 项目路径：`${report.rootPath}`')
    ..writeln('- 已扫描文件：${report.scannedFileCount}')
    ..writeln('- 已跳过文件：${report.skippedFileCount}')
    ..writeln('- 风险总数：${report.findings.length}')
    ..writeln('- 高危：${_countSeverity(report.findings, CodeAuditSeverity.high)}')
    ..writeln(
        '- 中危：${_countSeverity(report.findings, CodeAuditSeverity.medium)}')
    ..writeln('- 低危：${_countSeverity(report.findings, CodeAuditSeverity.low)}')
    ..writeln()
    ..writeln('## 启用规则')
    ..writeln();

  if (rules.isEmpty) {
    buffer.writeln('- 未启用本地规则');
  } else {
    for (final rule in rules) {
      buffer.writeln('- ${rule.title}（${rule.severity.label}，`${rule.id}`）');
    }
  }

  buffer
    ..writeln()
    ..writeln('## 风险发现')
    ..writeln();

  if (report.findings.isEmpty) {
    buffer.writeln('未命中本地规则。');
    return buffer.toString();
  }

  for (var i = 0; i < report.findings.length; i++) {
    final finding = report.findings[i];
    buffer
      ..writeln('### ${i + 1}. ${finding.rule.title}')
      ..writeln()
      ..writeln('- 严重级别：${finding.rule.severity.label}')
      ..writeln('- 位置：`${finding.filePath}:${finding.lineNumber}`')
      ..writeln('- 说明：${finding.rule.description}')
      ..writeln('- 建议：${finding.rule.suggestion}')
      ..writeln()
      ..writeln('```text')
      ..writeln(finding.lineText)
      ..writeln('```')
      ..writeln();
  }

  return buffer.toString();
}

int _countSeverity(
  List<CodeAuditFinding> findings,
  CodeAuditSeverity severity,
) {
  return findings.where((finding) => finding.rule.severity == severity).length;
}

bool _isAuditableSourceFile(String path) {
  final normalized = path.toLowerCase();
  const extensions = [
    '.dart',
    '.js',
    '.ts',
    '.tsx',
    '.jsx',
    '.py',
    '.java',
    '.kt',
    '.go',
    '.rs',
    '.cs',
    '.cpp',
    '.c',
    '.h',
    '.php',
    '.rb',
    '.swift',
    '.yaml',
    '.yml',
    '.json',
    '.env',
  ];
  return extensions.any(normalized.endsWith);
}

bool _isIgnoredPath(String path) {
  final normalized = path.replaceAll('\\', '/').toLowerCase();
  const ignoredSegments = [
    '/.git/',
    '/.dart_tool/',
    '/build/',
    '/node_modules/',
    '/.gradle/',
    '/.idea/',
    '/.vscode/',
  ];
  return ignoredSegments.any(normalized.contains);
}

String _relativePath(String rootPath, String filePath) {
  final normalizedRoot = rootPath.replaceAll('\\', '/');
  final normalizedFile = filePath.replaceAll('\\', '/');
  if (normalizedFile.startsWith('$normalizedRoot/')) {
    return normalizedFile.substring(normalizedRoot.length + 1);
  }
  return filePath;
}
