# Programmer Learning Platform Dev Log

## 2026-05-28

### Step 0: Scope Approval

**User Goal:** Convert `Kazumi` into a programmer learning platform with three zones: learning resources, coding, and relaxation.

**Approved Scope:** First-stage MVP only. Build a runnable shell with three primary zones and traceable logs before deeper RAG/code-audit work.

**Constraints:**
- Split work because the full task touches more than 3 files.
- Use test-first changes for new behavior.
- Record operations, file changes, verification commands, and outcomes.

### Step 1: Plan And RED Test

**Operation:** Create plan, dev log, and an initial widget test that references the new zone pages before they exist.

**Expected Result:** `flutter test test/platform_zones_test.dart` fails because the pages have not been implemented yet.

**Verification Attempt 1:** Ran `flutter test test/platform_zones_test.dart` through the local Flutter SDK path.

**Result:** Timed out after 60 seconds while resolving dependencies. This did not reach the expected RED compile failure, so it is treated as an environment/dependency-resolution delay rather than a valid test result.

**Verification Attempt 2:** Re-ran `flutter test test/platform_zones_test.dart` with a longer timeout.

**Result:** Expected RED confirmed. The test failed because `learning_zone_page.dart`, `coding_zone_page.dart`, and `relax_zone_page.dart` did not exist yet.

### Step 2: Zone Pages

**Operation:** Added `LearningZonePage`, `CodingZonePage`, and `RelaxZonePage` with Material 3 layouts and MVP resource/action entries.

**Files Added:**
- `lib/pages/platform/learning_zone_page.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `lib/pages/platform/relax_zone_page.dart`

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed. All three zone pages render their expected titles and resource/action labels.

### Step 3: Navigation RED Test

**Operation:** Added a route configuration test that expects exactly three primary zones: learning, coding, and relax.

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Expected RED confirmed. The test failed because the existing Kazumi menu still exposes four routes.

### Step 4: Zone Modules And Navigation

**Operation:** Added three Flutter Modular modules and replaced the root menu route list with learning, coding, and relax zones.

**Files Added:**
- `lib/pages/platform/learning_zone_module.dart`
- `lib/pages/platform/coding_zone_module.dart`
- `lib/pages/platform/relax_zone_module.dart`

**Files Modified:**
- `lib/pages/router.dart`
- `lib/pages/menu/menu.dart`

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed. The route configuration now exposes exactly three zones, and all zone page tests pass.

### Step 5: Startup Path RED Test

**Operation:** Added a test requiring `defaultPlatformStartupPath` to point to `/tab/learning/`.

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Expected RED confirmed. The test failed because `defaultPlatformStartupPath` did not exist yet.

### Step 6: Default Startup Path

**Operation:** Added `defaultPlatformStartupPath` in `router.dart` and reused it from `menu.dart` and `init_page.dart`.

**Files Modified:**
- `lib/pages/router.dart`
- `lib/pages/menu/menu.dart`
- `lib/pages/init_page.dart`

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed. The platform now defaults to `/tab/learning/` and all zone tests pass.

### Step 7: Formatting

**Operation:** Ran Dart formatter on modified Dart files.

**Result:** `menu.dart` was reformatted. Other modified Dart files were already formatted.

### Step 8: Regression And Static Checks

**Operation:** Ran the full Flutter test suite.

**Result:** Passed. All existing tests and the new platform zone tests passed.

**Operation:** Ran `flutter analyze`.

**Result:** Analyzer reported info-level issues in existing Kazumi code. No errors were reported, and no issues were reported for the newly added platform pages/modules. One route typing issue in the modified `router.dart` was fixed by adding an explicit `String` return type to `getPath`.

**Operation:** Re-ran the full Flutter test suite after the route typing fix.

**Result:** Passed. All tests passed again.

**Operation:** Ran `flutter build windows`.

**Result:** Succeeded. Windows release binary was built at `build\windows\x64\runner\Release\kazumi.exe`. Build output included a non-fatal `Nuget is not installed` message and a CMake plugin warning from `webview_windows`.

### Step 9: Review Fixes

**Operation:** Reviewed route/settings consistency feedback.

**Result:** Confirmed two high-risk issues: persisted old startup routes could navigate to removed tabs, and interface settings still offered old Kazumi startup routes.

**Operation:** Added RED tests for legacy startup path normalization and platform startup page choices.

**Result:** Expected RED confirmed because the normalization API and platform page labels did not exist yet.

**Operation:** Added `normalizePlatformStartupPath` and `defaultPlatformPageLabels`, then connected menu state, startup navigation, and interface settings to these shared route definitions.

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed. Legacy Kazumi startup paths now normalize to `/tab/learning/`, and settings choices match the three platform zones.

**Operation:** Added an additional RED test for non-string persisted startup values.

**Result:** Expected RED confirmed because `normalizePlatformStartupPath` only accepted `String?`.

**Operation:** Updated `normalizePlatformStartupPath` to validate `Object?` values and removed forced casts from startup/settings reads.

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed. Invalid persisted startup values now normalize to `/tab/learning/` without throwing.

### Step 10: Final Verification After Review Fixes

**Operation:** Ran Dart formatter on final modified Dart files.

**Result:** Formatter reported no file changes.

### Step 11: Learning Catalog Data

**Operation:** Added a RED test for the five resource groups in the learning catalog.

**Result:** Expected RED confirmed because `platform_learning_catalog.dart` did not exist yet.

**Operation:** Added `platform_learning_catalog.dart` and refactored `LearningZonePage` to render from `platformLearningSections`.

**Verification:** Ran `flutter test test/platform_learning_catalog_test.dart`.

**Result:** Passed. The learning catalog now exposes the five core resource groups as data.

**Operation:** Ran Dart formatter on learning catalog files.

**Result:** Formatter reported no file changes.

**Operation:** Ran the full Flutter test suite.

**Result:** Passed. All tests passed with the new learning catalog test included.

**Operation:** Ran `flutter analyze`.

**Result:** Analyzer still reports existing info-level legacy Kazumi issues. No errors were reported and no new platform catalog files were listed.

**Operation:** Ran `flutter build windows`.

**Result:** Succeeded. Windows release binary was rebuilt at `build\windows\x64\runner\Release\kazumi.exe`. The same non-fatal NuGet/CMake plugin warnings remained.

### Step 12: Local RAG Resource Preview

**Operation:** Added a RED test requiring `LearningZonePage` to render a `RAG 资料包` section with three local source types.

**Result:** Expected RED confirmed because the learning zone did not render the RAG preview yet.

**Operation:** Added `platform_rag_catalog.dart`, `rag_library_preview.dart`, and mounted `RagLibraryPreview` in `LearningZonePage`.

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed. The learning zone now renders Markdown, PDF/document, and code snippet RAG source entries.

**Operation:** Ran Dart formatter, full Flutter test suite, `flutter analyze`, and `flutter build windows`.

**Result:** Full tests passed. Analyzer still reports existing legacy info-level issues only. Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe` with the same non-fatal NuGet/CMake warnings.

### Step 13: Code Audit Workflow Preview

**Operation:** Added a RED test requiring `CodingZonePage` to render a `代码审计流程` section with four audit workflow steps.

**Result:** Expected RED confirmed because the coding zone did not render the workflow preview yet.

**Operation:** Added `platform_code_audit_catalog.dart`, `code_audit_preview.dart`, and mounted `CodeAuditPreview` in `CodingZonePage`.

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed. The coding zone now renders project import, rule scan, AI audit, and report generation steps.

**Operation:** Ran Dart formatter, full Flutter test suite, `flutter analyze`, and `flutter build windows`.

**Result:** Full tests passed. Analyzer still reports existing legacy info-level issues only. Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe` with the same non-fatal NuGet/CMake warnings.

### Step 14: Relax Toolkit Preview

**Operation:** Added a RED test requiring `RelaxZonePage` to render a `放松工具箱` section with three recovery rhythms.

**Result:** Expected RED confirmed because the relax zone did not render the toolkit preview yet.

**Operation:** Added `platform_relax_toolkit.dart`, `relax_toolkit_preview.dart`, and mounted `RelaxToolkitPreview` in `RelaxZonePage`.

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed. The relax zone now renders focus, short break, and long break entries.

**Operation:** Ran Dart formatter, full Flutter test suite, `flutter analyze`, and `flutter build windows`.

**Result:** Full tests passed. Analyzer still reports existing legacy info-level issues only. Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe` with the same non-fatal NuGet/CMake warnings.

### Step 15: Learning Resource Catalog Details

**Operation:** Added a RED test requiring each learning catalog section to expose concrete resource entries.

**Result:** Expected RED confirmed because `PlatformLearningSection` did not expose a `resources` field yet.

**Operation:** Added `PlatformLearningResource`, added `resources` to each learning section, and seeded video, Skill, MCP, local RAG, and algorithm/model entries.

**Verification:** Ran `flutter test test/platform_learning_catalog_test.dart`.

**Result:** Passed. Learning catalog sections now have concrete resource entries in the data model.

**Operation:** Ran Dart formatter, full Flutter test suite, `flutter analyze`, and `flutter build windows`.

**Result:** Full tests passed. Analyzer still reports existing legacy info-level issues only. Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe` with the same non-fatal NuGet/CMake warnings.

### Step 16: Render Learning Resource Entries

**Operation:** Added a RED widget test requiring `LearningZonePage` to render concrete learning resources such as `CS50`, `Context7`, and `BM25`.

**Result:** Expected RED confirmed because the learning zone rendered section cards only, not the nested resources.

**Operation:** Updated `LearningZonePage` to render each section's `resources` under the section description.

**Verification:** Ran `flutter test test/platform_zones_test.dart`.

**Result:** Passed after rendering each resource title as standalone text.

**Operation:** Ran Dart formatter, full Flutter test suite, `flutter analyze`, and `flutter build windows`.

**Result:** Full tests passed. Analyzer still reports existing legacy info-level issues only. Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe` with the same non-fatal NuGet/CMake warnings.

## 2026-05-29

### Step 17: Resource Metadata And Filtering

**Operation:** Expanded `PlatformLearningResource` from a title/description item into a platform resource model with type, level, action label, URL, and tags.

**Why:** The platform needs to manage videos, Skills, MCP tools, local RAG sources, and recommendation/model learning materials as structured data instead of hard-coded text. This makes filtering, search, recommendation, and later persistence easier.

**Feature Goal:** Turn the learning area into a resource catalog that can answer: "What kind of resource is this?", "Where is the entry point?", and "Which learning tags does it cover?"

**Files Modified:**
- `lib/pages/platform/platform_learning_catalog.dart`
- `test/platform_learning_catalog_test.dart`

### Step 18: Learning Workbench UI

**Operation:** Reworked `LearningZonePage` into a stateful learning workbench with a suggested learning path, keyword search, resource type filters, resource cards, and action sheets.

**Why:** The previous page only proved that three zones existed. A learning platform needs users to quickly locate resources, distinguish videos from RAG/MCP/Skill/model entries, and see the next learning action.

**Feature Goal:** Provide a practical first screen for the data learning zone: learn from videos, organize local RAG materials, and connect algorithm/model study to recommendation-system concepts.

**Files Modified:**
- `lib/pages/platform/learning_zone_page.dart`
- `test/platform_zones_test.dart`

## 2026-06-02

### Step 35: Continue From Existing Platform State

**Operation:** Inspected the current project structure, Git status, platform pages, router, menu, and existing platform tests.

**Thinking Log:** The user goal is broad, so the first move was not to add new files immediately. I checked whether the three-zone platform already existed and found that learning, coding, relax, local RAG, recommendation, progress, and session persistence were already partially implemented. This changed the next step from "build the shell" to "find the least complete user-facing workflow."

**Observation:** The learning zone already had video resources, Skill/MCP entries, local RAG retrieval, and recommendation ranking. The relax zone already had a timer and persisted session history. The coding zone still had placeholder language around project import and AI audit, while its only executable scanner worked on a pasted snippet.

**Decision:** Improve the coding zone first because it was the largest gap between the platform goal and the actual user workflow. A programmer learning platform should be able to inspect a local project, not only scan a demo snippet.

### Step 36: Add Local Project Audit Data Model

**Operation:** Added `CodeAuditProjectReport` and `scanCodeProject` to the local audit rules module.

**Thinking Log:** I reused the existing deterministic rule scanner instead of introducing a new analyzer dependency. That keeps the feature small, offline, and testable. The scanner walks a local directory, skips noisy folders such as `.git`, `.dart_tool`, `build`, and `node_modules`, reads common source/config extensions, and records relative file paths so reports are easier to read.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`

**Design Notes:**
- `maxFiles` defaults to 120 to avoid accidental huge scans in an MVP UI.
- Binary or non-UTF files are counted as skipped through `FormatException`.
- Findings are sorted by severity, file path, and line number so the UI shows higher-priority items first.

### Step 37: Make Coding Zone Project Scanning Usable

**Operation:** Added a `本地项目审计` panel to `CodingZonePage`.

**Thinking Log:** The project did not have a file picker dependency, so I avoided adding one. A path text field is less polished than a picker, but it works immediately on desktop, avoids dependency churn, and matches the current MVP style. The panel reports scanned files, skipped files, risk count, top findings, error state, loading state, and report saving.

**Files Modified:**
- `lib/pages/platform/coding_zone_page.dart`

**UI Behavior:**
- User enters a local project path.
- `扫描项目` runs deterministic multi-file scanning.
- `保存项目报告` reuses the existing Markdown report repository.
- The original pasted-snippet scanner remains available for quick experiments.

### Step 38: Cover Project Directory Scanning With Tests

**Operation:** Added a test that creates a temporary project directory with one source file and one ignored build file.

**Thinking Log:** The test checks the riskiest behavior in this feature: recursive scanning should include real source files, skip generated/build output, preserve relative paths, and produce findings from multiple rules. This gives confidence without needing a full fixture project.

**Files Modified:**
- `test/platform_code_audit_rules_test.dart`

**Verification Command:**
```text
D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_code_audit_rules_test.dart
```

**Result:** Passed. The targeted code audit test file completed with 4 passing tests.

### Step 39: Tooling Notes And Verification Constraints

**Operation:** Checked formatter and Flutter test execution in the current sandbox.

**Thinking Log:** `dart` and `flutter` through the normal launcher scripts timed out, so I tested the SDK directly. Direct `dart.exe` worked. Flutter tests initially failed because the tool needed write access to the Flutter SDK `cache/lockfile`, which is outside the workspace sandbox. After requesting permission for the Flutter tool snapshot command, the targeted test passed.

**Formatter Notes:**
- Direct `dart.exe format --output=none --set-exit-if-changed` reported 0 changed files after manual cleanup.
- A normal overwrite-format attempt on `coding_zone_page.dart` hit a Windows access-denied replacement error, so formatting suggestions were applied manually with patches.

**Current Verification Status:**
- Passed: `test/platform_code_audit_rules_test.dart`
- Not rerun in this step: full `flutter test`, `dart analyze`, and Windows build, because normal Flutter launcher scripts were hanging in this environment and the immediate feature risk was covered by targeted tests.

### Step 40: Widget Test Catch And Icon Compatibility Fix

**Operation:** Added widget assertions for the new coding-zone project audit panel, then reran targeted platform tests.

**Thinking Log:** After adding a new UI feature, logic tests alone were not enough. The zone widget test should also prove the user can see the new entrypoint. This caught a real SDK compatibility problem: `Icons.folder_data_outlined` was not available in the current Flutter SDK.

**Fix:** Replaced the unavailable icon with `Icons.folder_open_outlined`, which is present in the SDK and communicates the same project-folder meaning.

**Files Modified:**
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_zones_test.dart`

**Verification Commands:**
```text
D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format --output=none --set-exit-if-changed lib/pages/platform/coding_zone_page.dart
D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_code_audit_rules_test.dart test/platform_zones_test.dart
```

**Result:** Formatting reported 0 changed files. Targeted platform tests passed: 11 tests total, including local audit rules and the three-zone widget tests.

### Step 41: Turn Local Learning Entries Into Guides

**Operation:** Added `PlatformLearningGuide` and attached built-in guides to all non-external learning resources.

**Thinking Log:** The learning zone already had videos, Skills, MCP tools, local RAG entries, and model entries, but many local resources still behaved like labels or `local://` references. The next useful improvement was to make those entries teach the user what to do next. I kept video resources as external links, and made every Skill/MCP/RAG/model entry include overview, steps, and expected outputs.

**Files Modified:**
- `lib/pages/platform/platform_learning_catalog.dart`

**Design Notes:**
- Guides live beside resource metadata so search, recommendation, and UI can share one source of truth.
- `toClipboardText` generates Markdown so users can paste a guide into notes, RAG material, or an AI prompt.
- The `本地 RAG 资料` section description was updated from a reserved/future wording to an active import-and-retrieval wording.

### Step 42: Show And Copy Built-In Guides

**Operation:** Updated the learning resource action sheet to render `内置指南` content and added a `复制指南` action.

**Thinking Log:** A bottom sheet is already the app's local resource action pattern, so expanding it was lower-risk than adding a new page. Wrapping the sheet in a scroll view keeps long guides usable on smaller screens.

**Files Modified:**
- `lib/pages/platform/learning_zone_page.dart`

**UI Behavior:**
- External video resources still show open/copy actions.
- Local resources show overview, numbered steps, output chips, entry URL, and copy-guide action.

### Step 43: Guide Coverage Tests And Verification

**Operation:** Added catalog tests proving all local resources have actionable built-in guides.

**Thinking Log:** The most important invariant is coverage: if a resource is local, it should not be an empty pointer. The test checks that all 12 local entries have guides and that the guide text includes title, steps, and outputs.

**Files Modified:**
- `test/platform_learning_catalog_test.dart`

**Verification Commands:**
```text
D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_learning_catalog_test.dart test/platform_zones_test.dart
```

**Result:** Passed. The targeted learning catalog and platform zone tests completed with 11 passing tests.

**Formatter Note:** `dart.exe format --output=none --set-exit-if-changed` repeatedly reported `learning_zone_page.dart` as changed even after formatting, while `--output=show` displayed the already-formatted code and tests passed. This appears to be a local formatter/write or newline quirk rather than a compile issue.

### Step 44: Goal Coverage Audit

**Operation:** Audited the current platform against the explicit user goal.

**Thinking Log:** Before treating the goal as complete, I mapped each user requirement to current evidence instead of relying on intent:

- Programmer learning platform: platform identity constants, README/metadata, and three-zone startup route exist.
- Three zones: menu routes expose `资料`, `编程`, and `放松`.
- Resource learning zone: learning page renders resource catalog, progress, recommendations, and local RAG preview.
- Video resources: catalog includes CS50, MIT 6.006, and FreeCodeCamp external course entries.
- Common Skill/MCP: catalog includes TDD, debugging, code review, Context7, Filesystem MCP, and GitHub MCP, now with built-in guides.
- Local RAG materials: RAG import, persistence, chunking, search, and answer draft are implemented and tested.
- RAG and recommendation algorithms/models: RAG retrieval, BM25/Embedding/model resources, and explainable recommendation ranking are implemented and tested.
- Coding zone: local snippet scan, local project scan, Markdown report save, audit checklist, and Prompt templates are implemented and tested.
- Relax zone: focus/rest timer surface and persisted session history are implemented and tested.

**Verification Commands:**
```text
D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_code_audit_repository_test.dart test/platform_code_audit_rules_test.dart test/platform_identity_test.dart test/platform_learning_catalog_test.dart test/platform_learning_progress_repository_test.dart test/platform_rag_catalog_test.dart test/platform_rag_repository_test.dart test/platform_recommendation_catalog_test.dart test/platform_relax_session_repository_test.dart test/platform_zones_test.dart
D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/pages/platform test/platform_code_audit_repository_test.dart test/platform_code_audit_rules_test.dart test/platform_identity_test.dart test/platform_learning_catalog_test.dart test/platform_learning_progress_repository_test.dart test/platform_rag_catalog_test.dart test/platform_rag_repository_test.dart test/platform_recommendation_catalog_test.dart test/platform_relax_session_repository_test.dart test/platform_zones_test.dart
```

**Result:** All 32 platform tests passed. Platform-scoped static analysis reported `No issues found`.

**Tooling Note:** Passing `test/platform_*_test.dart` directly to Flutter crashed because the Flutter tool treated the wildcard as an illegal literal path. Explicitly listing the 10 platform test files avoided the tool crash.

### Step 35: Manual QA Launch Record

**Operation:** Launched the Windows build artifact `build\windows\x64\runner\Release\kazumi.exe` for manual acceptance testing.

**Why:** Automated tests and builds had passed, but desktop navigation, persisted local state, clipboard actions, and link-opening behavior still need visual/manual confirmation in the running app.

**Feature Goal:** Move the MVP from code-only verification into user-facing acceptance checks.

**Result:** The executable was started successfully. Visual inspection requires checking the app window directly with the manual checklist in `docs/qa/2026-05-31-manual-acceptance-checklist.md`.

### Step 36: Local RAG Answer Draft

**Operation:** Added a deterministic local RAG answer draft on top of the existing keyword retrieval.

**Why:** The previous RAG feature could search and import documents, but it still behaved like a search result list. A learning platform should show how retrieved context becomes an answer, even before integrating Embedding or an LLM.

**Feature Goal:** Let the learning zone generate a traceable answer draft from the current query, show the number of cited documents, display matched fields, and expose evidence snippets from the retrieved notes.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_rag_catalog_test.dart`
- `test/platform_zones_test.dart`
- `README.md`
- `docs/qa/2026-05-31-manual-acceptance-checklist.md`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Verification:**
- `dart format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_rag_catalog_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Targeted tests passed, targeted analysis found no issues, and the full Flutter test suite passed with 56 tests. The first Windows build attempt failed because the previously launched `kazumi.exe` was still running and locked the Release executable; after confirming the process path and closing that process, `flutter build windows` succeeded. The existing non-fatal `Nuget is not installed` and `webview_windows` CMake warning remain.

### Step 37: Legacy Startup Isolation

**Operation:** Added a platform identity flag that disables legacy Kazumi startup services by default, made legacy controllers lazy, and removed the old rating switch from interface settings.

**Why:** The main platform route already shows only learning, coding, and relaxation, but the initialization flow still eagerly started old plugins, Bangumi sync, danmaku shield loading, download background services, shortcut prompts, and update checks. That could surface anime-player behavior inside the new programmer learning platform.

**Feature Goal:** Keep old code available for gradual migration while preventing it from actively affecting the new platform startup experience.

**Files Modified:**
- `lib/pages/platform/platform_identity.dart`
- `lib/pages/init_page.dart`
- `lib/pages/settings/interface_settings.dart`
- `test/platform_identity_test.dart`
- `README.md`
- `docs/qa/2026-05-31-manual-acceptance-checklist.md`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Verification:**
- `dart format lib\pages\platform\platform_identity.dart lib\pages\init_page.dart lib\pages\settings\interface_settings.dart test\platform_identity_test.dart`
- `flutter test test\platform_identity_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_identity.dart lib\pages\init_page.dart lib\pages\settings\interface_settings.dart test\platform_identity_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Targeted tests passed, targeted analysis found no issues, and the full Flutter test suite passed with 56 tests. The running Release executable was closed to release the build lock, Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`, and the latest build was launched again for manual acceptance. Existing non-fatal NuGet/CMake warnings remain.

### Step 38: Windows Native Branding

**Operation:** Replaced the remaining Windows native branding for the initial window title, single-instance lookup title, mutex name, desktop shortcut label, shortcut description, version metadata, and the `window_manager` title applied from Flutter startup.

**Why:** The Flutter shell already sets the visible app title, but Windows still had native startup and shortcut metadata referencing Kazumi. These can appear before Flutter finishes initialization, in desktop shortcuts, or in executable properties.

**Feature Goal:** Make the Windows desktop experience identify as `人人都是程序员` while avoiding a risky full package/executable rename in this MVP stage.

**Files Modified:**
- `windows/runner/main.cpp`
- `windows/runner/flutter_window.cpp`
- `windows/runner/Runner.rc`
- `lib/main.dart`
- `README.md`
- `docs/qa/2026-05-31-manual-acceptance-checklist.md`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Verification:**
- `dart format lib\main.dart`
- `dart analyze lib\main.dart lib\pages\platform\platform_identity.dart`
- `flutter test`
- `flutter build windows`
- `Start-Process build\windows\x64\runner\Release\kazumi.exe`
- `Get-Process -Name kazumi | Select-Object Id,MainWindowTitle,Path`

**Result:** Targeted analysis passed, the full Flutter test suite passed with 56 tests, and Windows build succeeded. The first runtime title check still showed `Kazumi`, which exposed `WindowOptions(title: 'Kazumi')` in `lib/main.dart`; after switching that to `programmerPlatformTitle` and rebuilding, the process metadata confirmed the main window title is `人人都是程序员`. Existing non-fatal NuGet/CMake warnings remain.

### Step 39: Windows Executable Name

**Operation:** Renamed the Windows CMake binary target from `kazumi` to `everyone_is_programmer` and updated current documentation to point at `build\windows\x64\runner\Release\everyone_is_programmer.exe`.

**Why:** After the native title and metadata were updated, the Release executable name was the largest remaining user-visible Kazumi artifact on Windows. Renaming only the Windows binary target keeps this change scoped and avoids the much riskier Dart package rename.

**Feature Goal:** Make the built Windows artifact align with the programmer learning platform identity while keeping imports and package references stable.

**Files Modified:**
- `windows/CMakeLists.txt`
- `windows/runner/Runner.rc`
- `windows/runner/shortcut_utils.cpp`
- `README.md`
- `docs/qa/2026-05-31-manual-acceptance-checklist.md`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Verification Plan:**
- Stop any running old `kazumi.exe` instance so the build directory can be updated.
- Run `flutter build windows`.
- Confirm `everyone_is_programmer.exe` exists and launches with the title `人人都是程序员`.

**Current Verification Status:** `flutter build windows` exposed stale CMake files from the previous target name, so `flutter clean` was run to regenerate the Windows build directory. After cleaning, Flutter needed to recreate Windows plugin symlinks, but the current Windows account does not have symlink permission and Developer Mode is not enabled. The command now stops with `Building with plugins requires symlink support`. The Windows Developer Mode settings page was opened so the permission can be enabled before retrying the build.

**Verification:**
- `flutter clean`
- `flutter build windows`
- Administrator PowerShell retry for `flutter build windows`
- `Test-Path build\windows\x64\runner\Release\everyone_is_programmer.exe`
- `Test-Path build\windows\x64\runner\Release\kazumi.exe`
- `Start-Process build\windows\x64\runner\Release\everyone_is_programmer.exe`
- `Get-Process -Name everyone_is_programmer | Select-Object Id,MainWindowTitle,Path`
- `flutter test`

**Result:** The normal post-clean build was blocked by Windows symlink permissions. Running the build through an administrator PowerShell completed successfully and produced `build\windows\x64\runner\Release\everyone_is_programmer.exe`; the old `kazumi.exe` was not present in the regenerated Release directory. The new executable launched successfully, and process metadata confirmed the window title is `人人都是程序员`. The full Flutter test suite passed with 56 tests.

### Step 40: RAG Chunk Retrieval Upgrade

**Operation:** Added local RAG document chunks and switched retrieval evidence from whole-document excerpts to the best matching chunk.

**Why:** The previous local RAG prototype ranked documents, but real RAG systems retrieve smaller passages so answers can cite precise context. Chunk-level retrieval is the next useful improvement before adding Embedding or an external model.

**Feature Goal:** Let imported and built-in documents split into summary/body chunks, score each chunk locally, show the matched chunk label in the UI, and use that chunk as answer evidence.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_rag_catalog_test.dart`
- `README.md`
- `docs/qa/2026-05-31-manual-acceptance-checklist.md`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Verification Plan:**
- Format modified Dart files.
- Run RAG catalog tests.
- Run targeted analysis for modified RAG files.
- Run the full Flutter test suite.

**Verification:**
- `dart format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart`
- `flutter test test\platform_rag_catalog_test.dart`
- `dart analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart`
- `flutter test`
- `flutter build windows`
- `Start-Process build\windows\x64\runner\Release\everyone_is_programmer.exe`

**Result:** RAG catalog tests passed with 7 tests, targeted analysis found no issues, and the full Flutter test suite passed with 58 tests. Windows build succeeded at `build\windows\x64\runner\Release\everyone_is_programmer.exe`; the latest executable launched successfully with the window title `人人都是程序员`. Existing non-fatal NuGet/CMake warnings remain.

### Step 41: Code Audit Report Save

**Operation:** Added a code audit report repository and a `保存报告` action in the coding zone.

**Why:** The coding zone already generated and copied Markdown reports, but real audit workflows need a durable artifact that can be reviewed later or attached to project notes.

**Feature Goal:** Save the current local scan report as a Markdown file under the app support directory, then show the latest saved path in the UI.

**Files Added:**
- `lib/pages/platform/platform_code_audit_repository.dart`
- `test/platform_code_audit_repository_test.dart`

**Files Modified:**
- `lib/pages/platform/coding_zone_page.dart`
- `README.md`
- `docs/qa/2026-05-31-manual-acceptance-checklist.md`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Verification:**
- `dart format lib\pages\platform\coding_zone_page.dart lib\pages\platform\platform_code_audit_repository.dart test\platform_code_audit_repository_test.dart`
- `flutter test test\platform_code_audit_repository_test.dart test\platform_code_audit_rules_test.dart`
- `dart analyze lib\pages\platform\coding_zone_page.dart lib\pages\platform\platform_code_audit_repository.dart test\platform_code_audit_repository_test.dart test\platform_code_audit_rules_test.dart`
- `flutter test`
- `flutter build windows`
- `Start-Process build\windows\x64\runner\Release\everyone_is_programmer.exe`

**Result:** Repository tests passed, targeted analysis found no issues, and the full Flutter test suite passed with 59 tests. Windows build succeeded at `build\windows\x64\runner\Release\everyone_is_programmer.exe`, and the latest executable launched successfully with the window title `人人都是程序员`. Existing non-fatal NuGet/CMake warnings remain.

### Step 24: Verification For RAG And Recommendation Step

**Operation:** Ran Dart formatter on the new RAG/recommendation files and related widget tests.

**Result:** Formatter completed successfully. `test/platform_recommendation_catalog_test.dart` was rewritten by the formatter.

**Operation:** Ran targeted tests.

**Commands:**
- `flutter test test\platform_rag_catalog_test.dart`
- `flutter test test\platform_recommendation_catalog_test.dart`
- `flutter test test\platform_zones_test.dart`

**Result:** RAG and recommendation tests passed. The first zone test initially failed because new RAG result cards made `Markdown 知识库` and `PDF / 文档资料` appear more than once; the test was corrected to assert presence instead of exact count.

**Operation:** Ran the full Flutter test suite.

**Command:** `flutter test`

**Result:** Passed. All 42 tests passed.

**Operation:** Ran targeted static analysis on the modified platform files and tests.

**Result:** Passed with no issues.

**Operation:** Built the Windows app.

**Command:** `flutter build windows`

**Result:** Succeeded. The binary was built at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning from `webview_windows` remains.

## 2026-05-30

### Step 25: Local RAG Import Prototype

**Operation:** Extended local RAG retrieval to accept user-provided documents in addition to built-in sample documents.

**Why:** A RAG area is not useful if it only searches bundled examples. The next useful milestone is letting users add their own notes or snippets and see them appear in retrieval immediately.

**Feature Goal:** Support a page-level local RAG import flow with title, source, summary, content, and tags. Imported documents participate in the same keyword scoring path as built-in documents.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_rag_catalog_test.dart`
- `test/platform_zones_test.dart`

**Verification:**
- `dart format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_rag_catalog_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Targeted tests passed, targeted analysis passed with no issues, all 43 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

### Step 26: Persist Imported RAG Documents

**Operation:** Added JSON serialization for `LocalRagDocument`, added a `platformRagDocuments` setting key, and introduced `PlatformRagRepository` with a Hive-backed storage adapter.

**Why:** Page-level imported RAG documents disappeared after restart. Persisting the documents in the existing dynamic Hive setting box gives the platform a real local knowledge base without adding a new adapter or migration.

**Feature Goal:** Load imported RAG documents when the learning zone opens, save new documents after import, and support deleting imported documents from the local library.

**Files Added:**
- `lib/pages/platform/platform_rag_repository.dart`
- `test/platform_rag_repository_test.dart`

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `lib/utils/storage.dart`

**Verification:**
- `dart format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\platform_rag_repository.dart lib\pages\platform\rag_library_preview.dart lib\utils\storage.dart test\platform_rag_repository_test.dart`
- `flutter test test\platform_rag_repository_test.dart`
- `flutter test test\platform_rag_catalog_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\platform_rag_repository.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_repository_test.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Repository, catalog, and zone tests passed. One parallel Flutter command initially failed on a tool startup lock/temporary file deletion conflict and passed when rerun sequentially. Targeted analysis passed with no issues, all 45 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

### Step 27: Local Code Audit Scanner

**Operation:** Added deterministic code audit rules for hardcoded secrets, dynamic `eval`, plaintext HTTP URLs, and debug output. Added a coding-zone scanner panel with a code input, scan button, finding count, severity labels, line locations, evidence, and fix suggestions.

**Why:** The coding zone had workflow guidance and Prompt templates, but did not yet perform an action on code. A local scanner provides immediate value and creates a structured pre-check before future AI review.

**Feature Goal:** Let users paste a code snippet and get a first-pass audit report without network or model dependency.

**Files Added:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`

**Files Modified:**
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_zones_test.dart`

**Verification:**
- `dart format lib\pages\platform\platform_code_audit_rules.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_rules_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_code_audit_rules_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_code_audit_rules.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_rules_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** The scanner test initially expected line 2 for a triple-quoted sample; the scanner correctly reported line 1, so the test was fixed. Targeted tests and analysis passed, all 47 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

### Step 28: Copyable Code Audit Report

**Operation:** Added Markdown report formatting for local code audit findings and exposed a `复制报告` action in the coding zone scanner.

**Why:** A scan result is more useful when it can be copied into a repair task, an AI review prompt, or the local RAG knowledge base. Keeping formatting in the rules layer also makes it testable outside the UI.

**Feature Goal:** Convert local scan findings into a portable report with risk counts, severity, location, evidence, explanation, and fix suggestions.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_code_audit_rules_test.dart`
- `test/platform_zones_test.dart`

**Verification:**
- `dart format lib\pages\platform\platform_code_audit_rules.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_rules_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_code_audit_rules_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_code_audit_rules.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_rules_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Targeted tests and analysis passed, all 48 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

### Step 29: Relax Session History

**Operation:** Added persistent relax session records and a `节奏记录` panel in the relax zone. Users can record the current focus/rest rhythm, see recent sessions, total count, total minutes, and clear history.

**Why:** A relaxation area should help users build a sustainable study rhythm. Recording completed focus/rest sessions gives feedback beyond a one-off timer and makes the relax zone useful across app restarts.

**Feature Goal:** Persist focus and rest completion history locally through the existing Hive setting box.

**Files Added:**
- `lib/pages/platform/platform_relax_session_repository.dart`
- `test/platform_relax_session_repository_test.dart`

**Files Modified:**
- `lib/pages/platform/relax_zone_page.dart`
- `lib/utils/storage.dart`
- `test/platform_zones_test.dart`

**Verification:**
- `dart format lib\pages\platform\platform_relax_session_repository.dart lib\pages\platform\relax_zone_page.dart lib\utils\storage.dart test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_relax_session_repository_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_relax_session_repository.dart lib\pages\platform\relax_zone_page.dart test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** One parallel Flutter test command crashed on a native asset copy conflict and passed when rerun sequentially. Targeted tests and analysis passed, all 50 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

### Step 30: Usable Learning Resource Entrypoints

**Operation:** Added external URL detection for learning resources and connected resource action sheets to `url_launcher` and clipboard copy.

**Why:** The learning zone already listed video courses and local platform resources, but users could only read the URL text. Opening external course links and copying local entries makes the resource catalog usable.

**Feature Goal:** Let users open video resources such as CS50, MIT 6.006, and FreeCodeCamp directly, while still supporting local RAG/Skill/MCP entries through copyable `local://` references.

**Files Modified:**
- `lib/pages/platform/platform_learning_catalog.dart`
- `lib/pages/platform/learning_zone_page.dart`
- `test/platform_learning_catalog_test.dart`

**Verification:**
- `dart format lib\pages\platform\platform_learning_catalog.dart lib\pages\platform\learning_zone_page.dart test\platform_learning_catalog_test.dart`
- `flutter test test\platform_learning_catalog_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_learning_catalog.dart lib\pages\platform\learning_zone_page.dart test\platform_learning_catalog_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Targeted tests passed. The first targeted analysis command timed out while run in parallel, then passed when rerun alone with a longer timeout. All 51 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

### Step 31: Learning Progress Tracking

**Operation:** Added stable resource IDs, a learning progress repository, and a `学习进度` panel with per-resource completion checkboxes.

**Why:** Resource links make the learning zone usable, but users also need feedback across repeated sessions. Persisting completed resources turns the catalog into a lightweight study tracker.

**Feature Goal:** Let users mark learning resources as completed, persist the completed set locally, and see overall progress across the 15 curated resources.

**Files Added:**
- `lib/pages/platform/platform_learning_progress_repository.dart`
- `test/platform_learning_progress_repository_test.dart`

**Files Modified:**
- `lib/pages/platform/platform_learning_catalog.dart`
- `lib/pages/platform/learning_zone_page.dart`
- `lib/utils/storage.dart`
- `test/platform_zones_test.dart`

**Verification:**
- `dart format lib\pages\platform\platform_learning_catalog.dart lib\pages\platform\platform_learning_progress_repository.dart lib\pages\platform\learning_zone_page.dart lib\utils\storage.dart test\platform_learning_progress_repository_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_learning_progress_repository_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_learning_catalog.dart lib\pages\platform\platform_learning_progress_repository.dart lib\pages\platform\learning_zone_page.dart test\platform_learning_progress_repository_test.dart test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Targeted tests and analysis passed, all 53 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

## 2026-05-31

### Step 32: Platform Identity Cleanup

**Operation:** Added shared platform identity constants and replaced visible app title, tray tooltip, tray exit label, and exit confirmation text.

**Why:** The project has been converted into a programmer learning platform, but key shell-level strings still referenced Kazumi. Cleaning these user-visible strings makes the app feel like the new platform instead of a reskinned anime client.

**Feature Goal:** Present the app as `人人都是程序员` consistently at the window and tray level.

**Files Added:**
- `lib/pages/platform/platform_identity.dart`
- `test/platform_identity_test.dart`

**Files Modified:**
- `lib/app_widget.dart`

**Verification:**
- `dart format lib\app_widget.dart lib\pages\platform\platform_identity.dart test\platform_identity_test.dart`
- `flutter test test\platform_identity_test.dart`
- `dart analyze lib\app_widget.dart lib\pages\platform\platform_identity.dart test\platform_identity_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Identity test and targeted analysis passed. The first build attempt timed out at 5 minutes without a result, then passed with a longer timeout. All 54 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

### Step 33: Project README And Metadata

**Operation:** Replaced the old Kazumi README with a programmer learning platform README and updated `pubspec.yaml` description/MSIX display name.

**Why:** The repository entry point still described an anime collection/player app. Documentation needed to match the current platform surface so a new user can understand the three zones, RAG, recommendation, code audit, and relax workflows.

**Feature Goal:** Make the project understandable from the repository root and align packaging metadata with `人人都是程序员`.

**Files Modified:**
- `README.md`
- `pubspec.yaml`

**Verification:**
- `flutter test test\platform_identity_test.dart`
- `flutter test test\platform_zones_test.dart`
- `flutter test`
- `flutter build windows`

**Result:** Parallel targeted tests initially hit Flutter's `build\unit_test_assets` lock; rerunning sequentially passed. All 54 tests passed, and Windows build succeeded at `build\windows\x64\runner\Release\kazumi.exe`. The existing non-fatal NuGet/CMake warning remains.

### Step 34: Manual QA And Handoff Documents

**Operation:** Added a manual acceptance checklist and MVP handoff document.

**Why:** Automated tests and builds validate code paths, but this platform also needs human checks for navigation, persisted state, clipboard actions, link opening, and desktop app behavior. A handoff document also keeps the remaining work explicit.

**Feature Goal:** Provide a practical checklist for manual validation and a concise delivery summary for future development.

**Files Added:**
- `docs/qa/2026-05-31-manual-acceptance-checklist.md`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

### Step 19: Coding Zone Audit Workflow

**Operation:** Added an audit readiness panel, interactive checklist, and copyable Prompt templates to `CodingZonePage`.

**Why:** The coding zone should support actual programming workflows, not only describe them. A checklist gives deterministic steps before AI review, while Prompt templates prepare for later model integration.

**Feature Goal:** Build the first usable coding workflow: import project context, scan rules, run AI audit, generate reports, and copy prompts for security review, learning summaries, or recommendation-model design.

**Files Modified:**
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_zones_test.dart`

### Step 20: Relax Zone Timer

**Operation:** Added durations to `RelaxTool` and implemented a selectable focus/rest timer in `RelaxZonePage`.

**Why:** The relax zone should provide a real recovery action. A timer is a small but useful tool that supports study and coding rhythm without needing backend services.

**Feature Goal:** Let users start a 25-minute focus session, a 5-minute short break, or a 15-minute long break directly inside the platform.

**Files Modified:**
- `lib/pages/platform/platform_relax_toolkit.dart`
- `lib/pages/platform/relax_zone_page.dart`
- `test/platform_zones_test.dart`

### Step 21: Verification

**Operation:** Ran Dart formatter on all modified platform files and tests.

**Result:** Formatting completed. `platform_learning_catalog.dart` and `coding_zone_page.dart` were rewritten by the formatter.

**Operation:** Ran targeted platform tests.

**Commands:**
- `flutter test test\platform_zones_test.dart`
- `flutter test test\platform_learning_catalog_test.dart`

**Result:** Passed. The three platform zones render the new workbench, audit, and timer surfaces; the learning catalog exposes complete resource metadata.

**Operation:** Ran the full Flutter test suite.

**Command:** `flutter test`

**Result:** Passed. All 38 tests passed.

**Operation:** Ran static analysis.

**Commands:**
- `flutter analyze`
- `dart analyze lib\pages\platform\platform_learning_catalog.dart lib\pages\platform\learning_zone_page.dart lib\pages\platform\coding_zone_page.dart lib\pages\platform\platform_relax_toolkit.dart lib\pages\platform\relax_zone_page.dart test\platform_zones_test.dart test\platform_learning_catalog_test.dart`

**Result:** `flutter analyze` still reported 61 existing info-level issues in legacy Kazumi files and exited non-zero. Targeted analysis for the modified platform files and tests passed with no issues.

**Operation:** Built the Windows app.

**Command:** `flutter build windows`

**Result:** Succeeded. The binary was built at `build\windows\x64\runner\Release\kazumi.exe`. The build kept the existing non-fatal NuGet/CMake warning from `webview_windows`.

### Step 22: Local RAG Retrieval Prototype

**Operation:** Added local RAG document data, a keyword scoring function, and search result objects.

**Why:** The platform already had RAG source categories, but users also need to see how local materials can be retrieved. A deterministic keyword retriever is small, testable, and can later be replaced by Embedding/vector search.

**Feature Goal:** Let the learning zone search local notes about RAG, MCP, recommendation algorithms, BM25, code audit, and focus rhythm.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_rag_catalog_test.dart`
- `test/platform_zones_test.dart`

### Step 23: Recommendation Algorithm Prototype

**Operation:** Added a local recommendation catalog with learning goals, keyword weights, recommendation pipeline labels, scored recommendations, and explainable reasons.

**Why:** The user explicitly asked that recommendation algorithms and models be included. This implements a visible first version of recall/ranking logic without requiring a backend model service.

**Feature Goal:** Recommend learning resources for goals such as programming foundation, local RAG, code audit, and recommendation algorithms, while showing the ranking reason.

**Files Added:**
- `lib/pages/platform/platform_recommendation_catalog.dart`
- `test/platform_recommendation_catalog_test.dart`

**Files Modified:**
- `lib/pages/platform/learning_zone_page.dart`
- `test/platform_zones_test.dart`

### Step 45: Platform Settings Surface And Startup Slimming

**Operation:** Added a dedicated platform settings entry, gave each primary zone a shared settings button in the page header, and registered `/settings/` as the platform-facing settings home.

**Why:** The app shell had already been reshaped into learning, coding, and relax zones, but users still had no obvious platform settings entry from those screens. At the same time, the settings module still behaved like the legacy product's internal route tree instead of a platform home.

**Feature Goal:** Let users reach a platform-specific settings surface directly from any main zone while keeping the default settings entry aligned with the programmer learning platform identity.

**Files Added:**
- `lib/pages/platform/platform_page_header.dart`
- `lib/pages/settings/platform_settings_page.dart`

**Files Modified:**
- `lib/pages/platform/learning_zone_page.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `lib/pages/platform/relax_zone_page.dart`
- `lib/pages/settings/settings_module.dart`
- `test/platform_zones_test.dart`

**Operation:** Stopped the platform startup flow from copying legacy Anime4K shaders unless legacy startup services are explicitly enabled.

**Why:** Platform mode does not currently expose the old super-resolution/video stack, so shader copying was unnecessary startup I/O. Moving it behind the legacy service gate reduces platform startup work and better matches the current product boundary.

**Feature Goal:** Keep platform startup focused on the new three-zone experience and avoid initializing unused legacy media assets by default.

**Files Modified:**
- `lib/pages/init_page.dart`

**Operation:** Continued branding cleanup in About and fallback error surfaces by replacing remaining `Kazumi` user-facing labels with the programmer platform identity and by clarifying which external links still point to legacy project infrastructure.

**Why:** Mixed product naming makes the app feel half-migrated. The About page is a high-signal place for users to judge whether the platform identity is coherent.

**Feature Goal:** Make licenses, exit behavior, cache messaging, and initialization fallback screens read consistently as `人人都是程序员`, while still acknowledging the legacy project origins where relevant.

**Files Modified:**
- `lib/pages/about/about_module.dart`
- `lib/pages/about/about_page.dart`
- `lib/pages/index_module.dart`

**Operation:** Ran formatter and targeted platform regression tests after the first-pass cleanup.

**Commands:**
- `dart format lib/pages/platform/platform_page_header.dart lib/pages/settings/platform_settings_page.dart lib/pages/platform/learning_zone_page.dart lib/pages/platform/coding_zone_page.dart lib/pages/platform/relax_zone_page.dart lib/pages/settings/settings_module.dart lib/pages/init_page.dart lib/pages/about/about_module.dart lib/pages/about/about_page.dart lib/pages/index_module.dart test/platform_zones_test.dart`
- `flutter test test/platform_zones_test.dart`
- `flutter test test/platform_zones_test.dart test/platform_learning_catalog_test.dart test/platform_learning_progress_repository_test.dart test/platform_rag_catalog_test.dart test/platform_rag_repository_test.dart test/platform_recommendation_catalog_test.dart test/platform_code_audit_rules_test.dart test/platform_code_audit_repository_test.dart test/platform_relax_session_repository_test.dart test/platform_identity_test.dart`

**Result:** Passed. The new platform settings surface rendered correctly, the three zones exposed the shared settings entry, and the targeted platform regression suite passed with 38 tests.

### Step 46: Platform Settings Route Narrowing

**Operation:** Narrowed the default `SettingsModule` route table to platform-facing settings only.

**Why:** The previous route table still registered legacy player, danmaku, plugin, history, proxy, WebDAV, download, and Bangumi settings under the same `/settings` module. Even after adding a platform settings home, those routes kept the new platform shell coupled to the old video-product surface.

**Feature Goal:** Make `/settings/` a platform-owned route tree by default, with only platform settings, theme/display settings, interface settings, and About/license/log support routes exposed.

**Files Modified:**
- `lib/pages/settings/settings_module.dart`

**Legacy Routes Removed From Default Platform Settings Registration:**
- `/settings/player`
- `/settings/player/decoder`
- `/settings/player/renderer`
- `/settings/player/super`
- `/settings/keyboard`
- `/settings/proxy`
- `/settings/webdav`
- `/settings/plugin`
- `/settings/history`
- `/settings/danmaku`
- `/settings/download`
- `/settings/download-settings`
- `/settings/bangumi`

**Operation:** Ran formatter, targeted widget tests, and targeted static analysis for the narrowed route table.

**Commands:**
- `dart format lib/pages/settings/settings_module.dart`
- `flutter test test/platform_zones_test.dart test/platform_identity_test.dart`
- `dart analyze lib/pages/settings/settings_module.dart lib/pages/settings/platform_settings_page.dart test/platform_zones_test.dart`

**Result:** Passed. The platform zone and identity tests passed with 10 tests, and targeted analysis reported no issues.

### Step 47: Default Index Module Slimming

**Operation:** Removed legacy controller, repository, and media/search route registrations from the default `IndexModule`.

**Why:** The platform startup path no longer needs the old video, Bangumi, plugin, history, collect, search, or download controller graph. Keeping those registrations in the default module made the platform shell carry legacy dependencies even after the visible settings routes were narrowed.

**Feature Goal:** Make the default app module boot around the platform zones, platform settings, and shared image preview only. Legacy feature files remain in the repository, but they are no longer created or routed through the default platform module.

**Default Registrations Removed:**
- `ICollectRepository`
- `ISearchHistoryRepository`
- `ICollectCrudRepository`
- `IHistoryRepository`
- `IDownloadRepository`
- `IDownloadManager`
- `PopularController`
- `PluginsController`
- `VideoPageController`
- `TimelineController`
- `CollectController`
- `HistoryController`
- `MyController`
- `ShadersController`
- `DownloadController`
- `/video`
- `/info`
- `/search`

**Operation:** Removed two remaining platform-page dependencies on legacy controllers.

**Why:** `ThemeSettingsPage` no longer used `PopularController`, and `AboutPage` only used `MyController` for the old auto-update check. Removing those references allowed the default module to stop registering legacy controllers.

**Files Modified:**
- `lib/pages/index_module.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `lib/pages/about/about_page.dart`

**Operation:** Ran formatter, targeted static analysis, and targeted platform tests.

**Commands:**
- `dart format lib/pages/index_module.dart lib/pages/settings/theme_settings_page.dart lib/pages/about/about_page.dart`
- `dart analyze lib/pages/index_module.dart lib/pages/settings/theme_settings_page.dart lib/pages/about/about_page.dart lib/pages/init_page.dart lib/pages/settings/settings_module.dart test/platform_zones_test.dart`
- `flutter test test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Targeted static analysis reported no issues, and the platform zone and identity tests passed with 10 tests.

### Step 48: Platform Startup Dependency Cleanup

**Operation:** Removed legacy-only startup imports, controller lookups, service initialization methods, and update/plugin/download callbacks from `InitPage`.

**Why:** The platform module no longer registers legacy controllers or legacy media routes. Keeping legacy startup code in `InitPage` meant the platform startup file still depended on plugins, Bangumi sync, WebDAV sync, downloads, shaders, shortcut creation, and old update checks even though those services are no longer part of the default platform flow.

**Feature Goal:** Make platform startup responsible only for platform-safe boot work: checking the Linux X11 warning, normalizing the default startup page, applying the dynamic-color preference, and navigating into the three-zone platform shell.

**Legacy Startup Code Removed From `InitPage`:**
- Plugin initialization and plugin update checks
- Legacy disclaimer and update mirror dialog
- Collect migration
- Danmaku shield loading
- WebDAV initialization and history sync
- Bangumi initialization
- Download controller/background download setup
- Anime4K shader copy
- Windows shortcut prompt
- Old auto-update check through `MyController`

**Files Modified:**
- `lib/pages/init_page.dart`

**Operation:** Ran formatter, targeted static analysis, and targeted platform tests.

**Commands:**
- `dart format lib/pages/init_page.dart`
- `dart analyze lib/pages/init_page.dart lib/pages/index_module.dart lib/pages/settings/settings_module.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `flutter test test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Targeted static analysis reported no issues, and the platform zone and identity tests passed with 10 tests.

### Step 49: Platform Boundary Regression Tests

**Operation:** Added source-level regression tests for the default platform boundary.

**Why:** The previous cleanup removed legacy startup, settings, and route registrations from the platform path. Before deeper dependency work, the project needs a small guardrail that fails if future changes re-register old video, plugin, download, Bangumi, WebDAV, or search surfaces in the default platform modules.

**Feature Goal:** Keep the default `IndexModule`, `SettingsModule`, and `InitPage` aligned with the three-zone platform shell while legacy code remains in the repository.

**Files Added:**
- `test/platform_boundary_test.dart`

**Boundaries Covered:**
- `IndexModule` exposes platform routes, settings, and shared image preview, but not `/video`, `/info`, `/search`, or old controllers.
- `SettingsModule` exposes platform settings, theme/display, interface, and About support routes, but not old player, danmaku, plugin, download, Bangumi, WebDAV, or proxy settings.
- `InitPage` keeps platform startup responsibilities and stays free of legacy service initialization references.

**Operation:** Fixed the README verification command that was hostile to PowerShell wildcard handling.

**Why:** Passing `test/platform_*_test.dart` directly to `dart analyze` on Windows treats the wildcard as a literal path and fails. The README should provide commands that work in the current Windows development environment.

**Files Modified:**
- `README.md`

**Command Changed:**
- From: `dart analyze lib/pages/platform test/platform_*_test.dart`
- To: `dart analyze lib/pages/platform test`

**Operation:** Ran formatter, targeted static analysis, and targeted platform tests.

**Commands:**
- `dart format test/platform_boundary_test.dart`
- `dart analyze test/platform_boundary_test.dart test/platform_zones_test.dart lib/pages/index_module.dart lib/pages/settings/settings_module.dart lib/pages/init_page.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Targeted static analysis reported no issues, and the boundary, platform zone, and identity tests passed with 13 tests.

### Step 50: Dependency Audit And Media Runtime Startup Removal

**Operation:** Removed the default platform startup call to `MediaKit.ensureInitialized()` and the direct `media_kit` import from `main.dart`.

**Why:** The default platform module no longer registers player routes or media controllers. Initializing the media runtime during every platform startup kept a legacy player dependency active even though the three-zone platform shell does not need it.

**Feature Goal:** Keep default startup focused on platform storage, window setup, theme state, and routing, while legacy media dependencies remain dormant until the old player surface is explicitly reintroduced or moved into a legacy module.

**Files Modified:**
- `lib/main.dart`
- `test/platform_boundary_test.dart`

**Operation:** Added a dependency audit document that classifies platform-required packages, legacy-retained packages, completed dependency boundary work, and next removal candidates.

**Why:** The repository still contains legacy Kazumi source files. Removing packages directly from `pubspec.yaml` before moving or deleting those files would break analysis and builds. The audit document creates a concrete path for future dependency removal instead of relying on memory or broad guesses.

**Files Added:**
- `docs/plans/platform-dependency-audit.md`

**Files Modified:**
- `README.md`

**Operation:** Extended boundary tests so the default startup guard also rejects `MediaKit.ensureInitialized()` and the direct `media_kit` import.

**Commands:**
- `dart format test/platform_boundary_test.dart`
- `dart analyze lib/main.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Targeted static analysis reported no issues, and the boundary, platform zone, and identity tests passed with 13 tests.

### Step 51: Platform-Only Storage Initialization

**Operation:** Added `GStorage.initPlatform()` and switched default startup from full legacy storage initialization to platform-only storage initialization.

**Why:** The platform shell only needs the shared `setting` box for theme, interface, learning progress, local RAG documents, and relax sessions. Full `GStorage.init()` still registered and opened old favorites, collectibles, history, shield, search history, and download boxes, which kept default startup coupled to legacy data models.

**Feature Goal:** Let the default platform startup open only the storage it needs while preserving the existing full `GStorage.init()` path for legacy code that still depends on old boxes.

**Files Modified:**
- `lib/main.dart`
- `lib/utils/storage.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Replaced two old `print` calls in storage backup handling with `KazumiLogger`.

**Why:** The targeted analysis for the touched storage file exposed existing `avoid_print` info diagnostics. Since this pass already touched storage, replacing them keeps the platform storage path cleaner and consistent with the existing logging abstraction.

**Operation:** Ran formatter, targeted static analysis, and targeted platform/storage tests.

**Commands:**
- `dart format lib/utils/storage.dart lib/main.dart test/platform_boundary_test.dart`
- `dart analyze lib/main.dart lib/utils/storage.dart test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart test/platform_learning_progress_repository_test.dart test/platform_rag_repository_test.dart test/platform_relax_session_repository_test.dart`

**Result:** Passed. Targeted static analysis reported no issues, and the boundary, platform zone, identity, and platform storage repository tests passed with 19 tests.

### Step 52: Shared Image Preview Route Removal From Platform Graph

**Operation:** Removed the shared `ImageViewer` route registration and import from the default `IndexModule`.

**Why:** The three platform zones do not currently route to the legacy/shared image preview surface. Keeping the route in the default platform module made `cached_network_image` and `photo_view` part of the platform route graph even though the platform shell does not need that preview path.

**Feature Goal:** Keep the default platform module limited to the three platform zones and platform settings. The old image preview widget remains in the repository for legacy callers, but it is no longer part of platform startup routing.

**Files Modified:**
- `lib/pages/index_module.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Updated boundary tests to fail if `ImageViewer` or `image_preview.dart` is reintroduced into the default `IndexModule`.

**Commands:**
- `dart format lib/pages/index_module.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/index_module.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Targeted static analysis reported no issues, and the boundary, platform zone, and identity tests passed with 13 tests.

### Step 53: Platform About Page Legacy Link Cleanup

**Operation:** Removed legacy media-service links from the platform-facing About page.

**Why:** The default platform shell no longer exposes the old Bangumi, danmaku, image-search, or icon-credit surfaces. Keeping those external links in About made the platform identity feel partially coupled to the old video product even after startup, route, and settings boundaries had been narrowed.

**Feature Goal:** Keep About focused on platform identity, license/log/cache support, and the original project provenance links that are still useful while the repository is being migrated.

**Legacy Links Removed From `AboutPage`:**
- `ApiEndpoints.iconUrl` / Pixiv icon credit
- `ApiEndpoints.bangumiIndex` / Bangumi service
- `https://trace.moe` image recognition service
- `ApiEndpoints.dandanIndex` / DanDanPlay danmaku source
- `mortis` import used only for the old DanDanPlay identifier

**Files Modified:**
- `lib/pages/about/about_page.dart`
- `lib/pages/platform/platform_rag_repository.dart`
- `lib/pages/platform/platform_learning_progress_repository.dart`
- `lib/pages/platform/platform_relax_session_repository.dart`
- `test/platform_boundary_test.dart`
- `test/platform_rag_repository_test.dart`
- `test/platform_learning_progress_repository_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added a platform boundary regression test that rejects those legacy media-service links from `AboutPage`.

**Operation:** Corrected the dependency audit document so the default platform path no longer lists `lib/bean/widget/image_preview.dart`, matching the Step 52 route removal.

**Operation:** Switched the platform RAG, learning-progress, and relax-session repositories from `GStorage` / `SettingBoxKey` to `PlatformStorage` / `PlatformSettingKey`.

**Why:** The default startup now initializes `PlatformStorage.init()`. The repositories were still importing the legacy `storage.dart`, which created a runtime boundary mismatch: platform pages could try to read `GStorage.setting` even though only the platform storage box was opened.

**Operation:** Updated platform boundary tests to guard the current storage boundary: default startup must call `PlatformStorage.init()`, platform repositories must not import `storage.dart`, and those repositories must not reference `GStorage` or `SettingBoxKey`.

**Verification Commands:**
- `dart format lib/pages/about/about_page.dart lib/pages/platform/platform_rag_repository.dart lib/pages/platform/platform_learning_progress_repository.dart lib/pages/platform/platform_relax_session_repository.dart test/platform_boundary_test.dart test/platform_rag_repository_test.dart test/platform_learning_progress_repository_test.dart`
- `dart analyze lib/pages/about/about_page.dart lib/pages/platform/platform_rag_repository.dart lib/pages/platform/platform_learning_progress_repository.dart lib/pages/platform/platform_relax_session_repository.dart test/platform_boundary_test.dart test/platform_rag_repository_test.dart test/platform_learning_progress_repository_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart test/platform_rag_repository_test.dart test/platform_learning_progress_repository_test.dart test/platform_relax_session_repository_test.dart`

**Result:** Passed. Formatter reported 0 changed files after cleanup. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests, covering platform boundaries, zone rendering, identity, RAG persistence, learning progress persistence, and relax session persistence.

### Step 54: Platform Metadata Split From Legacy API Endpoints

**Operation:** Added a dedicated platform metadata file for the version and original-project provenance links used by About and License pages.

**Why:** `ApiEndpoints` still contains the old Kazumi video-product network surface, including Bangumi, DanDanPlay, trace, plugin, update, and danmaku endpoints. The platform-facing About and License pages only need the platform version plus the original project/source links, so importing the full legacy endpoint map kept an unnecessary dependency edge in the default platform settings path.

**Feature Goal:** Keep platform About/License metadata small, explicit, and free of legacy media-service endpoint configuration while still preserving useful original-project provenance during migration.

**Files Added:**
- `lib/pages/platform/platform_metadata.dart`

**Files Modified:**
- `lib/pages/about/about_module.dart`
- `lib/pages/about/about_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Updated About and License to use `programmerPlatformVersion`, `originalKazumiProjectUrl`, and `originalKazumiSourceUrl` from `platform_metadata.dart`.

**Operation:** Extended platform boundary tests so About and AboutModule must not import or reference `ApiEndpoints`, and platform metadata must not contain old Bangumi, DanDanPlay, or trace service URLs.

**Verification Commands:**
- `dart format lib/pages/platform/platform_metadata.dart lib/pages/about/about_module.dart lib/pages/about/about_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_metadata.dart lib/pages/about/about_module.dart lib/pages/about/about_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter rewrote `about_page.dart` layout only. Targeted analysis reported no issues. Targeted platform tests passed with 15 tests, covering platform boundaries, zone rendering, and platform identity.

### Step 55: Platform Log File Boundary Cleanup

**Operation:** Renamed the default platform log file from the old `kazumi_logs.log` name to `programmer_platform.log`.

**Why:** The About support surface still exposes the logs page, so the log file path is part of the platform-facing support workflow. Keeping the old product name in that path was a small but visible migration boundary leak.

**Feature Goal:** Make platform support logs use platform naming and one shared helper path instead of duplicating path construction in the logs page.

**Files Modified:**
- `lib/utils/logger.dart`
- `lib/pages/logs/logs_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added `platformLogFileName` and reused it from both logger output and `getLogsPath()`.

**Operation:** Updated `LogsPage` to use `getLogsPath()` and `clearLogs()` instead of constructing the app-support log path and writing the file directly.

**Operation:** Replaced logger console output with `debugPrint` and removed `print` fallback calls from logger file-write and clear-log failure paths to avoid analyzer noise and recursive console output in the logging layer.

**Operation:** Extended platform boundary tests so the logger and logs page reject `kazumi_logs.log`, and the logs page must use the shared log helpers.

**Verification Commands:**
- `dart format lib/utils/logger.dart lib/pages/logs/logs_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/utils/logger.dart lib/pages/logs/logs_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter rewrote `logger.dart` and `logs_page.dart`, then reported no further changes. Targeted analysis reported no issues after replacing logger `print` output with `debugPrint`. Targeted platform tests passed with 16 tests, covering platform boundaries, zone rendering, and platform identity.

### Step 56: Linux Tray Application Id Platformization

**Operation:** Added `platformLinuxApplicationId` to platform metadata and used it from the default app shell when setting the tray icon in Flatpak/Snap-style Linux environments.

**Why:** The default platform `AppWidget` still hard-coded the old `io.github.Predidit.Kazumi` app id for packaged Linux tray icons. That kept a legacy product identifier inside the platform startup surface even after titles, logs, About metadata, and Windows naming had been moved toward the programmer learning platform identity.

**Feature Goal:** Keep packaged Linux tray integration aligned with platform metadata and avoid hard-coded legacy application identifiers in the default app shell.

**Files Modified:**
- `lib/pages/platform/platform_metadata.dart`
- `lib/app_widget.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Updated `AppWidget` to pass `platformLinuxApplicationId` to `trayManager.setIcon(...)` for Flatpak/Snap environments.

**Operation:** Extended platform boundary tests so the default app shell must reference `platformLinuxApplicationId` and must not hard-code `io.github.Predidit.Kazumi`.

**Verification Commands:**
- `dart format lib/pages/platform/platform_metadata.dart lib/app_widget.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_metadata.dart lib/app_widget.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed with one tooling note. Targeted analysis reported no issues. Targeted platform tests passed with 17 tests, covering platform boundaries, zone rendering, and platform identity. The formatter command's first attempt timed out in the approval review path, and the retry was rejected because the automatic approval service returned 503; no formatter diagnostics were produced.

### Step 57: Linux Packaging Metadata Platformization

**Operation:** Updated Linux CMake package identity from the old Kazumi executable and GTK application id to the programmer platform identity.

**Why:** After moving the runtime tray app id into `platformLinuxApplicationId`, the Linux build metadata still produced a `kazumi` binary and used `io.github.Predidit.Kazumi` as the GTK application id. That kept Linux packaging out of sync with the platform-facing identity.

**Feature Goal:** Align default Linux package metadata with `everyone_is_programmer` and `io.github.everyone_is_programmer.Platform`.

**Files Added:**
- `assets/linux/io.github.everyone_is_programmer.Platform.desktop`

**Files Removed:**
- `assets/linux/io.github.Predidit.Kazumi.desktop`

**Files Modified:**
- `linux/CMakeLists.txt`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Replaced the Linux desktop entry with a platform-named desktop file, platform app id, platform executable name, development/education categories, and platform description text.

**Operation:** Extended platform boundary tests so Linux CMake and desktop metadata must use platform identifiers and the old desktop file must not exist.

**Verification Commands:**
- `dart format test/platform_boundary_test.dart`
- `dart analyze test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter rewrote `test/platform_boundary_test.dart`. Targeted analysis reported no issues. Targeted platform tests passed with 18 tests, covering platform boundaries, zone rendering, and platform identity.

### Step 58: Linux Debian Install Script Platformization

**Operation:** Updated Linux DEBIAN install and remove scripts from the old `kazumi` command link to the platform executable name.

**Why:** Step 57 renamed the Linux binary to `everyone_is_programmer`, but the package install scripts still linked `/opt/Kazumi/kazumi` into `/usr/bin/kazumi`. That would leave installed Linux packages with a stale command entry and a broken identity path.

**Feature Goal:** Keep Linux package install/remove scripts consistent with the platform binary and install directory naming.

**Files Modified:**
- `assets/linux/DEBIAN/postinst`
- `assets/linux/DEBIAN/postrm`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Changed `postinst` to link `/opt/everyone_is_programmer/everyone_is_programmer` to `/usr/bin/everyone_is_programmer`.

**Operation:** Changed `postrm` to remove `/usr/bin/everyone_is_programmer`.

**Operation:** Extended Linux packaging boundary tests so install scripts must use platform paths and must not reference `/opt/Kazumi` or `/usr/bin/kazumi`.

**Verification Commands:**
- `dart format test/platform_boundary_test.dart`
- `dart analyze test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter reported 0 changed files after the script edits. Targeted analysis reported no issues. Targeted platform tests passed with 18 tests, covering platform boundaries, zone rendering, and platform identity.

### Step 59: Web App Metadata Platformization

**Operation:** Updated Web/PWA metadata from the old `kazumi` name and default Flutter description to the programmer learning platform identity.

**Why:** The web entrypoint and manifest are user-visible packaging metadata. Leaving `kazumi` and `A new Flutter project.` in those files made the Web/PWA surface inconsistent with the platform shell, Linux package metadata, Windows executable naming, and About page identity.

**Feature Goal:** Make Web/PWA install and browser surfaces present `人人都是程序员` with a platform-specific learning/practice/recovery description.

**Files Modified:**
- `web/index.html`
- `web/manifest.json`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Updated the HTML description, iOS web app title, and document title to platform text.

**Operation:** Updated the web manifest `name`, `short_name`, and `description` to platform text.

**Operation:** Extended platform boundary tests so Web metadata must contain the platform title/description and must not contain `kazumi` or the default Flutter project description.

**Verification Commands:**
- `dart format test/platform_boundary_test.dart`
- `dart analyze test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter reported 0 changed files after the metadata edits. Targeted analysis reported no issues. Targeted platform tests passed with 19 tests, covering platform boundaries, zone rendering, and platform identity.

### Step 60: Linux Native Window Title Platformization

**Operation:** Updated Linux native GTK header/window title strings from `kazumi` to `人人都是程序员`.

**Why:** After Linux CMake, desktop metadata, install scripts, and Web/PWA metadata were platformized, the Linux native window still presented the old product name before or outside Flutter title synchronization. That left one more user-visible Linux entrypoint inconsistent with the platform identity.

**Feature Goal:** Make Linux native window chrome present the programmer learning platform title.

**Files Modified:**
- `linux/my_application.cc`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Changed both `gtk_header_bar_set_title(...)` and `gtk_window_set_title(...)` to `人人都是程序员`.

**Operation:** Extended Linux packaging boundary tests so native GTK titles must contain `人人都是程序员` and must not use the old `kazumi` title calls.

**Design Note:** The Linux native `com.predidit.kazumi/*` MethodChannel names were intentionally left unchanged in this step because Dart legacy utilities and download/storage code still reference them. Renaming those channels safely requires a broader native-channel migration pass.

**Verification Commands:**
- `dart format test/platform_boundary_test.dart`
- `dart analyze test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter rewrote `test/platform_boundary_test.dart`. Targeted analysis reported no issues. Targeted platform tests passed with 19 tests, covering platform boundaries, zone rendering, and platform identity.

### Step 61: Android Visible Metadata Platformization

**Operation:** Updated Android user-visible metadata from the old Kazumi/anime product identity to the programmer learning platform identity.

**Why:** Android install surfaces and fastlane store metadata still presented `Kazumi`, anime collection, danmaku, and custom-rule video wording. That was inconsistent with the platform shell, Web/PWA metadata, and desktop packaging identity.

**Feature Goal:** Make Android-facing app labels and store descriptions present `人人都是程序员` / `Everyone Is Programmer` as a learning, coding practice, local RAG, and recovery rhythm platform.

**Files Modified:**
- `android/app/src/main/AndroidManifest.xml`
- `fastlane/metadata/android/zh-CN/title.txt`
- `fastlane/metadata/android/zh-CN/short_description.txt`
- `fastlane/metadata/android/zh-CN/full_description.txt`
- `fastlane/metadata/android/en-US/title.txt`
- `fastlane/metadata/android/en-US/short_description.txt`
- `fastlane/metadata/android/en-US/full_description.txt`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Changed the Android manifest `android:label` to `人人都是程序员`.

**Operation:** Rewrote zh-CN and en-US fastlane title, short description, and full description for the programmer learning platform.

**Operation:** Extended platform boundary tests so Android visible metadata must use platform text and must not contain old `Kazumi`, anime, or danmaku wording.

**Design Note:** Android `applicationId`, Kotlin package, and `com.predidit.kazumi/*` MethodChannel names were intentionally left unchanged in this step because they are deeper package/native-channel identifiers that require a separate migration pass.

**Verification Commands:**
- `dart format test/platform_boundary_test.dart`
- `dart analyze test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter reported 0 changed files after the metadata edits. Targeted analysis reported no issues. Targeted platform tests passed with 20 tests, covering platform boundaries, zone rendering, and platform identity.

### Step 62: Apple Visible Metadata Platformization

**Operation:** Updated iOS and macOS user-visible app names from the old Kazumi product identity to the programmer learning platform identity.

**Why:** iOS `Info.plist` still exposed `Kazumi` / `kazumi` through `CFBundleDisplayName` and `CFBundleName`, while macOS `AppInfo.xcconfig` still set `PRODUCT_NAME = kazumi`. These values can appear in install surfaces, app switchers, and window/app metadata even when the Flutter shell title has already been platformized.

**Feature Goal:** Make Apple platform visible names present `人人都是程序员` without changing deeper bundle identifiers, Xcode project/module names, or native channel names in this pass.

**Files Modified:**
- `ios/Runner/Info.plist`
- `macos/Runner/Configs/AppInfo.xcconfig`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Changed iOS `CFBundleDisplayName` and `CFBundleName` to `人人都是程序员`.

**Operation:** Changed macOS `PRODUCT_NAME` to `人人都是程序员`.

**Operation:** Extended platform boundary tests so Apple visible metadata must use the platform name and must not contain the old visible `Kazumi` / `kazumi` values.

**Design Note:** Apple bundle identifiers, Xcode project/module names, and `com.predidit.kazumi/*` MethodChannel names were intentionally left unchanged because they require a broader package/native-channel migration pass.

**Verification Commands:**
- `python` plist parse check for `ios/Runner/Info.plist`
- `dart format test/platform_boundary_test.dart`
- `dart analyze test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. iOS plist parsing confirmed `CFBundleDisplayName` and `CFBundleName` are `人人都是程序员`; macOS AppInfo confirmed `PRODUCT_NAME = 人人都是程序员`. Formatter rewrote `test/platform_boundary_test.dart` during verification. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests, covering platform boundaries, zone rendering, and platform identity.

### Step 63: macOS Xcode Product Metadata Platformization

**Operation:** Updated macOS Xcode product metadata from the old `Kazumi.app` / `kazumi` output references to the programmer learning platform app product name.

**Why:** Step 62 changed the Apple visible app name, but the macOS Xcode project and shared scheme still referenced the old product bundle name. That left Xcode build/test metadata inconsistent with `PRODUCT_NAME = 人人都是程序员`.

**Feature Goal:** Align macOS Xcode product references with `人人都是程序员.app` while leaving bundle id, Xcode module names, project names, and native MethodChannel names unchanged in this pass.

**Files Modified:**
- `macos/Runner.xcodeproj/project.pbxproj`
- `macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Changed the Runner product file reference, Products group entry, and product reference comments to `人人都是程序员.app`.

**Operation:** Updated RunnerTests `TEST_HOST` paths to point at `$(BUILT_PRODUCTS_DIR)/人人都是程序员.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/人人都是程序员`.

**Operation:** Removed stale `PRODUCT_NAME = Kazumi` overrides from the Runner target build settings so macOS uses `macos/Runner/Configs/AppInfo.xcconfig`.

**Operation:** Updated the shared Xcode scheme `BuildableName` entries to `人人都是程序员.app`.

**Operation:** Extended platform boundary tests so macOS Xcode project and scheme metadata must contain `人人都是程序员.app`, must not contain `Kazumi.app`, stale `PRODUCT_NAME = Kazumi`, or old `$(BUILT_PRODUCTS_DIR)/kazumi.app` test-host paths, and must continue documenting the intentionally retained `com.example.kazumi` bundle id.

**Design Note:** `PRODUCT_BUNDLE_IDENTIFIER = com.example.kazumi`, Xcode module/project identifiers, and `com.predidit.kazumi/*` MethodChannel names remain intentionally unchanged because those are deeper native/package boundaries that require a separate migration pass.

**Verification Commands:**
- `dart format test/platform_boundary_test.dart`
- `dart analyze test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter reported 0 changed files after the test extension. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests, covering platform boundaries, zone rendering, platform identity, and macOS Xcode product metadata.

### Step 64: Default Platform Logger Platformization

**Operation:** Updated the default platform shell and storage layer to use `PlatformLogger` while keeping `KazumiLogger` as a legacy compatibility alias.

**Why:** The platform shell and storage bootstrap still invoked `KazumiLogger()` even after the visible app identity had moved to `人人都是程序员`. That kept the default startup path tied to a legacy logger name even though the behavior and file naming had already been platformized.

**Feature Goal:** Make the default platform path use a platform-named logger API and keep `KazumiLogger` only as a compatibility bridge for legacy source files.

**Files Modified:**
- `lib/utils/logger.dart`
- `lib/utils/platform_storage.dart`
- `lib/app_widget.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Introduced `PlatformLogger`, `PlatformLogFilter`, `PlatformLogPrinter`, and `PlatformLogOutput` as the platform-facing logger API and kept `KazumiLogger` as a subclass alias for legacy compatibility.

**Operation:** Updated `PlatformStorage` and `AppWidget` to call `PlatformLogger()` instead of `KazumiLogger()`.

**Operation:** Extended the platform boundary test so the logger file must expose `PlatformLogger` and the default platform shell/storage files must not directly call `KazumiLogger()`.

**Design Note:** `KazumiLogger` remains available for older legacy files still in the repository. This step only repointed the default platform path away from the legacy logger name.

**Verification Commands:**
- `dart format lib/utils/logger.dart lib/utils/platform_storage.dart lib/app_widget.dart test/platform_boundary_test.dart`
- `dart analyze lib/utils/logger.dart lib/utils/platform_storage.dart lib/app_widget.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`

**Result:** Passed. Formatter changed `lib/utils/platform_storage.dart` only. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests, covering platform boundaries, zone rendering, platform identity, and default platform logger usage.

### Step 65: Default Platform Utilities Extraction

**Operation:** Extracted the default platform helper surface into `PlatformUtils` and moved startup, shell, About, and theme settings callers away from the legacy `Utils` collection.

**Why:** `lib/utils/utils.dart` still imports legacy video/WebView/danmaku/update infrastructure. The default platform path only needs desktop detection, low-resolution detection, OLED theme derivation, and Linux X11 detection, so keeping it on the large legacy helper preserved unnecessary dependency edges.

**Feature Goal:** Keep default platform utilities on a small platform-specific helper while leaving legacy `Utils` available for old player/WebView code until those modules are removed or isolated.

**Files Modified:**
- `lib/utils/platform_utils.dart`
- `lib/main.dart`
- `lib/app_widget.dart`
- `lib/pages/init_page.dart`
- `lib/pages/about/about_page.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added `PlatformUtils` with `isDesktop`, `isLowResolution`, `oledDarkTheme`, and `isRunningOnX11`.

**Operation:** Updated the default platform callers to import `platform_utils.dart` instead of `utils.dart`.

**Operation:** Removed the default Android startup call to `Utils.checkWebViewFeatureSupport()`.

**Operation:** Extended platform boundary tests so default startup/shell/settings files must not import `package:kazumi/utils/utils.dart`, and `PlatformUtils` must stay free of legacy API endpoint, danmaku, and WebView platform-interface imports.

**Design Note:** `PlatformUtils.isRunningOnX11()` still uses the existing `com.predidit.kazumi/intent` channel because native MethodChannel renaming remains deferred to a broader native-channel migration pass.

**Verification Commands:**
- `dart format lib/utils/platform_utils.dart lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/utils/platform_utils.dart lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number --fixed-strings "package:kazumi/utils/utils.dart" lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `rg --line-number --fixed-strings "checkWebViewFeatureSupport" lib/main.dart lib/utils/platform_utils.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter rewrote About, theme settings, and the platform boundary test. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The fixed-string import check only found test assertions, and `checkWebViewFeatureSupport` was absent from the default startup chain.

### Step 66: Platform Theme Token Extraction

**Operation:** Extracted the default platform theme constants from the legacy `constants.dart` file into `platform_theme_tokens.dart`.

**Why:** `lib/utils/constants.dart` still imports legacy API endpoint metadata for old Bangumi headers and also carries many video/player constants. The platform shell only needs app font, Material progress indicator, slider, and page transition tokens, so keeping default theme construction on `constants.dart` preserved an unnecessary dependency edge.

**Feature Goal:** Keep default platform theme construction on a small platform-specific token file while leaving legacy `constants.dart` available for old player, Bangumi, shortcut, and video configuration code.

**Files Modified:**
- `lib/pages/platform/platform_theme_tokens.dart`
- `lib/bean/settings/theme_provider.dart`
- `lib/app_widget.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added `platformAppFontFamily`, `platformProgressIndicatorTheme`, `platformSliderTheme`, and `platformPageTransitionsTheme`.

**Operation:** Updated `ThemeProvider`, `AppWidget`, and `ThemeSettingsPage` to import `platform_theme_tokens.dart` instead of `utils/constants.dart`.

**Operation:** Extended platform boundary tests so default platform theme files must not import `package:kazumi/utils/constants.dart`, and must use the platform theme token names.

**Verification Commands:**
- `dart format lib/pages/platform/platform_theme_tokens.dart lib/bean/settings/theme_provider.dart lib/app_widget.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_theme_tokens.dart lib/bean/settings/theme_provider.dart lib/app_widget.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number --fixed-strings "package:kazumi/utils/constants.dart" lib/app_widget.dart lib/bean/settings/theme_provider.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter changed `lib/bean/settings/theme_provider.dart` only after the final ignore cleanup. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The fixed-string `constants.dart` check only found boundary-test assertions.

### Step 67: Default Startup Proxy Boundary Cleanup

**Operation:** Removed the default startup call to `ProxyManager.applyProxy()` from `main.dart`.

**Why:** The default programmer platform settings module no longer exposes proxy settings, but startup still refreshed the legacy Dio proxy configuration through `ProxyManager`. That kept the platform entrypoint attached to legacy networking/proxy infrastructure even when proxy configuration is no longer part of the default platform surface.

**Feature Goal:** Keep default platform startup free of legacy proxy manager and Dio client refresh behavior while leaving old proxy settings pages and utilities available for legacy code until they are moved or removed.

**Files Modified:**
- `lib/main.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Removed the `package:kazumi/utils/proxy_manager.dart` import from `main.dart`.

**Operation:** Removed the startup `ProxyManager.applyProxy()` call before `runApp(...)`.

**Operation:** Extended platform boundary tests so `main.dart` must not reference `ProxyManager` or import `proxy_manager.dart`.

**Verification Commands:**
- `dart format lib/main.dart test/platform_boundary_test.dart`
- `dart analyze lib/main.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number --fixed-strings "ProxyManager" lib/main.dart test/platform_boundary_test.dart`
- `rg --line-number --fixed-strings "package:kazumi/utils/proxy_manager.dart" lib/main.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter rewrote `test/platform_boundary_test.dart`. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The fixed-string proxy checks only found boundary-test assertions.

### Step 68: Default Platform Dialog Boundary Cleanup

**Operation:** Added `PlatformDialog` as the default platform dialog facade and moved platform shell/init/About/log/theme callers away from direct `KazumiDialog` calls.

**Why:** The default platform UI still used the legacy dialog helper name, and `dialog_helper.dart` pulled layout breakpoints from `constants.dart`, which is otherwise a legacy player/Bangumi/video constants collection. This kept a small but visible legacy dependency in the platform shell and settings path.

**Feature Goal:** Give the default platform path a platform-named dialog entrypoint and remove the dialog helper's dependency on legacy constants while keeping `KazumiDialog` available for older legacy pages.

**Files Modified:**
- `lib/bean/dialog/dialog_helper.dart`
- `lib/app_widget.dart`
- `lib/pages/init_page.dart`
- `lib/pages/about/about_page.dart`
- `lib/pages/logs/logs_page.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Removed the `package:kazumi/utils/constants.dart` import from `dialog_helper.dart` and replaced the snack-bar breakpoint dependency with a local dialog breakpoint constant.

**Operation:** Added `PlatformDialog` as a compatibility facade over the existing dialog implementation.

**Operation:** Updated default platform callers to use `PlatformDialog` for observer registration, dialogs, dismissals, and toast notifications.

**Operation:** Extended platform boundary tests so default platform dialog callers must use `PlatformDialog`, must not directly call `KazumiDialog.`, and the dialog helper must not import legacy `constants.dart`.

**Design Note:** `KazumiDialog` and its existing route names remain in place for legacy compatibility. This step only moves the default platform path to the platform-named facade.

**Verification Commands:**
- `dart format lib/bean/dialog/dialog_helper.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/bean/dialog/dialog_helper.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number --fixed-strings "KazumiDialog." lib/app_widget.dart lib/pages/init_page.dart lib/pages/about lib/pages/logs lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `rg --line-number --fixed-strings "package:kazumi/utils/constants.dart" lib/bean/dialog/dialog_helper.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter rewrote `lib/pages/about/about_page.dart`. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The fixed-string `KazumiDialog.` and dialog constants checks only found boundary-test assertions.

### Step 69: Platform Dialog Facade Relocation

**Operation:** Moved the `PlatformDialog` facade from the legacy dialog helper file into the platform module directory.

**Why:** Step 68 moved default platform callers to `PlatformDialog`, but those callers still imported `bean/dialog/dialog_helper.dart` directly. That kept the default platform path pointed at a legacy helper file even though the public API had been platformized.

**Feature Goal:** Make default platform dialog callers import `lib/pages/platform/platform_dialog.dart` and keep `bean/dialog/dialog_helper.dart` as the legacy implementation surface behind the facade.

**Files Modified:**
- `lib/pages/platform/platform_dialog.dart`
- `lib/bean/dialog/dialog_helper.dart`
- `lib/app_widget.dart`
- `lib/pages/init_page.dart`
- `lib/pages/about/about_page.dart`
- `lib/pages/logs/logs_page.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added `platform_dialog.dart` with the `PlatformDialog` facade forwarding to the existing legacy dialog implementation.

**Operation:** Removed the duplicate `PlatformDialog` class from `dialog_helper.dart`.

**Operation:** Updated default platform callers to import `package:kazumi/pages/platform/platform_dialog.dart` instead of `package:kazumi/bean/dialog/dialog_helper.dart`.

**Operation:** Extended platform boundary tests so default platform callers must import the platform dialog facade, must not import the legacy dialog helper directly, and `dialog_helper.dart` must not define `PlatformDialog`.

**Design Note:** `platform_dialog.dart` still forwards to `KazumiDialog` and `KazumiDialogObserver` internally. This keeps runtime behavior stable while moving the default platform dependency edge to a platform-owned entrypoint.

**Verification Commands:**
- `dart format lib/pages/platform/platform_dialog.dart lib/bean/dialog/dialog_helper.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_dialog.dart lib/bean/dialog/dialog_helper.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number --fixed-strings "package:kazumi/bean/dialog/dialog_helper.dart" lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `rg --line-number --fixed-strings "class PlatformDialog" lib/bean/dialog/dialog_helper.dart lib/pages/platform/platform_dialog.dart test/platform_boundary_test.dart`
- `rg --line-number --fixed-strings "package:kazumi/pages/platform/platform_dialog.dart" lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter rewrote `lib/pages/about/about_page.dart` and `test/platform_boundary_test.dart`. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. Fixed-string checks confirmed default platform files import the platform dialog facade and only the boundary test references the legacy dialog helper import.

### Step 70: Platform Palette Card Boundary Cleanup

**Operation:** Moved the default theme color swatch UI from the legacy `bean/card` namespace into the platform module.

**Why:** `ThemeSettingsPage` was still importing `package:kazumi/bean/card/palette_card.dart`. The card itself is platform-neutral, but the import kept the default settings path coupled to the legacy card namespace used heavily by old Bangumi/info/search pages.

**Feature Goal:** Keep the default platform theme settings page inside platform-owned UI helpers and reserve `bean/card` for legacy surfaces until those pages are removed or isolated.

**Files Modified:**
- `lib/pages/platform/platform_palette_card.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added `PlatformPaletteCard` under `lib/pages/platform/` using the same color-swatch rendering behavior as the old palette card.

**Operation:** Updated `ThemeSettingsPage` to import `package:kazumi/pages/platform/platform_palette_card.dart` and render `PlatformPaletteCard`.

**Operation:** Replaced the copied `Color.value` conversion with `toARGB32()` so the new platform component does not introduce a deprecated-member analyzer warning.

**Operation:** Extended `platform_boundary_test.dart` so the default theme settings page must use the platform palette card and must not import `bean/card/palette_card.dart`.

**Design Note:** The old `PaletteCard` remains in place for legacy compatibility. This step only changes the default platform settings dependency edge.

**Verification Commands:**
- `dart format lib/pages/platform/platform_palette_card.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_palette_card.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number "package:kazumi/bean/card/palette_card.dart|PaletteCard|PlatformPaletteCard|platform_palette_card" lib/pages/settings/theme_settings_page.dart lib/pages/platform test/platform_boundary_test.dart`

**Result:** Passed. Formatter reported the final palette card file already formatted. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The boundary search confirmed `ThemeSettingsPage` imports the platform palette card and no longer imports the legacy `bean/card/palette_card.dart`.

### Step 71: Platform Native Control Area Boundary Cleanup

**Operation:** Moved the default menu's native window-control padding wrapper from the legacy widget namespace into the platform module.

**Why:** `ScaffoldMenu` still imported `package:kazumi/bean/widget/embedded_native_control_area.dart`, and that legacy widget read `GStorage` from `utils/storage.dart`. This kept the default platform menu coupled to the legacy storage facade even after the platform startup path switched to `PlatformStorage`.

**Feature Goal:** Keep the default platform menu on platform-owned UI and storage helpers while leaving the old `EmbeddedNativeControlArea` available for legacy video/info/player pages.

**Files Modified:**
- `lib/pages/platform/platform_native_control_area.dart`
- `lib/pages/menu/menu.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added `PlatformNativeControlArea` under `lib/pages/platform/`, preserving the macOS top inset behavior for embedded native window controls.

**Operation:** Updated `ScaffoldMenu` to import `package:kazumi/pages/platform/platform_native_control_area.dart` and render `PlatformNativeControlArea`.

**Operation:** Made the platform native-control wrapper read `PlatformSettingKey.showWindowButton` from `PlatformStorage.setting` instead of using legacy `GStorage` / `SettingBoxKey`.

**Operation:** Extended `platform_boundary_test.dart` so the default menu must use the platform native-control wrapper, must not import `bean/widget/embedded_native_control_area.dart`, and the new platform wrapper must not import `utils/storage.dart`.

**Design Note:** The old `EmbeddedNativeControlArea` remains in place for legacy surfaces. This step only changes the default platform menu dependency edge.

**Verification Commands:**
- `dart format lib/pages/platform/platform_native_control_area.dart lib/pages/menu/menu.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_native_control_area.dart lib/pages/menu/menu.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number "package:kazumi/bean/widget/embedded_native_control_area.dart|EmbeddedNativeControlArea|PlatformNativeControlArea|platform_native_control_area|package:kazumi/utils/storage.dart|PlatformStorage|PlatformSettingKey" lib/pages/menu/menu.dart lib/pages/platform/platform_native_control_area.dart test/platform_boundary_test.dart`
- `rg --line-number "package:kazumi/(bean/(dialog|widget|card)|utils/(utils|constants|storage|proxy_manager|pip_utils)\.dart|request/|modules/|pages/(player|video|search|plugin_editor|download|info|collect|history|webdav_editor|popular)|plugins/)" lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/index_module.dart lib/pages/menu/menu.dart lib/pages/router.dart lib/pages/settings/settings_module.dart lib/pages/settings/interface_settings.dart lib/pages/settings/theme_settings_page.dart lib/pages/settings/displaymode_settings.dart lib/pages/settings/platform_settings_page.dart lib/pages/about lib/pages/logs lib/pages/platform lib/bean/settings/theme_provider.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter rewrote `lib/pages/menu/menu.dart` and `test/platform_boundary_test.dart`. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The boundary search confirmed the default menu now imports the platform native-control wrapper, and the remaining default-path legacy import is the intentional `platform_dialog.dart` backend reference to `bean/dialog/dialog_helper.dart`.

### Step 72: Platform App Bar Boundary Cleanup

**Operation:** Added a platform-owned app bar and moved the default About, logs, interface settings, and theme settings pages away from the legacy `SysAppBar`.

**Why:** The four default pages no longer imported legacy widgets directly, but they still imported `package:kazumi/bean/appbar/sys_app_bar.dart`. That legacy app bar internally imported `bean/widget/embedded_native_control_area.dart` and `utils/utils.dart`, so the default platform path still had an indirect dependency edge back into legacy UI and utility helpers.

**Feature Goal:** Keep default platform pages on a platform-owned app bar that uses `PlatformNativeControlArea`, `PlatformStorage`, and `PlatformUtils`, while leaving `SysAppBar` available for legacy player/settings pages.

**Files Modified:**
- `lib/pages/platform/platform_app_bar.dart`
- `lib/pages/about/about_page.dart`
- `lib/pages/logs/logs_page.dart`
- `lib/pages/settings/interface_settings.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added `PlatformAppBar` under `lib/pages/platform/`, preserving the existing desktop close-button behavior, drag behavior, system overlay style, leading back button, and macOS title-bar offset behavior.

**Operation:** Updated default platform About, logs, interface settings, and theme settings pages to import `package:kazumi/pages/platform/platform_app_bar.dart` and render `PlatformAppBar`.

**Operation:** Implemented `PlatformAppBar` with `PlatformNativeControlArea`, `PlatformStorage`, and `PlatformUtils` instead of the legacy embedded native-control widget and `Utils.isDesktop()`.

**Operation:** Extended `platform_boundary_test.dart` so the default pages must import `platform_app_bar.dart`, must not import `bean/appbar/sys_app_bar.dart`, and `PlatformAppBar` must not import `bean/appbar`, `bean/widget/embedded_native_control_area.dart`, `utils/utils.dart`, or `utils/storage.dart`.

**Design Note:** `SysAppBar` remains unchanged for legacy settings and media pages. This step only removes the default platform pages' indirect dependency edge through that legacy app bar.

**Verification Commands:**
- `dart format lib/pages/platform/platform_app_bar.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/interface_settings.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_app_bar.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/interface_settings.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number "bean/appbar/sys_app_bar.dart|SysAppBar|PlatformAppBar|platform_app_bar|embedded_native_control_area|package:kazumi/utils/utils.dart|package:kazumi/utils/storage.dart" lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/interface_settings.dart lib/pages/settings/theme_settings_page.dart lib/pages/platform/platform_app_bar.dart test/platform_boundary_test.dart`
- `rg --line-number "package:kazumi/(bean/(appbar|dialog|widget|card)|utils/(utils|constants|storage|proxy_manager|pip_utils)\.dart|request/|modules/|pages/(player|video|search|plugin_editor|download|info|collect|history|webdav_editor|popular)|plugins/)" lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/index_module.dart lib/pages/menu/menu.dart lib/pages/router.dart lib/pages/settings/settings_module.dart lib/pages/settings/interface_settings.dart lib/pages/settings/theme_settings_page.dart lib/pages/settings/displaymode_settings.dart lib/pages/settings/platform_settings_page.dart lib/pages/about lib/pages/logs lib/pages/platform lib/bean/settings/theme_provider.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter rewrote `lib/pages/about/about_page.dart`. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The final default-path boundary search only found boundary-test assertions plus the intentional `platform_dialog.dart` backend import of `bean/dialog/dialog_helper.dart`.

### Step 73: Independent Platform Dialog Implementation

**Operation:** Replaced the platform dialog facade's legacy forwarding backend with a platform-owned dialog implementation.

**Why:** After Step 72, the remaining default-path legacy dependency was `lib/pages/platform/platform_dialog.dart` importing `package:kazumi/bean/dialog/dialog_helper.dart` and forwarding calls to `KazumiDialog`. That kept default platform dialog behavior tied to legacy names, route markers, and observer types even though callers already imported the platform facade.

**Feature Goal:** Make `PlatformDialog` a self-contained platform dialog helper with platform route names and observer state, while leaving `KazumiDialog` untouched for legacy pages.

**Files Modified:**
- `lib/pages/platform/platform_dialog.dart`
- `lib/pages/about/about_page.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Reimplemented `PlatformDialog` with Flutter native `showDialog`, `ScaffoldMessenger` toast, loading dialog, modal bottom sheet, dismiss, and timed success dialog behavior inside `lib/pages/platform/platform_dialog.dart`.

**Operation:** Added `PlatformDialogObserver` with platform route tracking for `PlatformDialog` and `PlatformBottomSheet`.

**Operation:** Updated default pages that check active dialogs to use `PlatformDialog.observer.hasPlatformDialog` instead of the legacy `hasKazumiDialog` observer property.

**Operation:** Extended `platform_boundary_test.dart` so `platform_dialog.dart` must define `PlatformDialogObserver`, use platform route names, and must not import `bean/dialog/dialog_helper.dart` or reference `KazumiDialog` / `KazumiDialogObserver`.

**Design Note:** `bean/dialog/dialog_helper.dart` remains in place for legacy compatibility. This step only removes the default platform dialog dependency edge.

**Verification Commands:**
- `dart format lib/pages/platform/platform_dialog.dart lib/pages/about/about_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_dialog.dart lib/pages/about/about_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number "package:kazumi/bean/dialog/dialog_helper.dart|KazumiDialog|KazumiDialogObserver|PlatformDialogObserver|hasPlatformDialog|PlatformBottomSheet|PlatformDialog" lib/pages/platform/platform_dialog.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/about/about_page.dart lib/pages/logs/logs_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `rg --line-number "package:kazumi/(bean/(appbar|dialog|widget|card)|utils/(utils|constants|storage|proxy_manager|pip_utils)\.dart|request/|modules/|pages/(player|video|search|plugin_editor|download|info|collect|history|webdav_editor|popular)|plugins/)" lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/index_module.dart lib/pages/menu/menu.dart lib/pages/router.dart lib/pages/settings/settings_module.dart lib/pages/settings/interface_settings.dart lib/pages/settings/theme_settings_page.dart lib/pages/settings/displaymode_settings.dart lib/pages/settings/platform_settings_page.dart lib/pages/about lib/pages/logs lib/pages/platform lib/bean/settings/theme_provider.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter rewrote `lib/pages/about/about_page.dart`. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The final default-path legacy import search now only finds boundary-test assertions; `platform_dialog.dart` no longer imports or references the legacy dialog helper.

### Step 74: Platform Theme Provider Boundary Cleanup

**Operation:** Moved the default platform theme state and theme color list away from the legacy `bean/settings` namespace.

**Why:** After the dialog and app-bar cleanup, the remaining default-path `bean/` imports were `package:kazumi/bean/settings/theme_provider.dart` and `package:kazumi/bean/settings/color_type.dart`. `ThemeProvider` was already mostly platformized internally, but keeping the default app shell and theme settings page pointed at `bean/settings` preserved a legacy dependency edge and made the platform boundary harder to audit.

**Feature Goal:** Give the default app shell a platform-named theme provider and platform-owned theme color catalog while leaving the old `ThemeProvider` and `color_type.dart` available for legacy compatibility.

**Files Modified:**
- `lib/pages/platform/platform_theme_provider.dart`
- `lib/pages/platform/platform_theme_colors.dart`
- `lib/main.dart`
- `lib/app_widget.dart`
- `lib/pages/init_page.dart`
- `lib/pages/settings/theme_settings_page.dart`
- `test/platform_boundary_test.dart`
- `docs/plans/platform-dependency-audit.md`

**Operation:** Added `PlatformThemeProvider` under `lib/pages/platform/`, preserving theme mode, dynamic color, light/dark theme storage, platform font family, and effective dark-mode behavior.

**Operation:** Added `platformColorThemeTypes` under `lib/pages/platform/platform_theme_colors.dart` and wrote the Chinese labels with Unicode escapes to avoid shell encoding corruption.

**Operation:** Updated `main.dart`, `AppWidget`, `InitPage`, and `ThemeSettingsPage` to use `PlatformThemeProvider`.

**Operation:** Updated `ThemeSettingsPage` to use `platformColorThemeTypes` instead of the legacy `colorThemeTypes`.

**Operation:** Extended `platform_boundary_test.dart` so the default platform startup/theme path must use the platform theme provider and color catalog, and must not import `bean/settings/theme_provider.dart` or `bean/settings/color_type.dart`.

**Design Note:** The old `ThemeProvider` and `color_type.dart` remain in place for legacy compatibility. This step only removes the default platform dependency edge.

**Verification Commands:**
- `dart format lib/pages/platform/platform_theme_provider.dart lib/pages/platform/platform_theme_colors.dart lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `dart analyze lib/pages/platform/platform_theme_provider.dart lib/pages/platform/platform_theme_colors.dart lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/settings/theme_settings_page.dart test/platform_boundary_test.dart`
- `flutter test test/platform_boundary_test.dart test/platform_zones_test.dart test/platform_identity_test.dart`
- `rg --line-number "bean/settings/theme_provider.dart|bean/settings/color_type.dart|ThemeProvider|PlatformThemeProvider|colorThemeTypes|platformColorThemeTypes|platform_theme_provider|platform_theme_colors" lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/settings/theme_settings_page.dart lib/pages/platform test/platform_boundary_test.dart`
- `rg --line-number "package:kazumi/(bean/|utils/(utils|constants|storage|proxy_manager|pip_utils)\.dart|request/|modules/|pages/(player|video|search|plugin_editor|download|info|collect|history|webdav_editor|popular)|plugins/)" lib/main.dart lib/app_widget.dart lib/pages/init_page.dart lib/pages/index_module.dart lib/pages/menu/menu.dart lib/pages/router.dart lib/pages/settings/settings_module.dart lib/pages/settings/interface_settings.dart lib/pages/settings/theme_settings_page.dart lib/pages/settings/displaymode_settings.dart lib/pages/settings/platform_settings_page.dart lib/pages/about lib/pages/logs lib/pages/platform lib/utils/platform_storage.dart lib/utils/platform_utils.dart lib/utils/logger.dart test/platform_boundary_test.dart`

**Result:** Passed. Formatter reported the final files already formatted after the label string fix. Targeted analysis reported no issues. Targeted platform tests passed with 21 tests. The final default-path legacy import search only finds boundary-test assertions; default platform startup/theme files no longer import `bean/settings/theme_provider.dart` or `bean/settings/color_type.dart`.

### Step 75: Code Audit Report History

**Operation:** Added saved-report history support to the coding zone.

**Why:** The coding-zone roadmap still listed report history management as a follow-up. The platform could already save Markdown audit reports, but users had no in-app view of recently generated reports after saving snippet or project scans.

**Feature Goal:** Let the programming area show the most recent local Markdown audit reports so saved findings become a visible workflow artifact instead of a one-off file path toast.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_repository.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_zones_test.dart`

**Files Added:**
- `test/platform_code_audit_report_history_test.dart`

**Operation:** Added `CodeAuditSavedReport` and `listCodeAuditReports()` to the audit repository. Reports are read from the existing `code_audit_reports` directory, sorted by modified time descending, and limited to the requested recent count.

**Operation:** Updated `CodingZonePage` to load report history on startup, refresh history after saving snippet or project reports, and render an `审计报告历史` panel with file name, modified time, size, and local path.

**Operation:** Added a repository test that creates two reports, assigns deterministic modified times, and verifies that the newest Markdown report is returned first with file metadata.

**Operation:** Extended the coding-zone widget test so the programming area must expose the report-history panel and empty-state text.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib/pages/platform/platform_code_audit_repository.dart lib/pages/platform/coding_zone_page.dart test/platform_code_audit_report_history_test.dart test/platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_code_audit_repository_test.dart test/platform_code_audit_report_history_test.dart test/platform_zones_test.dart`

**Result:** Passed. Formatter reported 4 files already formatted with 0 changed files. Targeted Flutter tests passed with 11 tests, covering report saving, report history ordering, and the three-zone widget surface including the new report-history entrypoint.

### Step 76: Code Audit Rule Configuration

**Operation:** Added local rule configuration support to the coding zone.

**Why:** The coding-zone roadmap still listed rule configuration as a follow-up. The scanner had a fixed set of deterministic local rules, but users could not choose which risks to include for a specific snippet or project scan.

**Feature Goal:** Let users tune the current audit workspace by enabling or disabling local deterministic rules before running snippet and project scans, while keeping all rules enabled by default for existing behavior.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_code_audit_rules_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added an optional `enabledRuleIds` parameter to `scanCodeSnippet()` and `scanCodeProject()`. When omitted, both scanners still run all local rules. When provided, scans only evaluate matching rule IDs.

**Operation:** Added tests proving that snippet scans and project directory scans can run a selected rule subset.

**Operation:** Added a `规则配置` panel to `CodingZonePage`, backed directly by `localCodeAuditRules`. The panel shows enabled count, severity, and rule suggestions. It keeps at least one rule enabled and immediately refreshes the snippet scan when a rule changes.

**Operation:** Updated the coding-zone widget test to require the rule-configuration entrypoint.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib/pages/platform/platform_code_audit_rules.dart lib/pages/platform/coding_zone_page.dart test/platform_code_audit_rules_test.dart test/platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_code_audit_rules_test.dart test/platform_code_audit_repository_test.dart test/platform_code_audit_report_history_test.dart test/platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/pages/platform/platform_code_audit_rules.dart lib/pages/platform/coding_zone_page.dart test/platform_code_audit_rules_test.dart test/platform_zones_test.dart`

**Result:** Passed after updating the coding-zone widget test to allow rule titles to appear both in configuration and findings. Formatter completed successfully. Targeted Flutter tests passed with 17 tests. Targeted analysis reported no issues.

### Step 77: AI Audit Request Placeholder

**Operation:** Added an AI audit interface placeholder to the coding zone.

**Why:** The coding-zone roadmap still listed an AI audit interface placeholder as a follow-up. The platform already had deterministic local scan findings and Prompt templates, but it lacked a clear handoff artifact for later model integration.

**Feature Goal:** Generate a structured, copyable AI audit request draft from local scan findings, enabled rules, and optional project scan context. This gives users an immediate manual AI-review workflow while keeping the implementation offline and ready for a future real API adapter.

**Files Added:**
- `lib/pages/platform/platform_ai_audit_request.dart`
- `test/platform_ai_audit_request_test.dart`

**Files Modified:**
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `CodeAuditAiRequestDraft` and `buildCodeAuditAiRequestDraft()`. The draft includes a context summary, local rule findings, enabled rule descriptions, optional project scan metadata, and required AI review outputs.

**Operation:** Added a coding-zone `AI 审计接口占位` panel that shows the draft summary, explains that no remote model is called yet, and lets users copy the generated request draft.

**Operation:** Added a unit test for the draft builder and extended the coding-zone widget test to require the placeholder panel and copy action.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib/pages/platform/platform_ai_audit_request.dart lib/pages/platform/coding_zone_page.dart test/platform_ai_audit_request_test.dart test/platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_ai_audit_request_test.dart test/platform_code_audit_rules_test.dart test/platform_code_audit_repository_test.dart test/platform_code_audit_report_history_test.dart test/platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/pages/platform/platform_ai_audit_request.dart lib/pages/platform/coding_zone_page.dart test/platform_ai_audit_request_test.dart test/platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted Flutter tests passed with 18 tests. Targeted analysis reported no issues.

### Step 78: Fix Suggestion Templates

**Operation:** Added fix suggestion templates to the coding zone.

**Why:** The coding-zone roadmap still listed fix suggestion templates as the last stage-4 follow-up. Findings already showed local suggestions inline, but users did not have a structured repair artifact they could copy into an issue, report, PR summary, or local RAG note.

**Feature Goal:** Generate Markdown repair templates from current snippet or project scan findings. Each template should preserve risk location and evidence, then guide the user through minimum repair steps and verification checks.

**Files Added:**
- `lib/pages/platform/platform_fix_suggestion_template.dart`
- `test/platform_fix_suggestion_template_test.dart`

**Files Modified:**
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `CodeAuditFixSuggestionTemplate`, `buildCodeAuditFixSuggestionTemplates()`, and `formatFixSuggestionTemplates()`. Templates are generated from `CodeAuditFinding` data and include risk location, trigger evidence, repair steps, and a verification checklist. When no findings exist, a generic manual-review repair template is generated.

**Operation:** Added a coding-zone `修复建议模板` panel that shows the generated template count, the first priority location, a short description, a Markdown preview, and a `复制修复模板` action.

**Operation:** Added unit tests for finding-based templates and the no-finding fallback template. Extended the coding-zone widget test to require the new panel and copy action.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib/pages/platform/platform_fix_suggestion_template.dart lib/pages/platform/coding_zone_page.dart test/platform_fix_suggestion_template_test.dart test/platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_fix_suggestion_template_test.dart test/platform_ai_audit_request_test.dart test/platform_code_audit_rules_test.dart test/platform_code_audit_repository_test.dart test/platform_code_audit_report_history_test.dart test/platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib/pages/platform/platform_fix_suggestion_template.dart lib/pages/platform/coding_zone_page.dart test/platform_fix_suggestion_template_test.dart test/platform_zones_test.dart`

**Result:** Passed. Formatter reported 4 files already formatted with 0 changed files. Targeted Flutter tests passed with 20 tests. Targeted analysis reported no issues.

### Step 79: Windows Temp Stream Prefix Branding

**Operation:** Replaced the Windows external-player temporary stream file prefix with the platform identity.

**Why:** `windows/runner/external_player_utils.cpp` still generated temporary M3U8 files with the old `kazumi_stream_` prefix. This is a small but visible/native filesystem branding leak inside the Windows integration surface.

**Feature Goal:** Continue phase-5 brand/package cleanup by removing an old Kazumi runtime artifact name without touching larger native contracts such as MethodChannel names, package IDs, or bundle IDs.

**Files Modified:**
- `windows/runner/external_player_utils.cpp`
- `test/platform_boundary_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Changed the generated temporary stream prefix from `kazumi_stream_` to `everyone_is_programmer_stream_`.

**Operation:** Added a boundary test requiring the Windows external-player helper to contain the platform prefix and not contain the old `kazumi_stream_` prefix.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format test/platform_boundary_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_boundary_test.dart`

**Result:** Passed. Formatter reported the boundary test was already formatted. Targeted boundary tests passed with 12 tests.

### Step 80: Windows Runtime Identity Boundary Guard

**Operation:** Added boundary coverage for Windows native runtime identity.

**Why:** Several Windows native surfaces had already been moved to the platform identity, including the window title, single-instance mutex, shortcut AUMID suffix, release executable name, and version resource strings. Without explicit boundary coverage, future native edits could accidentally reintroduce old Kazumi identifiers.

**Feature Goal:** Continue phase-5 brand/package cleanup by guarding the Windows runtime identity that is already platformized, while leaving larger native contracts such as MethodChannel names, package IDs, and bundle IDs for separate staged work.

**Files Modified:**
- `test/platform_boundary_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added a boundary test requiring:
- `windows/runner/main.cpp` to keep `everyone_is_programmer.win.mutex`.
- `windows/runner/shortcut_utils.cpp` to keep the `!everyone_is_programmer` AUMID suffix.
- `windows/runner/Runner.rc` to keep platform company/internal/original-filename metadata.
- The same files to avoid old `kazumi` runtime identifiers in those guarded fields.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format test/platform_boundary_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test/platform_boundary_test.dart`

**Result:** Passed. Formatter reported the boundary test was already formatted. Targeted boundary tests passed with 13 tests.

### Step 81: Updater Fallback Installer Filename Branding

**Operation:** Replaced the updater fallback installer filename prefix with the platform identity.

**Why:** `lib/utils/auto_updater.dart` still returned `Kazumi-$version$extension` when a download URL did not expose a concrete file name. Even though the legacy updater is not initialized by the default platform startup, this fallback could still create a visible stale installer filename if the updater path is reused later.

**Feature Goal:** Continue phase-5 brand/package cleanup with a narrow filesystem-facing change, while leaving larger native contracts such as MethodChannel names, package IDs, and bundle IDs for separate staged work.

**Files Modified:**
- `lib/utils/auto_updater.dart`
- `test/platform_boundary_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Changed the fallback installer filename from `Kazumi-$version$extension` to `everyone_is_programmer-$version$extension`.

**Operation:** Added a boundary test requiring the updater source to keep the `everyone_is_programmer-` fallback prefix and reject the old `Kazumi-` fallback prefix.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\utils\auto_updater.dart test\platform_boundary_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_boundary_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\utils\auto_updater.dart test\platform_boundary_test.dart`

**Result:** Passed. Formatter completed successfully and changed `test/platform_boundary_test.dart`. Targeted boundary tests passed with 14 tests. Targeted analysis reported no issues.

### Step 82: Android Background Download Channel Branding

**Operation:** Replaced the Android background download notification channel id with the platform identity.

**Why:** `lib/utils/background_download_service.dart` still initialized the foreground-service notification channel with `kazumi_download_channel`. Even though this legacy download service is not part of the default platform startup path, Android can persist notification channel ids once created, so keeping the stale id would leave a visible runtime artifact if the service is reused.

**Feature Goal:** Continue phase-5 brand/package cleanup with a narrow Android runtime identifier change, while leaving larger native contracts such as MethodChannel names, package IDs, and bundle IDs for separate staged work.

**Files Modified:**
- `lib/utils/background_download_service.dart`
- `test/platform_boundary_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Changed the foreground-service notification channel id from `kazumi_download_channel` to `everyone_is_programmer_download_channel`.

**Operation:** Added a boundary test requiring the background download service source to keep the platform channel id and reject the old `kazumi_download_channel` id.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\utils\background_download_service.dart test\platform_boundary_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_boundary_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\utils\background_download_service.dart test\platform_boundary_test.dart`

**Result:** Passed. Formatter completed successfully and changed `lib/utils/background_download_service.dart` plus `test/platform_boundary_test.dart`. Targeted boundary tests passed with 15 tests. Targeted analysis reported no issues.

### Step 83: Audio Service Runtime Identity Branding

**Operation:** Replaced audio service runtime identifiers with the platform identity.

**Why:** `lib/utils/audio_controller.dart` still registered Linux MPRIS and Android audio notification identifiers with `io.github.Predidit.Kazumi.channel.audio` and `Kazumi Playback`. The default platform startup does not initialize the legacy player runtime, but these identifiers are visible when the audio service is reused and can persist in desktop/media-control or Android notification surfaces.

**Feature Goal:** Continue phase-5 brand/package cleanup by removing old Kazumi playback identifiers from a contained runtime surface, while leaving broader package names, MethodChannel names, and bundle ids for separate staged work.

**Files Modified:**
- `lib/utils/audio_controller.dart`
- `test/platform_boundary_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Changed the Linux MPRIS D-Bus name from `io.github.Predidit.Kazumi.channel.audio` to `io.github.everyone_is_programmer.channel.audio`.

**Operation:** Changed the Linux MPRIS identity and Android audio notification channel name from `Kazumi Playback` to `Everyone Is Programmer Playback`.

**Operation:** Changed the Android audio notification channel id to `io.github.everyone_is_programmer.channel.audio`.

**Operation:** Added a boundary test requiring the audio controller source to keep the platform audio runtime identifiers and reject the old Kazumi playback identifiers.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\utils\audio_controller.dart test\platform_boundary_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_boundary_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\utils\audio_controller.dart test\platform_boundary_test.dart`

**Result:** Passed. Formatter completed successfully and changed `lib/utils/audio_controller.dart` plus `test/platform_boundary_test.dart`. Targeted boundary tests passed with 16 tests. Targeted analysis reported no issues.

### Step 84: Local RAG Retrieval Plan Preview

**Operation:** Added a visible retrieval-plan preview to the local RAG learning surface.

**Why:** The RAG MVP already had keyword search, document chunking, retrieved context, and answer drafts. The phase-3 roadmap still called for stronger RAG mechanics such as BM25/Embedding hybrid retrieval and reranking. Before wiring remote embeddings, users needed a clear local planning layer that explains how a query will be interpreted, how many candidates are considered, and how much evidence is retained.

**Feature Goal:** Add a deterministic retrieval-plan model and UI preview so the learning zone exposes query intent, tokenization, retrieval strategy, and evidence budget as a bridge toward later hybrid retrieval.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_rag_catalog_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `LocalRagRetrievalPlan` and `buildLocalRagRetrievalPlan()`. The plan normalizes query tokens, labels simple intents such as retrieval-architecture learning, code-audit learning, toolchain learning, and general learning Q&A, then emits candidate/context limits plus an evidence-budget summary.

**Operation:** Added a `RAG 检索计划` panel in `RagLibraryPreview` before the answer draft. The panel shows the inferred intent, retrieval strategy, candidate count, context count, and up to five query tokens.

**Operation:** Added unit tests for hybrid-search retrieval planning and empty-query planning. Extended the learning-zone widget test to require the retrieval-plan panel, intent label, and evidence-budget chips.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter reported all four files already formatted. Targeted RAG catalog and zone widget tests passed with 20 tests. Targeted analysis reported no issues.

### Step 85: Local RAG Study Note Export

**Operation:** Added a copyable Markdown study-note export for local RAG results.

**Why:** Step 84 made the retrieval plan visible, and the RAG preview already generated answer drafts with cited context. Users still had to manually combine the plan, answer, and evidence if they wanted to save a learning note, paste it into a project retrospective, or re-import it as local RAG material.

**Feature Goal:** Turn a RAG query session into a reusable Markdown artifact that combines the retrieval plan, generated answer draft, and scored evidence snippets.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_rag_catalog_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `buildLocalRagStudyNote()`. The function emits a Markdown note with sections for the question, retrieval plan, answer draft, and cited evidence entries.

**Operation:** Added a `复制 RAG 学习笔记` action to the RAG answer-draft panel. The action copies the generated Markdown note to the clipboard and shows a confirmation snackbar.

**Operation:** Rebuilt `test/platform_rag_catalog_test.dart` as a clean UTF-8/ASCII-focused test file after historical mojibake strings made the newly added test block fragile. The rebuilt test still covers keyword search, default search results, source packs, imported documents, chunking, evidence selection, answer drafts, retrieval plans, and the new study-note export.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog and zone widget tests passed with 21 tests. Targeted analysis reported no issues.

### Step 86: Local RAG Study Note Persistence

**Operation:** Added one-click persistence for generated local RAG study notes.

**Why:** Step 85 made the retrieval plan, answer draft, and cited evidence exportable as Markdown, but users still had to manually paste or re-import that note if they wanted it to become reusable RAG material. The learning flow needed a direct way to turn a solved query into durable local knowledge.

**Feature Goal:** Let a RAG answer session save its generated study note back into the local RAG library, refresh the preview query to the saved note title, and make the new note immediately searchable in follow-up retrieval.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_rag_catalog_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `buildLocalRagStudyNoteDocument()` to wrap `buildLocalRagStudyNote()` output into a `LocalRagDocument` with a generated title, source, summary, full Markdown content, and RAG-oriented tags.

**Operation:** Added a `沉淀到 RAG 资料库` action beside the existing copy action in the answer-draft panel. The action saves the generated document through `PlatformRagRepository.saveDocuments()`, updates the query field to the saved note title, and shows a confirmation snackbar.

**Operation:** Added catalog coverage proving generated notes can be converted into searchable local documents. Added a zone widget test proving the preview can save a study note into local storage and refresh the imported-document count.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 25 tests. Targeted analysis reported no issues.

### Step 87: Local RAG Study Note Duplicate Guard

**Operation:** Added duplicate protection for one-click local RAG study-note persistence.

**Why:** Step 86 let a generated study note be saved back into the local RAG library, but repeated clicks on the same answer session could create multiple near-identical imported documents. That would pollute subsequent retrieval results and make the imported-document list harder to scan.

**Feature Goal:** Keep the study-note persistence flow idempotent for the current RAG answer session: save the note once, then focus the existing saved note on later clicks instead of appending duplicates.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_findExistingStudyNote()` to detect an existing generated study note by source plus the generated/current title.

**Operation:** Added `_focusDocument()` so both new and existing generated notes update the preview query and text selection consistently.

**Operation:** Updated `_saveStudyNote()` to insert a new generated note only when no matching note exists. Duplicate saves now move the existing note to the top, focus it, persist the reordered library, and show a duplicate-focused snackbar.

**Operation:** Extended the RAG preview widget test to click the save action twice, require the saved-document count to remain at one, and verify the duplicate-focused snackbar.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 25 tests. Targeted analysis reported no issues.

### Step 88: Local RAG Study Note Title Idempotence

**Operation:** Made generated local RAG study-note document titles idempotent.

**Why:** Step 86 and Step 87 made generated study notes persistent and duplicate-safe. After a note is saved, the preview query is focused to the saved note title. If the user continues from that state, the title builder could produce nested names such as `RAG 学习笔记：RAG 学习笔记：...`, making saved notes harder to scan and weakening duplicate detection.

**Feature Goal:** Keep study-note document titles stable when the current query is already a generated study-note title.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_buildLocalRagStudyNoteTitle()` so blank queries still become `RAG 学习笔记`, normal queries become `RAG 学习笔记：{query}`, and existing generated note titles are reused unchanged.

**Operation:** Added catalog coverage requiring a query that already starts with `RAG 学习笔记：` to keep its exact title and avoid a nested `RAG 学习笔记：RAG 学习笔记` prefix.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 26 tests. Targeted analysis reported no issues.

### Step 89: Local RAG Document Normalization

**Operation:** Added normalization for persisted local RAG documents.

**Why:** The local RAG library now accepts manual imports and generated study notes. Without a shared cleanup boundary, historical Hive values or future import paths could retain leading/trailing spaces, blank sources, empty tags, duplicate tags, or empty records. That makes the imported list harder to scan and can weaken retrieval quality.

**Feature Goal:** Keep local RAG documents clean at the model and repository boundaries before they participate in retrieval or get written back to `platformRagDocuments`.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/platform_rag_repository.dart`
- `test/platform_rag_repository_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `LocalRagDocument.normalized()` to trim title, source, summary, content, and tags; default blank sources to `用户导入`; remove blank/duplicate tags; and fall back to `本地资料` when no tags remain.

**Operation:** Updated `LocalRagDocument.fromJson()` and `toJson()` so historical and newly serialized documents both pass through the normalization rules.

**Operation:** Updated `PlatformRagRepository.saveDocuments()` to normalize documents and filter out empty-title or empty-content records before writing to `platformRagDocuments`.

**Operation:** Added repository tests covering field normalization, duplicate tag cleanup, default source fallback, serialization cleanup, and save-time filtering of invalid documents.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\platform_rag_repository.dart test\platform_rag_repository_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\platform_rag_repository.dart test\platform_rag_repository_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 28 tests. Targeted analysis reported no issues.

### Step 90: Local RAG Manual Import Duplicate Guard

**Operation:** Added duplicate protection for manually imported local RAG documents.

**Why:** Generated study notes already had duplicate protection, but the manual `添加资料` flow still inserted every submitted document directly. Re-importing the same title/source/content could create duplicate local documents, pollute later retrieval, and make the imported library harder to scan.

**Feature Goal:** Make manual local RAG imports idempotent for the same normalized document while preserving the existing study-note duplicate behavior.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_upsertImportedDocument()` so imported documents are normalized, checked against existing documents, inserted only when new, and focused when an existing match is found.

**Operation:** Replaced the study-note-only lookup with `_findExistingDocument()`. Manual imports match by normalized source, title, and content; generated study notes match by normalized source and title so regenerated note content does not break the Step 87 duplicate guard.

**Operation:** Added duplicate feedback for manual imports with `RAG 资料已存在，已聚焦到资料库`.

**Operation:** Added a widget test that imports the same manual RAG document twice, verifies storage still contains one normalized document, and checks the duplicate-focused snackbar.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 29 tests. Targeted analysis reported no issues.

### Step 91: Local RAG Delete Undo

**Operation:** Added undo support for deleting imported local RAG documents.

**Why:** The local RAG library now supports normalization, duplicate-safe imports, and generated study-note persistence. Deletion was still immediate and irreversible from the UI, which made accidental taps risky when users are curating their local knowledge base.

**Feature Goal:** Let users recover an accidentally deleted local RAG document from the deletion snackbar while keeping the persisted `platformRagDocuments` list in sync.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_removeDocument()` to remember the removed document index, persist the deletion, and show a snackbar with the deleted title plus a `撤销` action.

**Operation:** Added `_restoreRemovedDocument()` to reinsert the removed document at its original position when possible, focus the restored document title in the query field, and persist the restored list.

**Operation:** Added a widget test that imports a manual RAG document, deletes it, verifies storage becomes empty, taps `撤销`, and verifies the document is restored to local storage and visible in the preview.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 92: Local RAG Imported Metadata Preview

**Operation:** Added source and tag metadata to imported local RAG document tiles.

**Why:** Imported documents already carried source and tags for retrieval, normalization, and persistence, but the imported-document list only showed title and summary. Users could not quickly scan where a document came from or which labels would affect later retrieval.

**Feature Goal:** Make the local RAG library easier to curate by showing each imported document's source and top tags directly in the imported list.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_ImportedDocumentTile` so its subtitle includes the summary followed by compact chips for the document source and up to four tags.

**Operation:** Extended the RAG preview widget test helper to support custom source and tags when adding manual RAG documents.

**Operation:** Extended the duplicate manual import widget test to verify a custom imported source and tags are persisted and visible in the imported-document list.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 93: Local RAG Imported Tag Overflow Indicator

**Operation:** Added an overflow indicator for imported local RAG document tags.

**Why:** Step 92 made imported document source and tags visible in the local RAG library, but the tile intentionally showed only the first four tags to keep the list compact. When a document had more than four tags, the extra metadata disappeared silently, which made the list harder to interpret during curation.

**Feature Goal:** Keep imported document tiles compact while still signaling when a document has additional tags beyond the visible set.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_ImportedDocumentTile` to calculate visible tags and hidden tag count, render the first four tags, and append a `+N` chip when more tags are available.

**Operation:** Extended the duplicate manual import widget test to import six custom tags, verify the full tag list is persisted, require the first four visible chips, and require a `+2` overflow chip.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 94: Local RAG Imported Document Focus

**Operation:** Added click-to-focus behavior for imported local RAG document tiles.

**Why:** The imported-document list now shows source, tags, overflow counts, duplicate protection, and delete undo. However, clicking an imported document did not do anything, so users still had to manually type or copy its title to revisit the document as the active retrieval query.

**Feature Goal:** Let users switch the local RAG query context by clicking an imported document in the local library list.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_focusImportedDocument()` to focus an imported document title in the query field without mutating the persisted document list.

**Operation:** Added an `onFocus` callback to `_ImportedDocumentTile` and wired it to `ListTile.onTap` while keeping the delete icon action unchanged.

**Operation:** Extended the RAG preview widget test to change the query to an unrelated value, tap an imported document tile, and verify the query field returns to the imported document title.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 95: Local RAG Imported Tag Overflow Tooltip

**Operation:** Added a tooltip for imported local RAG document tag overflow chips.

**Why:** Step 93 made hidden tags visible as a `+N` count, but the user still could not inspect which tags were hidden without opening or re-importing the document. That kept the imported library compact, but made curation less transparent for heavily tagged documents.

**Feature Goal:** Keep imported document tiles compact while letting users inspect the folded tags behind the overflow count.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_ImportedDocumentTile` to collect hidden tags and wrap the `+N` chip in a `Tooltip` whose message lists the folded tag names.

**Operation:** Extended the duplicate manual import widget test to require the overflow tooltip for the hidden `ExtraTag` and `DebugTag` values.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 96: Local RAG Imported Document Markdown Copy

**Operation:** Added Markdown copy support for imported local RAG documents.

**Why:** Imported documents can now be normalized, deduplicated, restored, focused, and inspected in the local RAG library, but users still lacked a quick way to move a curated document back into notes, prompts, or external knowledge bases. Copying a structured Markdown card makes the imported library more useful as a reusable study artifact store.

**Feature Goal:** Let users copy an imported local RAG document as a Markdown card containing title, source, tags, summary, and content without changing the persisted library.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_copyImportedDocument()` and `_buildImportedDocumentMarkdown()` to normalize the selected document, write a Markdown card to the clipboard, and show a snackbar confirmation.

**Operation:** Added a copy icon button beside the delete action in `_ImportedDocumentTile`, keeping tile tap focused on query selection and delete unchanged.

**Operation:** Extended the duplicate manual import widget test with a clipboard platform-channel mock, requiring the copy action to emit a snackbar and include title, source, tags, and content in the copied Markdown.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 97: Local RAG Search Result Markdown Copy

**Operation:** Added Markdown copy support for local RAG search result excerpts.

**Why:** Step 96 made curated imported documents reusable as Markdown cards, but search results still had to be manually selected when a user wanted to carry one piece of retrieval evidence into notes, a prompt, or an audit explanation. A copied evidence card preserves the score, source, matched fields, matched tags, excerpt, and original chunk text in one small artifact.

**Feature Goal:** Let users copy a single local RAG search result as a Markdown evidence card without changing the current query or imported document library.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_buildSearchResultMarkdown()` to format a retrieved result with title, source, score, chunk label, matched fields, matched tags, summary, excerpt, and original chunk text.

**Operation:** Added a `复制片段` icon button to `_RagSearchResultTile` that writes the evidence card to the clipboard and shows a snackbar confirmation.

**Operation:** Extended the RAG preview widget test clipboard mock to copy a search result excerpt and assert the Markdown evidence card contains the imported document title, source, evidence heading, and content.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 98: Local RAG Retrieval Plan Markdown Copy

**Operation:** Added Markdown copy support for the local RAG retrieval plan.

**Why:** The RAG surface can now copy study notes, imported document cards, and individual retrieval evidence cards, but the retrieval plan itself still had to be manually recreated when users wanted to explain why a query used a specific intent, strategy, token set, candidate count, and evidence budget. Making the plan copyable closes that explanatory gap.

**Feature Goal:** Let users copy the current local RAG retrieval plan as a compact Markdown card without changing the query, answer draft, search results, or imported document library.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_buildRetrievalPlanMarkdown()` to format the query, inferred intent, retrieval strategy, candidate count, context count, evidence budget, and query tokens.

**Operation:** Added a `复制检索计划` icon button to `_RagRetrievalPlanPanel` that writes the Markdown plan to the clipboard and shows a snackbar confirmation.

**Operation:** Extended the RAG preview widget clipboard test to copy the generated retrieval plan and assert that the Markdown contains the query, intent, strategy, and keyword sections before continuing through document and excerpt copy coverage.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 99: Local RAG Answer Draft Markdown Copy

**Operation:** Added lightweight Markdown copy support for the local RAG answer draft.

**Why:** The RAG answer panel already supported copying the full study note, which includes the retrieval plan, answer draft, and cited evidence. That is useful for archival notes, but too heavy when users only need the generated answer and a short citation summary for a prompt, comment, or quick learning note.

**Feature Goal:** Let users copy the current RAG answer draft as a compact Markdown card without changing the query, retrieval plan, search results, generated study note, or imported document library.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_buildAnswerDraftMarkdown()` to format the question, answer text, citation count, and citation summaries from `LocalRagAnswerDraft`.

**Operation:** Added a `复制回答草稿` action to `_RagAnswerDraftPanel`, keeping the existing `沉淀到 RAG 资料库` and `复制 RAG 学习笔记` actions unchanged.

**Operation:** Extended the RAG preview clipboard widget test to copy the answer draft and assert the Markdown contains the question, answer section, and citation summary section before continuing through plan, document, and excerpt copy coverage.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 100: Local RAG Query Token Deduplication

**Operation:** Added deduplication for normalized local RAG query tokens.

**Why:** Local RAG search and retrieval planning both derive their behavior from normalized query tokens. Repeating the same token, such as `BM25 BM25`, previously caused the same token to be scored more than once and made the generated retrieval plan show duplicated keywords. That could exaggerate ranking signals without adding new learning intent.

**Feature Goal:** Keep local RAG scoring and retrieval-plan keywords stable when users repeat the same query term by accident.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to preserve first-seen token order while filtering duplicate normalized tokens before scoring, retrieval planning, answer drafting, and study-note generation consume them.

**Operation:** Added catalog coverage requiring repeated `BM25` query tokens to produce the same top search score as a single `BM25` query and requiring repeated plan tokens to collapse to `['bm25', 'embedding']`.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 31 tests. Targeted analysis reported no issues.

### Step 101: Local RAG Punctuation Token Boundaries

**Operation:** Added common punctuation separators to local RAG query tokenization.

**Why:** Step 100 deduplicated repeated query tokens, but `_queryTokens()` still only split on whitespace. Queries such as `BM25, Embedding` or `BM25、Embedding` could be treated as one combined token, weakening search, retrieval planning, answer drafting, and study-note generation for natural user input.

**Feature Goal:** Let local RAG treat common English and Chinese punctuation separators as query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on whitespace, English comma, Chinese comma, Chinese enumeration comma, English semicolon, and Chinese semicolon before filtering blanks and deduplicating tokens.

**Operation:** Added catalog coverage requiring a mixed punctuation query like `BM25, Embedding、BM25；Embedding` to retrieve BM25/Embedding material and collapse the retrieval-plan tokens to `['bm25', 'embedding']`.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 32 tests. Targeted analysis reported no issues.

### Step 102: Local RAG Technical Separator Token Boundaries

**Operation:** Added slash and pipe separators to local RAG query tokenization.

**Why:** Step 101 handled common prose punctuation, but technical learning queries often use compact separators such as `BM25/Embedding` or `BM25|Embedding|RAG`. Treating those as one token weakens retrieval and plan generation for common programmer shorthand.

**Feature Goal:** Let local RAG treat slash and pipe characters as query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `/` and `|` in addition to whitespace, comma, enumeration comma, and semicolon separators.

**Operation:** Added catalog coverage requiring `BM25/Embedding|RAG` to produce the retrieval-plan tokens `['bm25', 'embedding', 'rag']` and retrieve results matching each of those tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 33 tests. Targeted analysis reported no issues.

### Step 103: Local RAG Non-Positive Limit Guard

**Operation:** Added an explicit guard for non-positive local RAG search limits.

**Why:** `searchLocalRagDocuments()` accepted a caller-provided `limit`, but the boundary behavior for zero or negative limits was implicit through `take(limit)`. Making the API return an empty result set for `limit <= 0` lets callers intentionally disable retrieval or clamp candidate windows without relying on iterable implementation details.

**Feature Goal:** Make local RAG candidate limiting predictable and covered by regression tests.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added an early `limit <= 0` return in `searchLocalRagDocuments()` before tokenization and candidate scoring.

**Operation:** Added catalog coverage for zero and negative limits, including an empty-query negative-limit case.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 34 tests. Targeted analysis reported no issues.

### Step 104: Local RAG Retrieval Plan Limit Clamping

**Operation:** Clamped local RAG retrieval-plan candidate and context limits to zero when callers pass negative values.

**Why:** Step 103 made `searchLocalRagDocuments()` return an empty result set for non-positive limits, but retrieval plans could still render negative candidate/context budgets. Those values are shown in plan chips, Markdown cards, and study notes, so the plan layer should expose predictable non-negative counts.

**Feature Goal:** Keep local RAG retrieval plans and exported notes free of negative evidence-budget counts while preserving existing positive/default limit behavior.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added normalized candidate/context limit values inside `buildLocalRagRetrievalPlan()` and used them for empty-query plans, populated plans, and evidence-budget text.

**Operation:** Added catalog coverage for negative candidate/context limits on both non-empty and empty retrieval-plan paths.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 35 tests. Targeted analysis reported no issues.

### Step 105: Local RAG Zero Context Budget Answer

**Operation:** Added an explicit answer-draft message for non-empty queries when the local RAG context limit is zero or negative.

**Why:** The search layer now treats non-positive limits as empty results, but answer drafts previously reused the generic no-hit message. That made an intentionally disabled context budget look like the local library had no relevant material.

**Feature Goal:** Make answer drafts distinguish between “retrieval skipped by zero context budget” and “retrieval ran but found no matching local material.”

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added an early `contextLimit <= 0` branch in `buildLocalRagAnswer()` after empty-query handling and before search execution.

**Operation:** Added catalog coverage requiring zero context budgets to preserve the query, return no contexts, and explain that local retrieval was skipped.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 36 tests. Targeted analysis reported no issues.

### Step 106: Local RAG Title Separator Token Boundaries

**Operation:** Added English and Chinese colon separators to local RAG query tokenization.

**Why:** Saved RAG study-note titles use a Chinese colon, such as `RAG 学习笔记：BM25 Embedding`, and users may also type compact technical titles like `BM25:Embedding`. Without colon token boundaries, title prefixes and technical keywords can be treated as combined tokens, weakening follow-up retrieval from saved notes.

**Feature Goal:** Let local RAG treat title-style separators as query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `:` and `：` in addition to whitespace, comma, enumeration comma, semicolon, slash, and pipe separators.

**Operation:** Added catalog coverage requiring `RAG 学习笔记：BM25:Embedding` to produce the retrieval-plan tokens `['rag', '学习笔记', 'bm25', 'embedding']` and retrieve results matching BM25/Embedding tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 37 tests. Targeted analysis reported no issues.

### Step 107: Local RAG Plus Separator Token Boundaries

**Operation:** Added plus-sign separators to local RAG query tokenization.

**Why:** Technical learning queries often use compact plus notation such as `BM25+Embedding+RAG` to express combined retrieval strategies. Without treating `+` as a token boundary, the query can collapse into one combined token and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat plus signs as technical query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `+` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, and pipe separators.

**Operation:** Added catalog coverage requiring `BM25+Embedding+RAG` to produce the retrieval-plan tokens `['bm25', 'embedding', 'rag']` and retrieve results matching BM25/Embedding/RAG tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 38 tests. Targeted analysis reported no issues.

### Step 108: Local RAG Hyphen Separator Token Boundaries

**Operation:** Added hyphen separators to local RAG query tokenization.

**Why:** Technical learning queries often use compact hyphen notation such as `BM25-Embedding-RAG` in titles, filenames, and shorthand notes. Without treating `-` as a token boundary, the query can collapse into one combined token and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat hyphens as technical query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `-` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, and plus separators.

**Operation:** Added catalog coverage requiring `BM25-Embedding-RAG` to produce the retrieval-plan tokens `['bm25', 'embedding', 'rag']` and retrieve results matching BM25/Embedding/RAG tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 39 tests. Targeted analysis reported no issues.

### Step 109: Local RAG Ampersand Separator Token Boundaries

**Operation:** Added ampersand separators to local RAG query tokenization.

**Why:** Technical learning notes and shorthand queries often use compact ampersand notation such as `BM25&Embedding&RAG` to express combined retrieval strategies. Without treating `&` as a token boundary, the query can collapse into one combined token and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat ampersands as technical query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `&` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, plus, and hyphen separators.

**Operation:** Added catalog coverage requiring `BM25&Embedding&RAG` to produce the retrieval-plan tokens `['bm25', 'embedding', 'rag']` and retrieve results matching BM25/Embedding/RAG tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 40 tests. Targeted analysis reported no issues.

### Step 110: Local RAG Parenthesis Separator Token Boundaries

**Operation:** Added half-width and full-width parenthesis separators to local RAG query tokenization.

**Why:** Learning note titles and compact technical queries often wrap keywords in parentheses, such as `RAG(BM25)Embedding` or `RAG（BM25）Embedding`. Without treating parentheses as token boundaries, title context and technical keywords can be merged into combined tokens and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat English and Chinese parentheses as title-style query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `(`, `)`, `（`, and `）` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, plus, hyphen, and ampersand separators.

**Operation:** Added catalog coverage requiring `RAG(BM25)Embedding` and `RAG（BM25）Embedding` to produce the retrieval-plan tokens `['rag', 'bm25', 'embedding']` and retrieve results matching BM25/Embedding/RAG tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 41 tests. Targeted analysis reported no issues.

### Step 111: Local RAG Bracket Separator Token Boundaries

**Operation:** Added half-width, full-width, and Chinese label bracket separators to local RAG query tokenization.

**Why:** Markdown notes and Chinese learning titles often wrap keywords in brackets, such as `[BM25]Embedding` or `【RAG】BM25`. Without treating those brackets as token boundaries, label context and technical keywords can be merged into combined tokens and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat bracket-style labels as query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `[`, `]`, `［`, `］`, `【`, and `】` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, plus, hyphen, ampersand, and parenthesis separators.

**Operation:** Added catalog coverage requiring `[BM25]Embedding` to produce the retrieval-plan tokens `['bm25', 'embedding']`, requiring `【RAG】BM25` to produce `['rag', 'bm25']`, and requiring bracketed queries to retrieve matching BM25/Embedding material.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 42 tests. Targeted analysis reported no issues.

### Step 112: Local RAG Quote Angle Separator Token Boundaries

**Operation:** Added angle-bracket and Chinese book-title quote separators to local RAG query tokenization.

**Why:** Learning notes and copied citations often wrap keywords in angle brackets or Chinese book-title quotes, such as `<RAG>BM25` or `《BM25》Embedding`. Without treating those wrappers as token boundaries, title context and technical keywords can be merged into combined tokens and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat citation-style wrappers as query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `<`, `>`, `《`, and `》` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, plus, hyphen, ampersand, parenthesis, and bracket separators.

**Operation:** Added catalog coverage requiring `《BM25》Embedding` to produce the retrieval-plan tokens `['bm25', 'embedding']`, requiring `<RAG>BM25` to produce `['rag', 'bm25']`, and requiring quote-wrapped queries to retrieve matching BM25/Embedding material.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 43 tests. Targeted analysis reported no issues.

### Step 113: Local RAG Underscore Separator Token Boundaries

**Operation:** Added underscore separators to local RAG query tokenization.

**Why:** Programmer notes, filenames, and copied snippets often use underscores to join technical keywords, such as `BM25_Embedding_RAG`. Without treating `_` as a token boundary, filename-style queries can collapse into one combined token and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat underscores as technical/file-name query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `_` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, plus, hyphen, ampersand, parenthesis, bracket, angle-bracket, and Chinese book-title quote separators.

**Operation:** Added catalog coverage requiring `BM25_Embedding_RAG` to produce the retrieval-plan tokens `['bm25', 'embedding', 'rag']` and retrieve results matching BM25/Embedding/RAG tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 44 tests. Targeted analysis reported no issues.

### Step 114: Local RAG Dot Separator Token Boundaries

**Operation:** Added dot separators to local RAG query tokenization.

**Why:** Programmer notes, filenames, package-like titles, and copied snippets often use dots to join technical keywords, such as `BM25.Embedding.RAG`. Without treating `.` as a token boundary, filename-style queries can collapse into one combined token and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat dots as technical/file-name query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `.` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, plus, hyphen, ampersand, underscore, parenthesis, bracket, angle-bracket, and Chinese book-title quote separators.

**Operation:** Added catalog coverage requiring `BM25.Embedding.RAG` to produce the retrieval-plan tokens `['bm25', 'embedding', 'rag']` and retrieve results matching BM25/Embedding/RAG tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 45 tests. Targeted analysis reported no issues.

### Step 115: Local RAG Flow Arrow Separator Token Boundaries

**Operation:** Added equals-sign and Unicode arrow separators to local RAG query tokenization.

**Why:** Prompt notes and learning flow sketches often use arrows such as `BM25=>Embedding→RAG` or `BM25⇒Embedding` to describe retrieval pipelines. Without treating those flow markers as token boundaries, compact prompt notes can collapse into combined tokens and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat flow arrows as query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `=`, `→`, and `⇒` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, plus, hyphen, ampersand, underscore, dot, parenthesis, bracket, angle-bracket, and Chinese book-title quote separators.

**Operation:** Added catalog coverage requiring `BM25=>Embedding→RAG` to produce the retrieval-plan tokens `['bm25', 'embedding', 'rag']`, requiring `BM25⇒Embedding` to produce `['bm25', 'embedding']`, and requiring flow-arrow queries to retrieve matching BM25/Embedding/RAG material.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 46 tests. Targeted analysis reported no issues.

### Step 116: Local RAG Backslash Separator Token Boundaries

**Operation:** Added backslash separators to local RAG query tokenization.

**Why:** Programmer notes and saved paths on Windows often use backslashes to join technical keywords, such as `RAG\BM25\Embedding`. Without treating `\` as a token boundary, path-style queries can collapse into one combined token and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat backslashes as Windows/file-path query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `\` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, pipe, plus, hyphen, ampersand, underscore, dot, equals-sign, flow-arrow, parenthesis, bracket, angle-bracket, and Chinese book-title quote separators.

**Operation:** Added catalog coverage requiring `RAG\BM25\Embedding` to produce the retrieval-plan tokens `['rag', 'bm25', 'embedding']` and retrieve results matching RAG/BM25/Embedding tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 47 tests. Targeted analysis reported no issues.

### Step 117: Local RAG Hash Tag Separator Token Boundaries

**Operation:** Added hash-sign separators to local RAG query tokenization.

**Why:** Programmer learning notes often use compact tag chains such as `RAG#BM25#Embedding` to group retrieval topics. Without treating `#` as a token boundary, tag-style queries can collapse into one combined token and weaken search, retrieval planning, answer drafting, and study-note generation.

**Feature Goal:** Let local RAG treat hash signs as tag query token boundaries while preserving first-seen order and duplicate filtering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_queryTokens()` to split on `#` in addition to whitespace, comma, enumeration comma, semicolon, colon, slash, backslash, pipe, plus, hyphen, ampersand, underscore, dot, equals-sign, flow-arrow, parenthesis, bracket, angle-bracket, and Chinese book-title quote separators.

**Operation:** Added catalog coverage requiring `RAG#BM25#Embedding` to produce the retrieval-plan tokens `['rag', 'bm25', 'embedding']` and retrieve results matching RAG/BM25/Embedding tags.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 48 tests. Targeted analysis reported no issues.

### Step 118: Local RAG English Sentence Chunk Boundaries

**Operation:** Added English sentence and newline boundaries to local RAG document chunking.

**Why:** Imported programmer notes often arrive as English Markdown paragraphs or pasted snippets where sentences are separated by periods or line breaks. The previous chunker only split on Chinese sentence punctuation, semicolons, and question/exclamation markers, so English sentence-style content could remain as one large body evidence block and make snippets less precise.

**Feature Goal:** Let local RAG produce smaller, more searchable evidence chunks for English sentence-style imported notes while preserving the existing summary/body chunk model and maximum chunk budget behavior.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `buildLocalRagChunks()` to split content on English periods and line breaks in addition to the existing Chinese sentence punctuation, semicolon, question, and exclamation boundaries.

**Operation:** Updated the chunk buffer to join adjacent short sentences with a space before checking the maximum chunk length, preventing sentence text from being glued together when several short sentences fit into the same chunk.

**Operation:** Added catalog coverage requiring English sentence-style imported notes to produce separate body chunks under a smaller chunk budget and preserve an exact `Conflict merge explains vector clocks` evidence chunk.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 49 tests. Targeted analysis reported no issues.

### Step 119: Local RAG Exact Phrase Chunk Scoring

**Operation:** Added exact multi-token phrase boosting to local RAG chunk scoring.

**Why:** The local chunk scorer already rewarded per-token matches, which is useful for recall, but it treated a continuous phrase such as `conflict merge` too similarly to separate mentions of `conflict` and `merge` in different sentence chunks. Programmer learning queries often use short technical phrases where adjacency carries meaning, so exact phrase evidence should rank ahead of scattered token evidence.

**Feature Goal:** Improve deterministic local RAG ranking by preferring chunks that contain the full normalized multi-token query phrase while preserving existing single-token scoring behavior.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated `_scoreChunk()` so multi-token queries add a small phrase boost when the chunk text contains the tokens joined as a continuous lowercase phrase.

**Operation:** Added catalog coverage with two imported sync notes: one where `conflict` and `merge` appear separately, and one where `conflict merge` appears as an exact phrase. The test requires the exact-phrase document to rank first and have a higher score than the loose match.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 50 tests. Targeted analysis reported no issues.

### Step 120: Local RAG Separator-Tolerant Phrase Scoring

**Operation:** Made local RAG phrase scoring tolerate technical separators between phrase tokens.

**Why:** Step 119 added exact multi-token phrase boosting for chunks containing phrases such as `conflict merge`, but programmer notes often write adjacent concepts with technical separators, such as `conflict-merge`, `conflict_merge`, or path-like delimiters. Those forms still express adjacency and should rank ahead of evidence where the words appear in separate sentences.

**Feature Goal:** Improve deterministic local RAG ranking for programmer-style phrase evidence by reusing the same token separator rules for both query tokenization and phrase adjacency matching.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Extracted the local RAG query-token separator pattern into `_queryTokenSeparatorPattern` so tokenizer splitting and phrase matching share one separator table.

**Operation:** Replaced the space-only phrase check with `_containsTokenPhrase()`, which tokenizes chunk text with the shared separator pattern and checks whether the query tokens appear as a consecutive token window.

**Operation:** Added catalog coverage requiring a `conflict-merge` chunk to outrank a document where `conflict` and `merge` appear separately for a `conflict merge` query.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted RAG catalog, repository, and zone widget tests passed with 51 tests after refining the separator-tolerant phrase matcher and focused test data. Targeted analysis reported no issues.

### Step 121: Code Audit Private Key Material Rule

**Operation:** Added a local code audit rule for private key material.

**Why:** The existing hardcoded-secret rule catches assignment-style credentials such as API keys, tokens, passwords, and secrets, but PEM/OpenSSH private keys often appear as multiline blocks beginning with `-----BEGIN ... PRIVATE KEY-----`. Those blocks are high-impact credential leaks and should be identified even when they are not assigned through a `password = "..."` style expression.

**Feature Goal:** Expand the deterministic local code audit scanner so it can flag pasted or committed private key material before a user copies findings into an AI audit request, repair template, or Markdown report.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the high-severity `private-key-material` rule, matching PEM/OpenSSH private key block headers such as `-----BEGIN PRIVATE KEY-----`.

**Operation:** Added code-audit scanner coverage requiring a private-key snippet to produce one `private-key-material` finding with high severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 22 tests. Targeted analysis reported no issues.

### Step 122: Code Audit Disabled TLS Verification Rule

**Operation:** Added a local code audit rule for disabled TLS/certificate verification.

**Why:** Programmer projects often contain temporary development bypasses such as Dart `badCertificateCallback => true`, Node `rejectUnauthorized: false`, Python `verify=False`, or `NODE_TLS_REJECT_UNAUTHORIZED=0`. If those bypasses reach shared code, HTTPS traffic can become vulnerable to man-in-the-middle attacks even though the URL uses TLS.

**Feature Goal:** Expand deterministic local code audit coverage so the coding zone can flag TLS verification bypasses before users copy reports, AI audit requests, or repair templates.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the high-severity `tls-verification-disabled` rule, matching common disabled TLS verification patterns across Dart, Node, Python, and environment-variable style snippets.

**Operation:** Added scanner coverage requiring a Dart `badCertificateCallback = (...) => true` snippet to produce one `tls-verification-disabled` finding with high severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 23 tests. Targeted analysis reported no issues.

### Step 123: Code Audit Weak Hash Rule

**Operation:** Added a local code audit rule for weak hash algorithm usage.

**Why:** Programmer projects sometimes keep MD5 or SHA1 calls for quick checksums, legacy signatures, or password-like verification. Those algorithms are weak for collision-resistant security work, so the local scanner should flag them as review items before findings are copied into reports, AI audit requests, or repair templates.

**Feature Goal:** Expand deterministic code audit coverage so the coding zone can identify weak hash usage and guide users toward stronger hashing or HMAC/password-hashing options.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the medium-severity `weak-hash` rule, matching `md5(`, `sha1(`, and namespace-style `md5.` / `sha1.` calls case-insensitively.

**Operation:** Added scanner coverage requiring a `sha1.convert(payload)` snippet to produce one `weak-hash` finding with medium severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed after expanding the rule to cover Dart-style `sha1.convert(...)` namespace calls. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 24 tests. Targeted analysis reported no issues.

### Step 124: Code Audit Weak Randomness Rule

**Operation:** Added a local code audit rule for non-cryptographic randomness.

**Why:** Programmer projects often use quick random helpers such as Dart `Random()`, JavaScript `Math.random()`, or Python `random.random()`. Those APIs are fine for simulations or UI variety, but risky when reused for reset codes, tokens, keys, or session identifiers. The coding zone should flag those calls as review items before a scan report or repair template is shared.

**Feature Goal:** Expand deterministic code audit coverage so the platform can warn about predictable randomness in security-sensitive code paths while keeping the rule simple and locally testable.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the medium-severity `weak-randomness` rule, matching Dart `Random(`, JavaScript `Math.random(`, and Python `random.random(` style calls case-insensitively.

**Operation:** Added scanner coverage requiring a `Random().nextInt(...)` reset-code snippet to produce one `weak-randomness` finding with medium severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 25 tests. Targeted analysis reported no issues.

### Step 125: Code Audit SQL String Interpolation Rule

**Operation:** Added a local code audit rule for SQL string interpolation and concatenation.

**Why:** Programmer projects often start with quick SQL strings such as `SELECT ... $userId` or query fragments joined with `+`. If user-controlled values enter those strings, the code can become vulnerable to SQL injection. The coding zone should flag this pattern early so users can switch to parameterized queries before copying reports, AI audit requests, or repair templates.

**Feature Goal:** Expand deterministic code audit coverage so the platform can warn about direct SQL string construction and guide users toward prepared statements, ORM parameter binding, or equivalent safe query APIs.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the high-severity `sql-string-interpolation` rule, matching SQL operation keywords followed by Dart-style `$variable` interpolation or `+` string concatenation.

**Operation:** Added scanner coverage requiring a `SELECT * FROM users WHERE id = $userId` snippet to produce one `sql-string-interpolation` finding with high severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 26 tests. Targeted analysis reported no issues.

### Step 126: Code Audit Command String Interpolation Rule

**Operation:** Added a local code audit rule for command string interpolation and concatenation.

**Why:** Programmer projects sometimes pass shell commands through APIs such as Dart `Process.run`, Node `exec`, or generic `spawn`. If user-controlled values are interpolated into those command strings, the code can become vulnerable to command injection. The coding zone should flag this pattern early so users can replace shell string construction with fixed executables and explicit argument arrays.

**Feature Goal:** Expand deterministic code audit coverage so the platform can warn about command construction risks before users copy reports, AI audit requests, or repair templates.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the high-severity `command-string-interpolation` rule, matching command execution calls such as `Process.run`, `Process.start`, `exec`, or `spawn` when the same line includes Dart-style `$variable` interpolation or `+` string concatenation.

**Operation:** Added scanner coverage requiring a `Process.run('sh', ['-c', 'rm -rf $targetPath'])` snippet to produce one `command-string-interpolation` finding with high severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 27 tests. Targeted analysis reported no issues.

### Step 127: Code Audit Wildcard CORS Rule

**Operation:** Added a local code audit rule for wildcard CORS configuration.

**Why:** Programmer projects often temporarily allow all origins with headers such as `Access-Control-Allow-Origin: *` or middleware configuration like `origin: '*'`. That can be acceptable for public static resources, but is risky around authenticated APIs, internal tools, or user data because it broadens browser-side access. The coding zone should flag the pattern so users review and replace it with an explicit allowlist when appropriate.

**Feature Goal:** Expand deterministic code audit coverage so the platform can warn about overly broad CORS settings before users copy reports, AI audit requests, or repair templates.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the medium-severity `wildcard-cors` rule, matching `Access-Control-Allow-Origin` assignments to `*` and `origin: '*'` style middleware configuration.

**Operation:** Added scanner coverage requiring an `Access-Control-Allow-Origin` wildcard snippet to produce one `wildcard-cors` finding with medium severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 28 tests. Targeted analysis reported no issues.

### Step 128: Code Audit Cookie Secure Disabled Rule

**Operation:** Added a local code audit rule for disabled Cookie Secure flags.

**Why:** Programmer projects sometimes keep session or cookie configuration such as `secure: false` while developing locally. If that configuration reaches production, session cookies and other credentials can travel over non-HTTPS connections. The coding zone should flag this pattern so users review cookie transport settings before copying reports, AI audit requests, or repair templates.

**Feature Goal:** Expand deterministic code audit coverage so the platform can warn about session cookie transport risks and guide users toward HTTPS-only Cookie settings.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the medium-severity `cookie-secure-disabled` rule, matching Cookie/session-related lines where `secure: false` or `.secure = false` appears.

**Operation:** Added scanner coverage requiring a `CookieOptions(secure: false, httpOnly: true)` snippet to produce one `cookie-secure-disabled` finding with medium severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 29 tests. Targeted analysis reported no issues.

### Step 129: Code Audit CSRF Disabled Rule

**Operation:** Added a local code audit rule for disabled CSRF/XSRF protection.

**Why:** Programmer projects sometimes disable CSRF protection during local development with flags such as `csrfProtection: false`. If that setting reaches a Cookie-backed production flow, form submissions and state-changing endpoints can become exposed to cross-site request attacks. The coding zone should flag this pattern before users copy reports, AI audit requests, or repair templates.

**Feature Goal:** Expand deterministic code audit coverage so the platform can warn about disabled CSRF defenses in session-based web flows.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the medium-severity `csrf-disabled` rule, matching `csrf`, `csrfProtection`, `xsrf`, or `antiForgery` fields assigned to `false`.

**Operation:** Added scanner coverage requiring a `SecurityOptions(csrfProtection: false)` snippet to produce one `csrf-disabled` finding with medium severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 30 tests. Targeted analysis reported no issues.

### Step 130: Code Audit JWT None Algorithm Rule

**Operation:** Added a local code audit rule for JWT `none` algorithm configuration.

**Why:** Programmer projects may copy JWT examples that set `alg` or `algorithm` to `none` during experiments. If that setting reaches authentication code, token signature verification can be bypassed and forged tokens may be accepted. The coding zone should flag this pattern before users copy reports, AI audit requests, or repair templates.

**Feature Goal:** Expand deterministic code audit coverage so the platform can warn about JWT signature bypass risks in authentication flows.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the high-severity `jwt-none-algorithm` rule, matching JWT/jsonwebtoken configuration lines where `alg` or `algorithm` is assigned to `none`.

**Operation:** Added scanner coverage requiring a `jwtOptions` snippet with `algorithm: 'none'` to produce one `jwt-none-algorithm` finding with high severity, the original file path, and the correct line number.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_rules_test.dart test\platform_ai_audit_request_test.dart test\platform_fix_suggestion_template_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed after expanding the rule to cover quoted object keys such as `'algorithm': 'none'`. Formatter completed successfully. Targeted code audit rules, AI audit request, fix suggestion template, and zone widget tests passed with 32 tests. Targeted analysis reported no issues.

### Step 131: Project Code Audit Report Context

**Operation:** Added project-level Markdown report formatting and saving for code audits.

**Why:** The coding zone could scan a whole local project, but saving the project report only persisted the raw finding list. A saved report should remain useful after the app closes: it needs the scanned project path, file counts, skipped-file counts, enabled rule set, severity totals, and the individual findings in one Markdown artifact.

**Feature Goal:** Make project audit exports self-contained enough for handoff, later review, and AI-assisted follow-up.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `lib/pages/platform/platform_code_audit_repository.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_code_audit_rules_test.dart`
- `test/platform_code_audit_repository_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `formatCodeAuditProjectReport`, including scan summary, enabled rules, severity totals, and risk findings.

**Operation:** Added `saveCodeAuditProjectReport`, writing project reports as `project_code_audit_*.md` while preserving the existing snippet report save API.

**Operation:** Updated the coding zone project report save button to persist the full project report context instead of only `report.findings`.

**Operation:** Added repository and formatter tests covering project report Markdown content and saved file naming.

**Verification Commands:**
- `dart format lib\pages\platform\platform_code_audit_rules.dart lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_rules_test.dart test\platform_code_audit_repository_test.dart`
- `flutter test test\platform_code_audit_rules_test.dart test\platform_code_audit_repository_test.dart test\platform_code_audit_report_history_test.dart test\platform_ai_audit_request_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit rules, repository, report history, and AI audit request tests passed with 21 tests.

### Step 132: Code Audit Report History Reuse

**Operation:** Added copy actions for saved code audit report history.

**Why:** After project and snippet reports are saved, users need to reuse them in notes, issue descriptions, or external AI review prompts without manually opening the Markdown file. The history panel already listed recent reports, so adding direct Markdown/path copy actions makes the saved report loop usable from inside the coding zone.

**Feature Goal:** Make saved audit reports immediately reusable for handoff and follow-up work.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_repository.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_code_audit_report_history_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `readCodeAuditReportMarkdown`, with a size guard before copying historical Markdown content.

**Operation:** Added history list actions to copy saved report Markdown or copy the report path, with user feedback on success or read failure.

**Operation:** Confirmed report history labels snippet and project reports separately, so copied history entries are easier to distinguish.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_report_history_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_report_history_test.dart test\platform_code_audit_repository_test.dart test\platform_code_audit_rules_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_report_history_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted code audit report history, repository, rules, and zone widget tests passed with 35 tests. Targeted analysis reported no issues.

### Step 133: Code Audit Report History Type Labels

**Operation:** Added saved report type metadata for code audit history.

**Why:** The coding zone can now save both snippet audit reports and project audit reports. Listing them only by filename, timestamp, size, and path made the history harder to scan, especially after Step 131 introduced project-level Markdown exports. The history should identify whether an entry came from a snippet scan or a project scan.

**Feature Goal:** Make saved code audit history easier to review by labeling `code_audit_*.md` entries as snippet audits and `project_code_audit_*.md` entries as project audits.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_repository.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_code_audit_report_history_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `CodeAuditReportType` and `CodeAuditReportTypeLabel`, with repository history detection based on saved report filename prefixes.

**Operation:** Updated the coding zone report history subtitle to display the saved report type before timestamp, size, and path.

**Operation:** Added history tests requiring snippet reports to be labeled as snippet audits and project report files to be labeled as project audits while preserving recent-first ordering.

**Verification Commands:**
- `dart format lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_report_history_test.dart`
- `flutter test test\platform_code_audit_report_history_test.dart test\platform_code_audit_repository_test.dart test\platform_code_audit_rules_test.dart`
- `dart analyze lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_report_history_test.dart`

**Result:** Passed. Formatter completed successfully. Targeted report history, repository, and code audit rule tests passed with 23 tests. Targeted analysis reported no issues.

### Step 134: Code Audit Report History Type Filter

**Operation:** Added type filtering for saved code audit report history.

**Why:** Step 133 labeled saved reports as snippet audits or project audits, but repository callers still had to fetch the mixed history and filter it themselves. A first-class `reportType` filter keeps future UI controls, automation, and focused report reuse simple and consistent.

**Feature Goal:** Let the platform retrieve only snippet audit reports or only project audit reports from the saved Markdown history while preserving the existing mixed recent-first behavior by default.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_repository.dart`
- `test/platform_code_audit_report_history_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added an optional `reportType` parameter to `listCodeAuditReports`, filtering entries after filename-based type detection and before sorting/limiting.

**Operation:** Added repository coverage saving one snippet report and one project report, then requiring project-only and snippet-only history calls to return the matching file paths.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_code_audit_repository.dart test\platform_code_audit_report_history_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_report_history_test.dart test\platform_code_audit_repository_test.dart test\platform_code_audit_rules_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_code_audit_repository.dart test\platform_code_audit_report_history_test.dart`

**Result:** Passed. Formatter reported 2 files already formatted with 0 changed files. Targeted code audit report history, repository, and rule tests passed with 24 tests. Targeted analysis reported no issues.

### Step 135: Relax Session Markdown Summary

**Operation:** Added Markdown summary copying for relax session history.

**Why:** The relax zone now records recent focus and rest rhythms, but those records were only visible inside the app. Users who keep learning logs or daily reviews need a quick way to move rhythm history into notes without manually rewriting counts, minutes, and timestamps.

**Feature Goal:** Make relax session history reusable as a concise Markdown recap for study reviews and handoff notes.

**Files Modified:**
- `lib/pages/platform/platform_relax_session_repository.dart`
- `lib/pages/platform/relax_zone_page.dart`
- `test/platform_relax_session_repository_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `formatRelaxSessionSummary`, producing a Markdown summary with generated time, record count, total minutes, and newest-first recent rhythm records.

**Operation:** Added a `复制总结` action to the relax session history panel, copying the generated Markdown summary to the clipboard with snackbar feedback.

**Operation:** Added repository and widget coverage for Markdown summary formatting and clipboard copy from the relax zone.

**Verification Commands:**
- `dart format lib\pages\platform\platform_relax_session_repository.dart lib\pages\platform\relax_zone_page.dart test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_relax_session_repository.dart lib\pages\platform\relax_zone_page.dart test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully with 0 changed files. Targeted relax session repository and zone widget tests passed with 16 tests. Targeted analysis reported no issues.

### Step 136: Code Audit Report History UI Filter

**Operation:** Added report type filtering controls to the coding zone report history panel.

**Why:** Step 134 made the repository capable of filtering saved Markdown reports by snippet audit or project audit, but the coding zone still showed one mixed history list. Users need a direct way to focus recent snippet reports or project reports before copying Markdown or paths into reviews.

**Feature Goal:** Let users switch the coding zone report history between all reports, snippet audit reports, and project audit reports without leaving the page.

**Files Modified:**
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added a `CodeAuditReportHistoryLoader` injection point and default loader so the widget can request report history with the selected `CodeAuditReportType` while tests can provide deterministic saved reports.

**Operation:** Added an all/snippet/project history filter state and a `SegmentedButton` to the report history panel, including filter-specific empty messages.

**Operation:** Added widget coverage that starts with mixed history, switches to project-only history, then switches to snippet-only history and verifies the displayed report filenames match the selected audit type.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\coding_zone_page.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_zones_test.dart test\platform_code_audit_report_history_test.dart test\platform_code_audit_repository_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_code_audit_report_history_test.dart test\platform_code_audit_repository_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\coding_zone_page.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter reported 2 files already formatted with 0 changed files. Targeted platform zone widget tests passed with 21 tests, including the new report-history type filter coverage. Targeted code audit report history and repository tests passed with 7 tests. Targeted analysis reported no issues.

### Step 137: Local RAG Markdown Boundary Chunking

**Operation:** Added Markdown structure boundaries to local RAG document chunking.

**Why:** Imported learning notes often use headings, bullet lists, numbered lists, and blockquotes to separate review sections or action items. The previous chunker split on sentence and line breaks, but Markdown structure could still be merged into nearby paragraph evidence when the combined text fit within the chunk length budget.

**Feature Goal:** Keep Markdown headings, list items, and quoted lines as focused evidence snippets while preserving the existing summary/body chunk model and sentence-length buffering.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `test/platform_rag_catalog_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added internal RAG content segments so forced Markdown boundaries can flush buffered body text before creating their own chunk.

**Operation:** Added Markdown boundary detection for ATX headings, unordered list items, numbered list items, and blockquote lines.

**Operation:** Marked sentence-level content segments as forced RAG chunk boundaries so English period-separated sentences stay as focused evidence instead of being merged back into neighboring sentences.

**Operation:** Added catalog coverage requiring Markdown heading and list lines to remain standalone chunks instead of being merged into surrounding paragraph text.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart test\platform_rag_catalog_test.dart`

**Result:** Passed. Formatter completed successfully and rewrote `test/platform_rag_catalog_test.dart`. Targeted RAG catalog and zone widget tests passed with 51 tests, including the new Markdown boundary chunking coverage. Targeted analysis reported no issues.

### Step 138: Imported RAG Library Markdown Summary

**Operation:** Added Markdown summary copying for the imported RAG library.

**Why:** Imported RAG documents could already be copied one by one, but users who are preparing a learning review, Prompt context, or handoff note need a compact overview of the whole imported library without manually collecting titles, sources, tags, and summaries.

**Feature Goal:** Let users copy a Markdown overview of all imported RAG documents from the learning zone.

**Files Modified:**
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `buildImportedRagLibraryMarkdown`, producing a Markdown overview with generated time, document count, source distribution, tag distribution, and newest-first document summaries.

**Operation:** Added a `复制资料库总览` action to the RAG import panel, enabled when imported documents exist and copying the generated Markdown to the clipboard with snackbar feedback.

**Operation:** Added widget coverage importing two documents, copying the library summary, and verifying the Markdown contains document count, source/tag distributions, and both document summaries in current library order.

**Verification Commands:**
- `dart format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`
- `flutter test test\platform_zones_test.dart`
- `flutter test test\platform_rag_catalog_test.dart test\platform_rag_repository_test.dart`
- `dart analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully with 0 changed files. Targeted platform zone widget tests passed with 15 tests, including the new imported-library Markdown summary copy flow. Targeted RAG catalog and repository tests passed with 40 tests after the sentence-boundary chunking fix. Targeted analysis reported no issues.

### Step 139: Local RAG Search Ranking Reasons

**Operation:** Added ranking explanations to local RAG search results.

**Why:** The RAG preview already exposes score, matched fields, tags, and evidence snippets, but users still had to infer why a result appeared near the top. A concise ranking reason makes retrieval behavior easier to audit before copying evidence into notes or prompts.

**Feature Goal:** Show and export a human-readable reason for each local RAG search result without changing the existing scoring behavior.

**Files Modified:**
- `lib/pages/platform/platform_rag_catalog.dart`
- `lib/pages/platform/rag_library_preview.dart`
- `test/platform_rag_catalog_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `rankingReason` to `RagSearchResult`, generated from matched fields, matched tags, the best evidence chunk label, and the final score, with an empty-query default explanation.

**Operation:** Rendered the ranking reason in each RAG result card and included it in copied search result Markdown.

**Operation:** Added catalog and widget coverage for ranking reason generation and clipboard Markdown export.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze lib\pages\platform\platform_rag_catalog.dart lib\pages\platform\rag_library_preview.dart test\platform_rag_catalog_test.dart test\platform_zones_test.dart`

**Result:** Passed for the Step 139 RAG scope. Formatter reported 4 files already formatted with 0 changed files. Targeted RAG catalog tests passed with 37 tests, including the new ranking-reason coverage. Targeted RAG preview clipboard widget test passed for copied search result Markdown. Targeted analysis reported no issues. The broader `test\platform_rag_catalog_test.dart test\platform_zones_test.dart` run reached the new RAG coverage successfully, then stalled on later non-RAG coding/relax/settings widget tests with `did not complete`; the first stalled coding-zone test also stalled when run alone, so it is tracked as outside this Step 139 change.

### Step 140: Platform Zone Widget Test Dependency Isolation

**Operation:** Isolated platform zone widget smoke tests from default filesystem-backed storage.

**Why:** Step 139 verification showed the combined RAG + zone test run reached the new RAG coverage, then stalled on later coding/relax/settings widget tests with `did not complete`. The coding smoke test used the default report-history loader, which can touch `path_provider`, while the relax smoke test used the default Hive-backed session repository. Those external dependencies make broad platform verification noisier than the UI assertions require.

**Feature Goal:** Keep platform zone widget tests deterministic by injecting in-memory dependencies for smoke tests that only need to verify rendered UI content.

**Files Modified:**
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Updated the coding-zone smoke test to pass an empty in-memory report-history loader instead of using the default filesystem-backed loader.

**Operation:** Updated the relax-zone smoke test to pass a `PlatformRelaxSessionRepository` backed by `_MemoryPlatformRagStorage` instead of using the default Hive storage.

**Verification Commands:**
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe format test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\flutter_tools.snapshot test test\platform_rag_catalog_test.dart test\platform_zones_test.dart`
- `D:\SoftWare\flutter_windows_3.44.0-stable\flutter\bin\cache\dart-sdk\bin\dart.exe analyze test\platform_zones_test.dart`

**Result:** Passed. Formatter reported `test/platform_zones_test.dart` already formatted with 0 changed files. Full platform zone widget tests passed with 15 tests, including the previously stalled coding, relax, and settings smoke tests. The combined RAG catalog + platform zone test run passed with 52 tests, confirming the Step 139 verification command now completes end to end. Targeted analysis of `test/platform_zones_test.dart` reported no issues.

### Step 141: Learning Progress Markdown Review

**Operation:** Added Markdown review copying for learning progress.

**Why:** The learning zone already persists completed resources, but the progress panel only showed a count and progress bar inside the app. Users who keep study logs need a portable summary of completed resources, type distribution, levels, tags, and entry links.

**Feature Goal:** Let users copy the current learning progress as a Markdown review from the learning zone.

**Files Modified:**
- `lib/pages/platform/platform_learning_progress_repository.dart`
- `lib/pages/platform/learning_zone_page.dart`
- `test/platform_learning_progress_repository_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `buildLearningProgressMarkdown`, which summarizes generated time, completed count, completion percentage, completed resource type distribution, and a numbered completed-resource list.

**Operation:** Added a copy action to the learning progress panel. The action exports the current completed resource set and shows snackbar feedback after copying.

**Operation:** Added repository coverage for populated and empty Markdown summaries, plus widget coverage that marks a learning resource complete and copies the progress review from the learning zone.

**Verification Commands:**
- `dart format lib\pages\platform\platform_learning_progress_repository.dart lib\pages\platform\learning_zone_page.dart test\platform_learning_progress_repository_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_learning_progress_repository_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_learning_progress_repository.dart lib\pages\platform\learning_zone_page.dart test\platform_learning_progress_repository_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully and rewrote the new learning-progress files. Targeted learning progress repository and platform zone widget tests passed with 20 tests, including the new progress-review copy coverage. Targeted analysis reported no issues.

### Step 142: Progress-Aware Learning Recommendations

**Operation:** Made learning recommendations skip resources the user has already completed.

**Why:** The recommendation prototype ranked resources by learning goal, type, tags, and difficulty, but it did not account for persisted progress. A completed resource could remain in the recommendation list, which made the panel less useful as a next-step guide.

**Feature Goal:** Turn the learning-zone recommendation panel into a progress-aware next-step list by filtering out completed learning resources.

**Files Modified:**
- `lib/pages/platform/platform_recommendation_catalog.dart`
- `lib/pages/platform/learning_zone_page.dart`
- `test/platform_recommendation_catalog_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added an optional `completedResourceIds` argument to `recommendPlatformResources` and skipped matching resources before scoring and ranking.

**Operation:** Passed the learning zone's current completed resource set into `_RecommendationPanel`, so checkbox changes immediately affect the recommendation list.

**Operation:** Added stable widget keys for recommendation tiles, goal chips, and resource cards so tests can target recommendation/progress interactions without relying on duplicate visible text.

**Verification Commands:**
- `dart format lib\pages\platform\platform_recommendation_catalog.dart lib\pages\platform\learning_zone_page.dart test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_recommendation_catalog.dart lib\pages\platform\learning_zone_page.dart test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter reported the target files already formatted. Targeted recommendation catalog and platform zone widget tests passed with 21 tests, including the new progress-aware recommendation coverage. Targeted analysis reported no issues.

### Step 143: Learning Recommendation Markdown Export

**Operation:** Added Markdown export for the current learning recommendation list.

**Why:** Step 142 made the recommendation panel progress-aware, but the resulting next-step list still only lived inside the learning zone. Users who keep study logs, handoff notes, or Prompt context need a portable summary of recommended resources, reasons, scores, tags, and entry links.

**Feature Goal:** Let users copy the current learning recommendation list as a Markdown artifact from the learning zone.

**Files Modified:**
- `lib/pages/platform/platform_recommendation_catalog.dart`
- `lib/pages/platform/learning_zone_page.dart`
- `test/platform_recommendation_catalog_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `buildLearningRecommendationMarkdown`, including generated time, selected learning goal, completed-resource count, recommendation count, and a numbered next-step list with type, level, score, reason, tags, and entry URL.

**Operation:** Added a `复制学习推荐清单` action to the recommendation panel, copying the currently selected goal's progress-aware recommendations and showing snackbar feedback.

**Operation:** Added recommendation catalog coverage for populated and empty Markdown exports, plus learning-zone widget coverage for copying recommendation Markdown through the UI.

**Verification Commands:**
- `dart format lib\pages\platform\platform_recommendation_catalog.dart lib\pages\platform\learning_zone_page.dart test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_recommendation_catalog.dart lib\pages\platform\learning_zone_page.dart test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter completed successfully and rewrote `lib/pages/platform/learning_zone_page.dart`. Targeted recommendation catalog and platform zone widget tests passed with 24 tests, including the new recommendation Markdown export coverage. Targeted analysis reported no issues.

### Step 144: Recommendation Completion Empty State

**Operation:** Added an explicit empty state for completed recommendation goals.

**Why:** Progress-aware recommendations can legitimately return no next-step resources when all resources for a selected goal are complete. Previously that left the recommendation panel visually blank after the pipeline explanation, which made it look like content failed to load.

**Feature Goal:** Show a clear completion message when the selected learning goal has no remaining recommendations after progress filtering.

**Files Modified:**
- `lib/pages/platform/learning_zone_page.dart`
- `test/platform_recommendation_catalog_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_RecommendationEmptyState`, displayed when the progress-aware recommendation list is empty.

**Operation:** Added catalog coverage proving a goal returns an empty recommendation list when all matching resources are completed, and widget coverage for the learning-zone empty state.

**Verification Commands:**
- `dart format lib\pages\platform\learning_zone_page.dart test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\learning_zone_page.dart test\platform_recommendation_catalog_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter reported target files already formatted. Targeted recommendation catalog and platform zone widget tests passed with 26 tests, including the new completed-recommendations empty-state coverage. Targeted analysis reported no issues.

### Step 145: Debug Mode Audit Rule

**Operation:** Added a deterministic local code audit rule for enabled debug mode.

**Why:** The coding zone already checks secrets, TLS verification, CORS, cookies, CSRF, weak hashing, weak randomness, and debug output, but production configuration can still leak sensitive internals when debug mode remains enabled. This rule catches simple `debug: true`, `debugMode = true`, and `.debug = true` style configuration lines.

**Feature Goal:** Expand local code audit coverage so the coding zone flags enabled debug mode before snippets or project reports are copied.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_rules.dart`
- `test/platform_code_audit_rules_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added the medium-severity `debug-mode-enabled` rule with a production-hardening suggestion.

**Operation:** Added rule coverage requiring `{'debug': true}` to be reported as `debug-mode-enabled` while preserving existing coding-zone smoke expectations.

**Verification Commands:**
- `dart format lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`
- `flutter test test\platform_code_audit_rules_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_code_audit_rules.dart test\platform_code_audit_rules_test.dart`

**Result:** Passed. Formatter reported target files already formatted. Targeted code audit rule and platform zone widget tests passed with 37 tests, including the new debug-mode rule coverage. Targeted analysis reported no issues.

### Step 146: Relax Session Distribution Summary

**Operation:** Added rhythm distribution to copied relax session summaries.

**Why:** The relax zone summary already included generated time, record count, total minutes, and recent records, but users could not quickly see how focus sessions and short/long breaks were balanced. A distribution line makes the copied review more useful for spotting skewed study rhythm.

**Feature Goal:** Include per-rhythm counts and total minutes in the Markdown summary copied from the relax zone.

**Files Modified:**
- `lib/pages/platform/platform_relax_session_repository.dart`
- `test/platform_relax_session_repository_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added a `节奏分布` line to `formatRelaxSessionSummary`, grouping records by title and showing count/minutes per rhythm.

**Operation:** Added repository coverage for populated rhythm distribution and the empty-session `无` distribution state.

**Verification Commands:**
- `dart format lib\pages\platform\platform_relax_session_repository.dart test\platform_relax_session_repository_test.dart`
- `flutter test test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_relax_session_repository.dart test\platform_relax_session_repository_test.dart`

**Result:** Passed. Formatter reported target files already formatted. Targeted relax session repository and platform zone widget tests passed with 23 tests, including the new rhythm distribution summary coverage. Targeted analysis reported no issues.

### Step 147: Relax Session Distribution Preview

**Operation:** Displayed rhythm distribution directly in the relax zone history panel.

**Why:** Step 146 added rhythm distribution to copied Markdown summaries, but users still had to copy the summary to see the balance between focus and rest sessions. Showing the same distribution in the panel gives immediate feedback before copying or clearing records.

**Feature Goal:** Make focus/rest rhythm balance visible inside the relax zone, not only in exported Markdown.

**Files Modified:**
- `lib/pages/platform/platform_relax_session_repository.dart`
- `lib/pages/platform/relax_zone_page.dart`
- `test/platform_relax_session_repository_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Promoted the distribution formatter to `formatRelaxSessionDistribution` and reused it in both the Markdown summary and the history panel.

**Operation:** Added visible `节奏分布` text below the record count/total minutes line, including the empty `无` state.

**Operation:** Added repository coverage for grouped rhythm distribution and widget coverage for empty and recorded distribution text.

**Verification Commands:**
- `dart format lib\pages\platform\platform_relax_session_repository.dart lib\pages\platform\relax_zone_page.dart test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_relax_session_repository.dart lib\pages\platform\relax_zone_page.dart test\platform_relax_session_repository_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter reported target files already formatted. Targeted relax session repository and platform zone widget tests passed with 24 tests, including the new visible rhythm distribution coverage. Targeted analysis reported no issues.

### Step 148: Relax Session Clear Undo

**Operation:** Added undo support after clearing relax session history.

**Why:** The relax zone made clearing records a one-click destructive action. Since rhythm history is part of the learning review loop, users should have a short recovery path if they clear it accidentally.

**Feature Goal:** Let users restore the just-cleared relax session list through snackbar undo while keeping persisted storage in sync.

**Files Modified:**
- `lib/pages/platform/relax_zone_page.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Snapshotted the current session list before clearing, saved the empty list, then showed a snackbar with `撤销`.

**Operation:** Added `_restoreClearedSessions`, restoring the snapshot and persisting it when the snackbar action is tapped.

**Operation:** Added widget coverage that records a session, clears history, verifies storage is empty, taps undo, and verifies the record is restored.

**Verification Commands:**
- `dart format lib\pages\platform\relax_zone_page.dart test\platform_zones_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\relax_zone_page.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter reported target files already formatted. Platform zone widget tests passed with 20 tests, including the new clear-undo flow. Targeted analysis reported no issues.

### Step 149: Code Audit Report History Delete

**Operation:** Added deletion support for saved code audit reports.

**Why:** The coding zone report history could filter, copy report Markdown, copy paths, and copy a history overview, but saved Markdown files could only accumulate. Users need a direct way to remove obsolete snippet/project audit reports from the history list.

**Feature Goal:** Let users delete individual saved audit report Markdown files from the coding zone report history and refresh the list afterwards.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_repository.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_code_audit_report_history_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `deleteCodeAuditReport`, deleting the underlying Markdown file when it exists.

**Operation:** Added a report-history deleter injection point to `CodingZonePage`, wired the default deleter to the repository helper, and added a `删除报告` action to each saved report row.

**Operation:** Added repository coverage for deleting a saved Markdown report and widget coverage that deletes a fake report through the coding zone UI, refreshes history, and shows snackbar feedback.

**Verification Commands:**
- `dart format lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_report_history_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_code_audit_report_history_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_report_history_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter reported target files already formatted. Targeted report-history repository and platform zone widget tests passed with 28 tests, including the new delete flow. Targeted analysis reported no issues.

### Step 150: Code Audit Report Delete Undo

**Operation:** Added undo support after deleting saved code audit reports.

**Why:** Step 149 gave users a direct delete action for obsolete report-history entries, but deleting a saved Markdown report is still destructive. Since reports are part of the learning and review handoff loop, the coding zone should offer the same short recovery path already used by the relax history workflow.

**Feature Goal:** Let users restore the just-deleted audit report from the snackbar undo action, recreating the Markdown file and refreshing report history.

**Files Modified:**
- `lib/pages/platform/platform_code_audit_repository.dart`
- `lib/pages/platform/coding_zone_page.dart`
- `test/platform_code_audit_report_history_test.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `restoreCodeAuditReportMarkdown`, which recreates the original report path and writes the captured Markdown content back to disk.

**Operation:** Added report Markdown reader and report restorer injection points to `CodingZonePage`, then changed delete handling to read a snapshot before deletion and expose snackbar `撤销` when a snapshot is available.

**Operation:** Extended repository coverage for restore-after-delete and widget coverage for deleting a fake report, tapping undo, and seeing the history entry return.

**Verification Commands:**
- `dart format lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_report_history_test.dart test\platform_zones_test.dart`
- `flutter test test\platform_code_audit_report_history_test.dart test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\platform_code_audit_repository.dart lib\pages\platform\coding_zone_page.dart test\platform_code_audit_report_history_test.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter reported 4 files formatted with 0 changed files. Targeted report-history repository and platform zone widget tests passed with 29 tests, including the new delete-undo flow. Targeted analysis reported no issues.

### Step 151: Learning Progress Clear Undo

**Operation:** Added clear-and-undo support for learning progress.

**Why:** The learning zone could mark resources complete and copy progress reviews, but there was no quick way to start a new study cycle without manually unchecking resources one by one. Clearing progress is destructive, so it should follow the same snackbar undo pattern now used by RAG library deletion, relax history clearing, and code audit report deletion.

**Feature Goal:** Let users clear completed learning resources from the progress panel, persist the empty state, and restore the previous completed set through snackbar `撤销`.

**Files Modified:**
- `lib/pages/platform/learning_zone_page.dart`
- `test/platform_zones_test.dart`
- `docs/release/2026-05-31-platform-mvp-handoff.md`

**Operation:** Added `_clearLearningProgress` and `_restoreLearningProgress`, snapshotting the completed resource id set before clearing and saving both the cleared and restored states through `PlatformLearningProgressRepository`.

**Operation:** Added a `清空学习进度` icon action to the learning progress panel. The action is disabled when no resources are completed and shows snackbar `撤销` after clearing.

**Operation:** Added widget coverage that marks a resource complete, clears progress, verifies persisted storage is empty, taps undo, and verifies the completed resource id returns.

**Verification Commands:**
- `dart format lib\pages\platform\learning_zone_page.dart test\platform_zones_test.dart`
- `flutter test test\platform_zones_test.dart`
- `dart analyze lib\pages\platform\learning_zone_page.dart test\platform_zones_test.dart`

**Result:** Passed. Formatter updated `lib/pages/platform/learning_zone_page.dart`. Platform zone widget tests passed with 22 tests, including the new learning progress clear-undo flow. Targeted analysis reported no issues.
