# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **museo_mobile**, a Flutter application built with Clean Architecture principles. The app follows a feature-based architecture with clear separation between domain, data, and presentation layers. The project implements a comprehensive theme system, accessibility-first design, and Result<T> error handling patterns.

## Essential Commands

```bash
# Install dependencies
flutter pub get

# Generate code (REQUIRED after model/injectable changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Generate translations (after adding new l10n keys)
flutter gen-l10n

# Static analysis (MUST pass with zero warnings)
flutter analyze

# Run tests
flutter test

# Run app
flutter run
```

## Architecture Overview

**Clean Architecture with 3 layers per feature:**

```
lib/
├── core/                          # Shared utilities, theme, DI
│   ├── config_tools/              # injection.dart, app_router.dart
│   ├── presentation/
│   │   ├── theme/                 # AppColors, AppTextStyles, AppSpacing, AppRadius
│   │   └── widgets/               # AppTapWidget, SelectableItem, AppScaffold
│   └── tools/                     # logger.dart, exceptions/
├── features/{feature}/
│   ├── domain/                    # entities/, repositories/, usecases/
│   ├── data/                      # models/, datasources/, repositories/
│   └── presentation/              # cubit/, pages/, widgets/
└── main.dart
```

**Key Patterns:**
- **State**: flutter_bloc Cubit + Result<T> (never try-catch in Cubits)
- **DI**: get_it + injectable with `@injectable`, `@Injectable(as: Interface)`
- **Navigation**: go_router
- **Code Gen**: freezed (always `abstract class`), json_serializable

## Critical Rules

### Freezed Classes (ALWAYS abstract)
```dart
// ✅ CORRECT
@freezed
abstract class User with _$User {
  const factory User({required String id}) = _User;
}

// ❌ WRONG - causes analyzer errors
@freezed
class User with _$User { ... }
```

### Result<T> Pattern (NO try-catch in Cubits)
```dart
// ✅ CORRECT - Cubit uses result.when()
Future<void> signIn() async {
  emit(const AuthState.loading());
  final result = await signInUseCase();
  result.when(
    success: (user) => emit(AuthState.loaded(user: user)),
    failure: (message) => emit(AuthState.error(message)),
  );
}

// ❌ WRONG - try-catch in Cubit
Future<void> signIn() async {
  try {
    emit(const AuthState.loading());
    final user = await signInUseCase(); // NEVER!
    emit(AuthState.loaded(user: user));
  } catch (e) { ... }
}
```

### Flat Result Handling (NO nested .when())
```dart
// ✅ CORRECT - early returns with is Failure checks
final uploadResult = await _datasource.getUpload(id);
if (uploadResult is Failure<UploadDTO?>) {
  return Failure(uploadResult.message);
}
final upload = (uploadResult as Success<UploadDTO?>).data;

// ❌ WRONG - deeply nested .when() callbacks
return uploadResult.when(
  success: (upload) => photosResult.when(
    success: (photos) => ... // Too nested!
  ),
);
```

### Immutable State (Data in State, NOT Cubit fields)
```dart
// ✅ CORRECT - data stored in freezed state
@freezed
class UserState with _$UserState {
  const factory UserState.loaded(User user) = _Loaded;
}

// Access via getter
User? get currentUser => state.maybeWhen(loaded: (u) => u, orElse: () => null);

// ❌ WRONG - mutable field in Cubit
User? _cachedUser; // NEVER store data in Cubit fields!
```

### Theme System (NEVER hardcode values)
```dart
// ✅ CORRECT
Container(
  color: AppColors.instance.backgroundPrimary,
  padding: EdgeInsets.all(AppSpacing.md),
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.lg)),
  child: Text('Hello', style: AppTextStyles.heading2),
)

// ❌ WRONG
Container(color: Color(0xFF1A1A1A), padding: EdgeInsets.all(16))
Text('Hello', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
```

### Interactive Elements (AppTapWidget with semantic params)
```dart
// ✅ CORRECT - semanticLabel and semanticHint are REQUIRED
AppTapWidget(
  onTap: onTap,
  semanticLabel: AppLocalizations.of(context).authSemanticAppleButton,
  semanticHint: AppLocalizations.of(context).authSemanticAppleButtonHint,
  child: Container(...),
)

// ❌ WRONG
GestureDetector(onTap: onTap, child: ...) // Use AppTapWidget!
InkWell(onTap: onTap, child: ...) // Use AppTapWidget!
```

### Widget Organization (NO _build* methods)
```dart
// ❌ WRONG - private build methods
class MyScreen extends StatelessWidget {
  Widget _buildHeader() { ... }
  Widget _buildContent() { ... }
}

// ✅ CORRECT - extract to separate widget files
// lib/features/my_feature/presentation/widgets/my_header.dart
class MyHeader extends StatelessWidget { ... }
```

### Scrollable Content (ALWAYS BouncingScrollPhysics)
```dart
// ✅ CORRECT
SingleChildScrollView(
  physics: const BouncingScrollPhysics(),
  child: ...,
)
```

### Logging (AppLogger, NOT print)
```dart
import 'package:museo_mobile/core/tools/logger.dart';

// ✅ CORRECT
AppLogger.info('Operation completed');
AppLogger.debug('Details...', prefix: LogPrefix.api);
AppLogger.error(e); // MANDATORY in catch blocks

// ❌ WRONG
print('Data saved');
```

## Translations & Accessibility

**For EVERY interactive element, create 3 keys in `assets/localizations/intl_en.arb`:**

```json
{
  "featureAction": "Button Text",
  "featureSemanticButton": "Descriptive semantic label",
  "featureSemanticButtonHint": "Double tap to [specific action]"
}
```

**Run `flutter gen-l10n` after changes.**

## Core Widgets Reference

| Widget | Use Instead Of |
|--------|---------------|
| `AppTapWidget` | GestureDetector, InkWell |
| `AppScaffold` | Scaffold |
| `AppLoadingIndicator` | CircularProgressIndicator |
| `SelectableItem` | Custom selection styling |
| `AppBottomSheet.show()` | showModalBottomSheet |
| `AppSnackBar.showError()` | ScaffoldMessenger |

## Pre-Commit Checklist

- [ ] `flutter analyze` passes with zero warnings
- [ ] `flutter pub run build_runner build` after model changes
- [ ] `flutter gen-l10n` after translation changes
- [ ] Result<T> pattern in Cubits (no try-catch)
- [ ] AppTapWidget with semanticLabel/semanticHint from translations
- [ ] AppLogger.error(e) in all catch blocks
- [ ] No _build* methods - extract to widget classes
- [ ] AppColors, AppTextStyles, AppSpacing (no hardcoded values)

## Additional Documentation

For detailed guidelines, see:
- `claude_agents_example/AI_PROGRAMMING_GUIDELINES.md` - Complete architecture rules
- `claude_agents_example/code_review_2.md` - Code review patterns
- `claude_agents_example/wcag_review_1.md` - WCAG accessibility checklist
- `BUILD_INSTRUCTIONS.md` - Code generation troubleshooting

## Notes

- Portrait orientation only
- Multi-language: en, de, es, fr, it, pl
- Dark/light mode support via theme system
- WCAG 2.1 AA accessibility compliance required
