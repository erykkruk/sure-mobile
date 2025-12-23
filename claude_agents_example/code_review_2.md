# Agent Review - Architectural Changes & Best Practices

## Clean Architecture Implementation

### Immutable State Management (CRITICAL)

All state in Cubits MUST be immutable. Data should be stored IN STATE, not in Cubit fields:

```dart
// ✅ CORRECT - Data stored in immutable state
@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;
  const factory UserState.loading() = _Loading;
  const factory UserState.loaded(User user) = _Loaded;  // User data IN state
  const factory UserState.error(String message) = _Error;
}

@injectable
class UserCubit extends Cubit<UserState> {
  UserCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const UserState.initial());

  final UserRepository _userRepository;

  // ✅ CORRECT - Access data from state using getter
  User? get currentUser => state.maybeWhen(
        loaded: (user) => user,
        orElse: () => null,
      );

  // ✅ CORRECT - Computed property from state
  bool get hasCompletedOnboarding =>
      currentUser?.onboardingCompleted ?? false;

  Future<void> fetchUser() async {
    emit(const UserState.loading());
    final result = await _userRepository.getCurrentUser();
    result.when(
      success: (user) => emit(UserState.loaded(user)),
      failure: (message) => emit(UserState.error(message)),
    );
  }
}

// ❌ WRONG - Mutable field in Cubit
@injectable
class BadUserCubit extends Cubit<UserState> {
  User? _cachedUser;  // NEVER store data in Cubit fields!

  Future<void> fetchUser() async {
    final result = await _repository.getCurrentUser();
    result.when(
      success: (user) {
        _cachedUser = user;  // WRONG! Store in state instead
        emit(UserState.loaded(user));
      },
      failure: (message) => emit(UserState.error(message)),
    );
  }
}
```

**Immutability Rules:**

- ✅ **MUST** store ALL data in freezed state classes
- ✅ **MUST** use getters to access data from current state
- ✅ **MUST** use `state.maybeWhen()` or `state.when()` to extract data
- ✅ **MUST** emit new state for any data changes
- ❌ **NEVER** store mutable data in Cubit class fields
- ❌ **NEVER** use `late` fields to cache data in Cubits
- ❌ **NEVER** modify state objects directly - always emit new state

### Error Handling Pattern

- **NEVER** use try-catch blocks in Cubits/presentation layer
- **ALWAYS** use Result<T> pattern in data sources
- **Pattern**: Data sources catch exceptions and return `Success<T>` or `Failure(message)`
- **Cubit implementation**: Use `result.when()` to handle success/failure cases

```dart
// ❌ Wrong - try-catch in Cubit
void sendOTP(String email) async {
  try {
    emit(Loading());
    await _dataSource.sendOTPEmail(email);
    emit(Loaded(otpSent: true, email: email));
  } catch (e) {
    emit(Error(e.toString()));
  }
}

// ✅ Correct - Result pattern
void sendOTP(String email) async {
  emit(Loading());
  final result = await _dataSource.sendOTPEmail(email);
  result.when(
    success: (_) => emit(Loaded(otpSent: true, email: email)),
    failure: (message) => emit(Error(message)),
  );
}
```

## Core Utilities Usage

### AppBottomSheet

- **Location**: `/lib/core/presentation/widgets/app_bottom_sheet.dart`
- **Usage**: Centralized bottom sheet management with consistent styling
- **Pattern**: Static show method with generic return type

```dart
// ✅ Use AppBottomSheet instead of showModalBottomSheet
AppBottomSheet.show<void>(
  context: context,
  heightFactor: 0.5,
  child: BlocProvider(
    create: (_) => getIt<EmailAuthCubit>(),
    child: const EmailLoginBottomSheet(),
  ),
);
```

### AppSnackBar

- **Location**: `/lib/core/presentation/widgets/app_snack_bar.dart`
- **Usage**: Typed snack bar system with predefined variants
- **Types**: success, error, warning, info

```dart
// ✅ Use typed snack bars
AppSnackBar.showError(
  context: context,
  message: AppLocalizations.of(context).authPleaseEnterValidEmail,
);

AppSnackBar.showSuccess(
  context: context,
  message: AppLocalizations.of(context).authWelcomeUser(user.displayName),
);
```

### AppScaffold

- **Location**: `/lib/core/presentation/widgets/app_scaffold.dart`
- **Usage**: Optimized scaffold with theme integration
- **Features**: Background gradients, bottom overlays, no unnecessary Stack layers

```dart
// ✅ Use AppScaffold with theme integration
AppScaffold(
  showBackground: true,
  showBottomGradient: true,
  body: SafeArea(child: YourContent()),
)
```

### Email Validation

- **Location**: `/lib/core/utils/email_validator.dart`
- **Features**: RFC-compliant regex supporting plus-addressing
- **Pattern**: Use with Form validation for immediate feedback

```dart
// ✅ Proper email validation
TextFormField(
  controller: _emailController,
  validator: EmailValidator.validate,
  // ... other properties
)

// ✅ Programmatic validation
if (EmailValidator.isValid(email)) {
  // Process email
}
```

## Theme System Integration

### Gradients

- **Location**: `/lib/core/presentation/theme/app_gradients.dart`
- **Types**: museumBackground, scaffoldBottomOverlay, scaffoldFullBackground
- **Usage**: Reference from theme instead of hardcoding

```dart
// ✅ Use theme gradients
decoration: BoxDecoration(
  gradient: AppGradients.museumBackground,
)
```

### Colors, Typography, Spacing & Sizing

- **Always** use theme constants from `/lib/core/presentation/theme/`:
  - `AppColors` - for all color values
  - `AppTextStyles` - for all text styling
  - `AppSpacing` - for margins, padding, gaps
  - `AppSizes` - for button heights, icon sizes, avatars
  - `AppRadius` - for border radius values
- **Never** hardcode any numeric values in presentation components
- **CRITICAL**: Never create custom TextStyle objects in presentation layer - always use predefined AppTextStyles
- **Pattern**: Use `.copyWith()` to modify existing styles when needed

```dart
// ✅ Correct - use predefined theme constants
Container(
  height: AppSizes.buttonHeightMedium,  // Instead of height: 52
  margin: EdgeInsets.all(AppSpacing.lg), // Instead of margin: EdgeInsets.all(16)
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.lg), // Instead of 16.0
    color: AppColors.instance.backgroundPrimary, // Instead of Color(0xFF1A1A1A)
  ),
  child: Icon(
    Icons.star,
    size: AppSizes.iconLarge, // Instead of size: 24
  ),
)

Text(
  'Welcome',
  style: AppTextStyles.heading2.copyWith(
    color: AppColors.instance.textPrimary,
  ),
)

// ❌ Wrong - hardcoded values
Container(
  height: 52, // Should use AppSizes.buttonHeightMedium
  margin: EdgeInsets.all(16), // Should use AppSpacing.lg
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(16.0), // Should use AppRadius.lg
    color: Color(0xFF1A1A1A), // Should use AppColors.instance.backgroundPrimary
  ),
  child: Icon(Icons.star, size: 24), // Should use AppSizes.iconLarge
)

// ❌ Wrong - creating custom TextStyle in presentation
Text(
  'Welcome',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  ),
)
```

## Internationalization (i18n) Best Practices

### Translation File Structure

- **Location**: `/assets/localizations/intl_en.arb`
- **Convention**: Feature-based prefixes for organization
- **Pattern**: `{feature}{ComponentOrAction}`

### Naming Conventions

#### Authentication Feature

```json
{
  "authHearTheStory": "Hear the\nstory.",
  "authSignInWithApple": "Sign in with Apple",
  "authSignInWithGoogle": "Sign in with Google",
  "authSignInWithEmail": "Sign in with email",
  "authEnterYourEmail": "Enter your email",
  "authContinue": "Continue",
  "authSending": "Sending...",
  "authPleaseEnterValidEmail": "Please enter a valid email address",
  "authVerificationCode": "Verification code",
  "authVerificationCodeSubtitle": "We'll send a verification code to your email",
  "authEnterVerificationCode": "Enter the verification code",
  "authResendCode": "Resend code",
  "authVerify": "Verify",
  "authVerifying": "Verifying...",
  "authTerms": "Terms of Service",
  "authPrivacy": "Privacy Policy",
  "authByContinuingYouAgreeToOur": "By continuing, you agree to our ",
  "authWelcomeUser": "Welcome, {displayName}!"
}
```

#### General App Content

```json
{
  "generalAppTitle": "Museo",
  "generalAnd": " and ",
  "generalCancel": "Cancel",
  "generalConfirm": "Confirm",
  "generalError": "Error",
  "generalSuccess": "Success"
}
```

#### Language Selector Feature

```json
{
  "languageSelectorTitle": "Select Language",
  "languageSelectorConfirm": "Confirm", 
  "languageSelectorRetry": "Retry",
  "languageSelectorError": "Error: {message}",
  "languageSelectorEnglish": "English",
  "languageSelectorPolish": "Polish"
}
```

#### **MANDATORY**: Semantic Accessibility Translation Keys

For EVERY interactive element, you MUST create semantic translation keys following this pattern:

```json
{
  // Authentication semantic keys
  "authSemanticAppleButton": "Sign in with Apple",
  "authSemanticAppleButtonHint": "Double tap to sign in with your Apple ID",
  "authSemanticGoogleButton": "Sign in with Google", 
  "authSemanticGoogleButtonHint": "Double tap to sign in with your Google account",
  "authSemanticEmailButton": "Sign in with email",
  "authSemanticEmailButtonHint": "Double tap to sign in with email address",
  "authSemanticContinueButton": "Continue button",
  "authSemanticContinueButtonHint": "Double tap to continue",
  "authSemanticBackButton": "Back button",
  "authSemanticBackButtonHint": "Double tap to go back to email input",
  
  // Language selector semantic keys
  "languageSelectorSemanticConfirmButton": "Confirm language selection",
  "languageSelectorSemanticConfirmButtonHint": "Double tap to confirm and apply selected language",
  "languageSelectorSemanticButton": "Language selector",
  "languageSelectorSemanticButtonHint": "Double tap to change app language",
  "languageSelectorSemanticSelectedLanguage": "Selected language",
  
  // SelectableItem semantic keys for language list items
  "languageItemSemanticLabel": "{languageName}",
  "languageItemSemanticHint": "Double tap to select {languageName} as app language",
  "languageItemSemanticSelected": "Selected language: {languageName}",
  "languageItemSemanticUnselected": "Double tap to select {languageName}",
  
  // General semantic keys (reusable)
  "generalSemanticCloseButton": "Close",
  "generalSemanticCloseButtonHint": "Double tap to close",
  "generalSemanticCloseIcon": "Close icon",
  "bottomSheetSemanticCloseButtonHint": "Double tap to close bottom sheet"
}
```

##### **CRITICAL**: Semantic Translation Naming Convention
- **Pattern**: `{feature}Semantic{ElementName}Button` for button labels
- **Pattern**: `{feature}Semantic{ElementName}ButtonHint` for interaction hints  
- **Pattern**: `{feature}Semantic{ElementName}Icon` for icon labels
- **ALWAYS** create both label and hint keys for interactive elements
- **ALWAYS** provide descriptive context in ARB descriptions

### Translation Generation Script

- **Location**: `/scripts/generate_translations.sh`
- **Usage**: Run after adding new translation keys
- **Command**: `./scripts/generate_translations.sh`

```bash
#!/bin/bash
echo "🌐 Generating translations..."
flutter gen-l10n
if [ $? -eq 0 ]; then
  echo "✅ Translations generated successfully"
else
  echo "❌ Failed to generate translations"
  exit 1
fi
```

### Translation Usage in Code

```dart
// ✅ Proper translation usage
Text(AppLocalizations.of(context).authHearTheStory)

// ✅ Parameterized translations
AppLocalizations.of(context).authWelcomeUser(user.displayName)

// ✅ Navigation and actions
AppLocalizations.of(context).authContinue
```

### **MANDATORY**: Semantic Accessibility Implementation

EVERY interactive element has BUILT-IN accessibility via AppTapWidget with required parameters:

```dart
// ✅ CORRECT - AppTapWidget with built-in accessibility (SIMPLIFIED!)
AppTapWidget(
  onTap: onTap,
  semanticLabel: AppLocalizations.of(context).authSemanticAppleButton,    // REQUIRED!
  semanticHint: AppLocalizations.of(context).authSemanticAppleButtonHint, // REQUIRED!
  borderRadius: AppRadius.md,
  child: Container(...),
)

// ✅ CORRECT - Icon with semantic label
Icon(
  Icons.apple,
  color: Colors.white,
  semanticLabel: AppLocalizations.of(context).authSemanticAppleLogo, // Use translation!
)

// ✅ CORRECT - PrimaryCTAButton with semantic overrides
PrimaryCTAButton(
  text: AppLocalizations.of(context).authContinue,
  semanticLabel: AppLocalizations.of(context).authSemanticContinueButton,
  semanticHint: AppLocalizations.of(context).authSemanticContinueButtonHint,
  onTap: onContinue,
)

// ✅ CORRECT - SelectableItem with built-in accessibility
SelectableItem(
  isSelected: isSelected,
  semanticLabel: AppLocalizations.of(context).languageItemSemanticLabel,
  semanticHint: AppLocalizations.of(context).languageItemSemanticHint,
  onTap: onSelectLanguage,
  child: Row(
    children: [
      Text(language.nativeName),
      if (isSelected) Icon(Icons.check, semanticLabel: 'Selected'),
    ],
  ),
)

// ❌ WRONG - Missing required semantic parameters (COMPILATION ERROR!)
AppTapWidget(
  onTap: onTap,
  child: Container(...), // ERROR: semanticLabel and semanticHint are required!
)

// ❌ WRONG - SelectableItem without semantic parameters (COMPILATION ERROR!)
SelectableItem(
  isSelected: isSelected,
  onTap: onTap,
  child: Text('Item'), // ERROR: semanticLabel and semanticHint required!
)

// ❌ WRONG - Hardcoded semantic text
AppTapWidget(
  onTap: onTap,
  semanticLabel: 'Sign in with Apple',  // Should use translation key!
  semanticHint: 'Double tap to sign in', // Should use translation key!
  child: Container(...),
)
```

#### **CRITICAL**: Accessibility Translation Requirements

**Before implementing ANY interactive element:**
1. ✅ Create semantic label translation key: `{feature}Semantic{Element}Button`
2. ✅ Create semantic hint translation key: `{feature}Semantic{Element}ButtonHint`  
3. ✅ Add proper ARB descriptions explaining the context
4. ✅ Use AppTapWidget with REQUIRED semanticLabel and semanticHint parameters
5. ✅ Test with TalkBack/VoiceOver to verify proper announcements

**SIMPLIFIED**: No more manual Semantics wrapping! AppTapWidget enforces accessibility automatically with required translation parameters.

### Translation Descriptions Best Practices

**IMPORTANT**: Always provide clear, detailed descriptions for ambiguous words or context-dependent translations in the ARB file. This helps translators understand the exact meaning and usage context.

```json
{
  "authContinue": "Continue",
  "@authContinue": {
    "description": "Button text to proceed with email authentication flow"
  },
  "generalContinue": "Continue",
  "@generalContinue": {
    "description": "Generic continue button for forms and dialogs"
  },
  "authSending": "Sending...",
  "@authSending": {
    "description": "Progress text shown while OTP email is being sent to user"
  },
  "authVerifying": "Verifying...",
  "@authVerifying": {
    "description": "Progress text shown while OTP code is being verified"
  }
}
```

**Guidelines for descriptions**:
- **Context**: Explain where and when the text appears
- **Purpose**: Describe what action or state the text represents
- **Ambiguity resolution**: For words like "Continue", "Send", "Loading" - specify the exact context
- **Technical terms**: Explain technical concepts like "OTP", "verification code", etc.
- **User interaction**: Describe what happens when user interacts with the element

## URL Handling

- **Location**: `/lib/core/utils/launch_url_helper.dart`
- **Usage**: Centralized URL launching for terms, privacy, etc.
- **Pattern**: Static methods for specific actions

```dart
// ✅ Use LaunchUrlHelper
recognizer: TapGestureRecognizer()
  ..onTap = LaunchUrlHelper.launchTerms,
```

## Code Quality Standards

### Freezed Classes

- **CRITICAL**: Always declare as `abstract class`, not `class`
- **Pattern**: `abstract class User with _$User`

### Form Validation

- **Always** use `Form` widget with `GlobalKey<FormState>`
- **Always** use `TextFormField` with validator for inputs
- **Pattern**: Validate in onTap using `_formKey.currentState?.validate()`

### Import Organization

1. Package imports first (flutter, third-party)
2. Relative imports second (local files)
3. Alphabetical order within each group

### Theme Consistency Audit

Before any component is considered complete, perform this audit:

#### Hardcoded Values Checklist
- [ ] **Colors**: No `Color(0x...)`, `Colors.red`, etc. → Use `AppColors.instance.*`
- [ ] **Dimensions**: No numeric values for height, width, padding → Use `AppSizes.*` or `AppSpacing.*`
- [ ] **Border Radius**: No `BorderRadius.circular(16)` → Use `AppRadius.*`
- [ ] **Icon Sizes**: No `size: 24` → Use `AppSizes.icon*`
- [ ] **Text Styles**: No custom `TextStyle(...)` → Use `AppTextStyles.*`
- [ ] **Button Heights**: No `height: 50` → Use `AppSizes.buttonHeight*`

#### Common Violations to Fix
```dart
// ❌ Common violations found in components:
height: 54                    → height: AppSizes.buttonHeightMedium
padding: EdgeInsets.all(16)   → padding: EdgeInsets.all(AppSpacing.lg)
BorderRadius.circular(20)     → BorderRadius.circular(AppRadius.xl)
size: 24                      → size: AppSizes.iconLarge
width: 8                      → width: AppSpacing.sm
Color(0xFF1A1A1A)            → AppColors.instance.backgroundPrimary
fontSize: 16                  → Use AppTextStyles.button (already has fontSize)
```

#### Layout Structure Best Practices

**AVOID unnecessary Stack widgets** - Prefer simpler layouts when possible:

```dart
// ❌ Wrong - Unnecessary Stack for background + content
Stack(
  children: [
    BackgroundWidget(),
    ContentWidget(),
  ],
)

// ✅ Correct - Use Container with decoration + Column with Spacers
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('background.png'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        AppColors.instance.backgroundSecondary.withValues(alpha: 0.3),
        BlendMode.overlay,
      ),
    ),
  ),
  child: Column(
    children: [
      const Spacer(flex: 2),
      ContentWidget(),
      const Spacer(flex: 3),
      BottomWidget(),
    ],
  ),
)
```

**Stack Usage Guidelines:**
- **ONLY use Stack when elements truly need to overlap**
- **For background images**: Use Container with DecorationImage + overlays
- **For layout spacing**: Use Column/Row with Spacer widgets
- **For simple overlays**: Use Container with colorFilter instead of separate overlay widgets

#### Haptic Feedback Best Practices

**MANDATORY**: Add `HapticFeedback.mediumImpact()` to ALL interactive elements by default:

```dart
// ✅ Correct - Include haptic feedback for all user interactions
onTap: () {
  // Your action logic
  onPressed?.call();
  HapticFeedback.mediumImpact(); // Always add this
}

// ✅ Correct - Swipe gestures should also include feedback
void _handlePanEnd(BuildContext context, DragEndDetails details) {
  final direction = deltaX > 0 ? SwipeDirection.right : SwipeDirection.left;
  context.read<SomeCubit>().handleSwipe(direction);
  HapticFeedback.mediumImpact(); // Add for swipe feedback
}

// ✅ Correct - Button taps, navigation, selections
AppTapWidget(
  onTap: () {
    onItemSelected();
    HapticFeedback.mediumImpact(); // Confirm selection
  },
  child: ...,
)
```

**Import Required:**
```dart
import 'package:flutter/services.dart'; // Add to all interactive widgets
```

**Haptic Feedback Guidelines:**
- **`HapticFeedback.mediumImpact()`**: Default for buttons, taps, swipes, selections
- **`HapticFeedback.lightImpact()`**: Only for very subtle interactions (progress dots, etc.)
- **`HapticFeedback.heavyImpact()`**: Only for critical actions (delete, submit, etc.)
- **NEVER skip haptic feedback** - users expect tactile response on mobile devices

### Linter Compliance

- **ALWAYS** run `flutter analyze` after changes
- **ALWAYS** fix ALL analyzer warnings
- **Remove** unused imports, variables, methods
- **Follow** line length limits (80 characters)
- **Use** proper constructor ordering
- **Avoid** redundant default values

### Logging Best Practices

- **MANDATORY**: Use `AppLogger` instead of `print()` statements
- **ALWAYS** add `AppLogger.error()` in catch blocks for proper error tracking
- **ALWAYS** use `LogPrefix.*` constants for module-specific logs
- **Pattern**: Use appropriate log levels and prefixes for different scenarios

```dart
// ✅ Correct - AppLogger with LogPrefix for module-specific logs
AppLogger.debug(
  'Fetching nearby museums at: $lat, $lng',
  prefix: LogPrefix.museum,
);

AppLogger.debug(
  'API request: GET /museums',
  prefix: LogPrefix.api,
);

// ✅ Correct - AppLogger.error in catch blocks
try {
  final result = await apiCall();
  return Success(result);
} catch (e) {
  AppLogger.error(e);  // MANDATORY for error tracking
  return Failure('Operation failed: ${e.toString()}');
}

// ❌ Wrong - Hardcoded emoji prefixes
AppLogger.log('🏛️ API CALL: ...');  // Use LogPrefix.museum instead!
AppLogger.log('📍 Location: ...');   // Use LogPrefix.location instead!

// ❌ Wrong - print statements in production
print('Data saved');           // Use AppLogger.info()!

// ❌ Wrong - catch without logging
try {
  await operation();
} catch (e) {
  return Failure(e.toString()); // Missing AppLogger.error(e)!
}
```

**Import Required:**
```dart
import 'package:museo_mobile/core/tools/logger.dart';
```

**Log Levels:**
- **`AppLogger.error()`**: Exceptions, failures, critical issues
- **`AppLogger.info()`**: Important operations, user actions, state changes
- **`AppLogger.debug(message, prefix:)`**: Development debugging with module prefix
- **NEVER use `print()`** - it's not tracked and creates linter warnings

**Log Prefixes (Module Categories):**

Use `LogPrefix` constants to categorize logs. Prefixed logs can be muted in `logger.dart` `_mutedPrefixes` set.

| Prefix | Usage |
|--------|-------|
| `LogPrefix.database` | Database operations |
| `LogPrefix.network` | Network/HTTP operations |
| `LogPrefix.auth` | Authentication |
| `LogPrefix.navigation` | Navigation/routing |
| `LogPrefix.storage` | Local storage |
| `LogPrefix.sync` | Sync operations |
| `LogPrefix.bluetooth` | Bluetooth operations |
| `LogPrefix.camera` | Camera operations |
| `LogPrefix.museum` | Museum feature |
| `LogPrefix.location` | Location services |
| `LogPrefix.api` | API calls |

**Prefix Rules:**
- ✅ **MUST** use `LogPrefix.*` constants for module-specific logs
- ✅ **MUST** use `AppLogger.debug()` with prefix for verbose logs
- ✅ Mute noisy modules in `logger.dart` `_mutedPrefixes` set
- ❌ **NEVER** use hardcoded emoji prefixes in log messages
- ❌ **NEVER** log sensitive data (tokens, passwords, PII)

## Development Workflow

### After Making Changes

1. Run code generation: `flutter pub run build_runner build`
2. Generate translations: `flutter gen-l10n` or use script
3. Run analysis: `flutter analyze`
4. Fix all linter issues
5. Test the changes: `flutter run`

### When Adding New Features

1. Follow Clean Architecture layers (domain/data/presentation)
2. Use Result<T> pattern for error handling
3. Add translations with proper naming convention
4. Use core utilities (AppBottomSheet, AppSnackBar, etc.)
5. Follow theme system for styling
6. Register dependencies in injection.dart
7. Add routes to app_router.dart if needed
