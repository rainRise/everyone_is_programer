# Programmer Learning Platform Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert the existing Kazumi Flutter shell into a programmer learning platform with three primary zones: learning resources, coding workspace, and relaxation.

**Architecture:** Keep the existing Flutter desktop/mobile shell, theme provider, storage bootstrap, and modular routing. Replace the current Kazumi tab surface with new platform zones first, then incrementally remove anime-specific modules after the new MVP is stable.

**Tech Stack:** Flutter 3.44.0, Dart, flutter_modular, Material 3, existing provider/theme setup.

---

## Phase 1 MVP

### Task 1: Create Traceable Plan And Log

**Files:**
- Create: `docs/plans/2026-05-28-programmer-learning-platform.md`
- Create: `docs/dev-log/2026-05-28-programmer-learning-platform-log.md`

**Steps:**
1. Record the implementation plan.
2. Record every user-visible operation and verification result.
3. Keep rationale concise and audit-friendly.

### Task 2: Add Failing Widget Test

**Files:**
- Create: `test/platform_zones_test.dart`

**Expected RED:**
- Test fails because `LearningZonePage`, `CodingZonePage`, and `RelaxZonePage` do not exist yet.

### Task 3: Create Three Zone Pages

**Files:**
- Create: `lib/pages/platform/learning_zone_page.dart`
- Create: `lib/pages/platform/coding_zone_page.dart`
- Create: `lib/pages/platform/relax_zone_page.dart`

**Expected GREEN:**
- Widget tests find all zone titles and key resource labels.

### Task 4: Create Zone Modules

**Files:**
- Create: `lib/pages/platform/learning_zone_module.dart`
- Create: `lib/pages/platform/coding_zone_module.dart`
- Create: `lib/pages/platform/relax_zone_module.dart`

**Expected:**
- Each module routes `/` to its zone page.

### Task 5: Replace Root Navigation

**Files:**
- Modify: `lib/pages/router.dart`
- Modify: `lib/pages/menu/menu.dart`

**Expected:**
- Navigation shows `资料`, `编程`, `放松`.
- Routes become `/tab/learning/`, `/tab/coding/`, `/tab/relax/`.

### Task 6: Switch Default Startup Page

**Files:**
- Modify: `lib/pages/init_page.dart`

**Expected:**
- Default route changes from `/tab/popular/` to `/tab/learning/`.

### Task 7: Verify

**Commands:**
- `flutter test test/platform_zones_test.dart`
- `flutter analyze`
- `flutter run -d windows`

**Expected:**
- Tests pass.
- Analyzer has no new errors.
- Windows app starts with the new platform shell.

## Deferred Phases

1. Replace Kazumi-specific initialization and controllers.
2. Add local RAG document ingestion and retrieval UI.
3. Add algorithm/model resource catalog.
4. Add code audit workspace and report pages.
5. Add relaxation tools such as pomodoro and rest resources.
