# AI Programming Guidelines - Museo Mobile

This document provides comprehensive guidelines for AI assistants working with the **museo_mobile** Flutter project. These rules enforce Clean Architecture principles, accessibility standards, and code quality requirements.

## 🏗️ Clean Architecture Implementation Rules

### Domain Layer Guidelines

#### **Entities (Pure Business Objects)**

```dart
// ✅ CORRECT - Abstract class with freezed
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required AuthProvider provider,
    String? displayName,
    String? photoUrl,
  }) = _User;
}

// ❌ WRONG - Regular class without freezed
class User {
  final String id;
  final String email;
  User({required this.id, required this.email});
}
```

**Rules:**

- ✅ **MUST** use `@freezed` annotation
- ✅ **MUST** declare as `abstract class` (not just `class`)
- ✅ **MUST** be pure data objects with NO business logic
- ✅ **MUST** use immutable data structures
- ✅ **MUST** be located in `lib/features/{feature}/domain/entities/`

#### **Repositories (Domain Interfaces)**

```dart
// ✅ CORRECT - Abstract interface returning Result<T>
abstract class AuthRepository {
  Future<Result<User>> signInWithApple();
  Future<Result<User>> signInWithGoogle();
  Future<Result<void>> signOut();
}

// ❌ WRONG - Concrete implementation or no Result<T>
class AuthRepository {
  Future<User> signInWithApple() async { ... } // No Result wrapper!
}
```

**Rules:**

- ✅ **MUST** be abstract classes (interfaces)
- ✅ **MUST** return `Result<T>` for all operations that can fail
- ✅ **MUST** define business contracts, NOT implementation details
- ✅ **MUST** be located in `lib/features/{feature}/domain/repositories/`

#### **Use Cases (Business Logic)**

```dart
// ✅ CORRECT - Injectable use case with Result<T>
@injectable
class SignInWithApple {
  SignInWithApple(this.repository);

  final AuthRepository repository;

  Future<Result<User>> call() async {
    return repository.signInWithApple();
  }
}

// ❌ WRONG - Direct repository dependency or no injection
class SignInWithApple {
  Future<User> execute() async { ... } // No Result<T>!
}
```

**Rules:**

- ✅ **MUST** use `@injectable` annotation for dependency injection
- ✅ **MUST** have single responsibility (one business operation)
- ✅ **MUST** depend only on repository interfaces (NOT implementations)
- ✅ **MUST** return `Result<T>` types
- ✅ **MUST** use `call()` method for execution
- ✅ **MUST** be located in `lib/features/{feature}/domain/usecases/`

### Data Layer Guidelines

#### **Models (Data Transfer Objects)**

```dart
// ✅ CORRECT - Freezed model with JSON serialization
@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String provider,
    String? displayName,
    String? photoUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// Extension for entity conversion
extension UserModelX on UserModel {
  User toEntity() {
    return User(
      id: id,
      email: email,
      provider: AuthProvider.values.firstWhere(
        (p) => p.name == provider,
      ),
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}
```

**Rules:**

- ✅ **MUST** use `@freezed` with JSON serialization
- ✅ **MUST** be abstract classes
- ✅ **MUST** provide `toEntity()` method via extension
- ✅ **MUST** handle primitive types (String, int, bool, etc.)
- ✅ **MUST** be located in `lib/features/{feature}/data/models/`

#### **Data Sources (External Data Access)**

```dart
// ✅ CORRECT - Data source returning Result<T>
abstract class AuthLocalDataSource {
  Future<Result<UserModel>> signInWithApple();
  Future<Result<void>> signOut();
}

@Injectable(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<Result<UserModel>> signInWithApple() async {
    try {
      // External API/database call
      final userData = await signInWithAppleSDK();
      return Success(UserModel.fromJson(userData));
    } catch (e) {
      return Failure('Authentication failed: ${e.toString()}');
    }
  }
}
```

**Rules:**

- ✅ **MUST** be abstract interfaces with implementations
- ✅ **MUST** use `@Injectable(as: Interface)` pattern
- ✅ **MUST** wrap all external calls in try-catch returning `Result<T>`
- ✅ **MUST** work with models (NOT entities)
- ✅ **MUST** handle all external exceptions
- ✅ **MUST** be located in `lib/features/{feature}/data/datasources/`

#### **Repository Implementations**

```dart
// ✅ CORRECT - Repository implementation with model-to-entity conversion
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.localDataSource);

  final AuthLocalDataSource localDataSource;

  @override
  Future<Result<User>> signInWithApple() async {
    final result = await localDataSource.signInWithApple();
    return result.map((userModel) => userModel.toEntity());
  }
}
```

**Rules:**

- ✅ **MUST** implement domain repository interface
- ✅ **MUST** use `@Injectable(as: Interface)` annotation
- ✅ **MUST** convert models to entities using `.map()` method
- ✅ **MUST** delegate to data sources
- ✅ **NEVER** contain business logic
- ✅ **MUST** be located in `lib/features/{feature}/data/repositories/`

### Presentation Layer Guidelines

#### **Cubit State Management**

```dart
// ✅ CORRECT - Freezed state with clear variants
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = Initial;
  const factory AuthState.loading() = Loading;
  const factory AuthState.loaded({
    required bool isAuthorized,
    User? user,
  }) = Loaded;
  const factory AuthState.error(String message) = Error;
}

// ✅ CORRECT - Cubit with Result<T> pattern (NO try-catch!)
@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.signInWithApple,
  }) : super(const AuthState.initial());

  final SignInWithApple signInWithApple;

  Future<void> signInApple() async {
    emit(const AuthState.loading());
    final result = await signInWithApple();
    result.when(
      success: (user) => emit(AuthState.loaded(isAuthorized: true, user: user)),
      failure: (message) => emit(AuthState.error(message)),
    );
  }
}
```

**Rules:**

- ✅ **MUST** use Cubit pattern (NOT Bloc)
- ✅ **MUST** use `@freezed` for state classes
- ✅ **MUST** use `@injectable` for cubits
- ✅ **MUST** use `result.when()` pattern (NEVER try-catch in cubits)
- ✅ **MUST** depend on use cases (NOT repositories directly)
- ✅ **MUST** emit loading states before async operations
- ✅ **MUST** be located in `lib/features/{feature}/presentation/cubit/`

#### **Immutable State Management (CRITICAL)**

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

#### **BlocBuilder Optimization (CRITICAL)**

```dart
// ✅ CORRECT - Multiple smaller BlocBuilders targeting specific state parts
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Each section has its own BlocBuilder with buildWhen
        _HeaderBuilder(),
        _ContentBuilder(),
        _FooterBuilder(),
      ],
    );
  }
}

class _HeaderBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCubit, MyState>(
      buildWhen: (previous, current) => previous.title != current.title,
      builder: (context, state) => Text(state.title),
    );
  }
}

class _ContentBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCubit, MyState>(
      buildWhen: (previous, current) => previous.items != current.items,
      builder: (context, state) => ListView(
        children: state.items.map((item) => ItemWidget(item)).toList(),
      ),
    );
  }
}

class _FooterBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCubit, MyState>(
      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
      builder: (context, state) => state.isLoading
          ? AppLoadingIndicator()
          : SaveButton(),
    );
  }
}

// ❌ WRONG - Single BlocBuilder wrapping entire screen (rebuilds everything!)
class BadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyCubit, MyState>(
      builder: (context, state) {
        return Scaffold(  // Entire scaffold rebuilds on ANY state change!
          appBar: AppBar(title: Text(state.title)),
          body: ListView(children: state.items.map(...).toList()),
          bottomNavigationBar: state.isLoading ? Loading() : Button(),
        );
      },
    );
  }
}
```

**BlocBuilder Rules:**

- ✅ **MUST** use `buildWhen` to filter rebuilds based on relevant state changes
- ✅ **MUST** place BlocBuilders close to the widgets they control
- ✅ **MUST** prefer 5 smaller BlocBuilders over 1 large one at the top
- ✅ **MUST** extract BlocBuilder widgets into separate classes (e.g., `_HeaderBuilder`)
- ✅ **NEVER** wrap entire Scaffold/Screen in a single BlocBuilder
- ✅ **NEVER** rebuild static content when only dynamic content changes

**Performance Impact:**
- Single BlocBuilder at top → Rebuilds 100% of UI on any change
- Multiple targeted BlocBuilders → Rebuilds only affected widgets (5-20%)

#### **Widget Implementation**

```dart
// ✅ CORRECT - Widget using core components with accessibility
class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          Semantics(
            header: true,
            child: Text(
              AppLocalizations.of(context).authWelcome,
              style: AppTextStyles.heading1,
            ),
          ),
          AppTapWidget(
            onTap: () => context.read<AuthCubit>().signInApple(),
            semanticLabel: AppLocalizations.of(context).authSemanticAppleButton,
            semanticHint: AppLocalizations.of(context).authSemanticAppleButtonHint,
            borderRadius: AppRadius.md,
            child: Container(...),
          ),
        ],
      ),
    );
  }
}
```

**Rules:**

- ✅ **MUST** use `AppScaffold` instead of `Scaffold`
- ✅ **MUST** use `AppTapWidget` for ALL interactive elements
- ✅ **MUST** use `AppColors.instance.*` for colors
- ✅ **MUST** use `AppTextStyles.*` for typography
- ✅ **MUST** use translation keys for ALL text
- ✅ **MUST** provide semantic labels from translations
- ✅ **MUST** be located in `lib/features/{feature}/presentation/widgets/` or `/pages/`

#### **Feature-Specific Widget Patterns**

```dart
// ✅ CORRECT - Feature widget using core components
class AuthButton extends StatelessWidget {
  const AuthButton({
    required this.type,
    required this.onTap,
    super.key,
  });

  final AuthButtonType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeightMedium,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.scanButton,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: AppTapWidget(
          onTap: onTap,
          semanticLabel: _getSemanticLabel(context),
          semanticHint: _getSemanticHint(context),
          borderRadius: AppRadius.md,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _getIcon(context),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _getText(context),
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.instance.textOnAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSemanticLabel(BuildContext context) {
    return AppLocalizations.of(context).authSemanticEmailButton;
  }

  String _getSemanticHint(BuildContext context) {
    return AppLocalizations.of(context).authSemanticEmailButtonHint;
  }

  Widget _getIcon(BuildContext context) {
    return Icon(
      Icons.email_outlined,
      color: AppColors.instance.iconOnAccent,
      size: AppSizes.iconMedium,
      semanticLabel: AppLocalizations.of(context).authSemanticEmailIcon,
    );
  }

  String _getText(BuildContext context) {
    return AppLocalizations.of(context).authSignInWithEmail;
  }
}

// ❌ WRONG - Feature widget with hardcoded values and missing accessibility
class BadAuthButton extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(
      height: 48,                    // Use AppSizes.buttonHeightMedium!
      color: Colors.blue,            // Use AppColors.instance.*!
      child: GestureDetector(        // Use AppTapWidget!
        onTap: onTap,
        child: Text('Sign in'),      // Missing translations and semantics!
      ),
    );
  }
}
```

**Feature Widget Rules:**
- ✅ **MUST** compose with core components (no reinventing)
- ✅ **MUST** use helper methods for translations (`_getSemanticLabel()`, `_getText()`)
- ✅ **MUST** use enum patterns for widget variants (`AuthButtonType`)
- ✅ **MUST** follow consistent naming: `{Feature}{Widget}` (e.g., `AuthButton`, `LanguageSelector`)
- ✅ **MUST** implement proper constructor patterns with required parameters first

## 🎨 Core Component Usage Guidelines

### Theme System (MANDATORY Usage)

#### **Colors**

```dart
// ✅ CORRECT - AppColors enum system
Container(
  color: AppColors.instance.backgroundPrimary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.instance.textPrimary),
  ),
)

// ❌ WRONG - Hardcoded colors
Container(
  color: Color(0xFF1A1A1A), // NEVER!
  child: Text('Hello', style: TextStyle(color: Colors.white)), // NEVER!
)
```

#### **Typography**

```dart
// ✅ CORRECT - AppTextStyles system
Text(
  'Welcome',
  style: AppTextStyles.heading2.copyWith(
    color: AppColors.instance.textPrimary,
  ),
)

// ❌ WRONG - Custom TextStyle
Text(
  'Welcome',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600), // NEVER!
)
```

#### **Spacing & Sizing**

```dart
// ✅ CORRECT - Using spacing and sizing constants
Padding(
  padding: EdgeInsets.all(AppSpacing.md),
  child: SizedBox(
    height: AppSizes.buttonHeightLarge,
    width: AppSizes.iconMedium,
    child: widget,
  ),
)

// ✅ CORRECT - Border radius constants
BorderRadius.circular(AppRadius.lg)

// ❌ WRONG - Hardcoded values
Padding(padding: EdgeInsets.all(16)) // Use AppSpacing.md!
BorderRadius.circular(12) // Use AppRadius.md!
```

### Widget Component Usage (MANDATORY)

#### **Interactive Elements**

```dart
// ✅ CORRECT - AppTapWidget with REQUIRED semantic parameters
AppTapWidget(
  onTap: onTap,
  semanticLabel: AppLocalizations.of(context).authSemanticAppleButton,    // REQUIRED!
  semanticHint: AppLocalizations.of(context).authSemanticAppleButtonHint, // REQUIRED!
  borderRadius: AppRadius.md,
  child: Container(...),
)

// ❌ WRONG - GestureDetector or InkWell
GestureDetector(onTap: onTap, child: Container(...)) // NEVER!
InkWell(onTap: onTap, child: Container(...)) // NEVER!

// ❌ WRONG - Missing semantic parameters (COMPILATION ERROR!)
AppTapWidget(onTap: onTap, child: Container(...)) // ERROR!
```

#### **Buttons**

```dart
// ✅ CORRECT - PrimaryCTAButton for main actions
PrimaryCTAButton(
  text: AppLocalizations.of(context).authContinue,
  semanticLabel: AppLocalizations.of(context).authSemanticContinueButton,
  semanticHint: AppLocalizations.of(context).authSemanticContinueButtonHint,
  onTap: onContinue,
)

// ❌ WRONG - ElevatedButton or custom buttons
ElevatedButton(onPressed: onContinue, child: Text('Continue')) // NEVER!
```

#### **Selectable Items**

```dart
// ✅ CORRECT - SelectableItem with semantic parameters
SelectableItem(
  isSelected: isSelected,
  semanticLabel: AppLocalizations.of(context).languageItemSemanticLabel,
  semanticHint: isSelected
    ? AppLocalizations.of(context).languageItemSemanticSelected
    : AppLocalizations.of(context).languageItemSemanticUnselected,
  onTap: onTap,
  child: Text(item.name),
)

// ❌ WRONG - Manual selection styling
Container(
  decoration: BoxDecoration(
    color: isSelected ? Colors.blue : Colors.transparent, // Use SelectableItem!
  ),
)
```

#### **Loading States**

```dart
// ✅ CORRECT - AppLoadingIndicator
Center(child: AppLoadingIndicator())
AppLoadingIndicator(color: Colors.black, size: 24)

// ❌ WRONG - CircularProgressIndicator
CircularProgressIndicator() // NEVER!
```

#### **Scaffolds and Layouts**

```dart
// ✅ CORRECT - AppScaffold with background options
AppScaffold(
  body: content,
  showBackground: true,        // Enable gradient background
  showBottomGradient: true,    // Enable bottom overlay gradient
  backgroundColor: AppColors.instance.backgroundPrimary,
)

// ❌ WRONG - Raw Scaffold
Scaffold(body: content) // Use AppScaffold!
```

#### **Scrollable Content (MANDATORY)**

```dart
// ✅ CORRECT - Always use BouncingScrollPhysics for scrollable content
SingleChildScrollView(
  physics: const BouncingScrollPhysics(),
  child: Column(
    children: [...],
  ),
)

ListView.builder(
  physics: const BouncingScrollPhysics(),
  itemBuilder: (context, index) => ...,
)

CustomScrollView(
  physics: const BouncingScrollPhysics(),
  slivers: [...],
)

// ❌ WRONG - Missing BouncingScrollPhysics
SingleChildScrollView(
  child: Column(...), // Missing physics!
)

ListView.builder(
  itemBuilder: ... // Missing physics!
)
```

**Scrollable Content Rules:**
- ✅ **MUST** always add `physics: const BouncingScrollPhysics()` to all scrollable widgets
- ✅ **MUST** apply to: `SingleChildScrollView`, `ListView`, `GridView`, `CustomScrollView`
- ✅ **MUST** use `const` keyword for performance optimization
- This provides consistent iOS-style bouncing scroll behavior across the app

#### **Bottom Sheets**

```dart
// ✅ CORRECT - AppBottomSheet.show() with accessibility
AppBottomSheet.show(
  context: context,
  title: AppLocalizations.of(context).languageSelectorTitle,
  showHandle: true,
  showDivider: true,
  showCloseButton: true,
  child: content,
)

// ✅ CORRECT - AppBottomSheet.showLarge() for larger content
AppBottomSheet.showLarge(
  context: context,
  heightFactor: 0.8,
  title: AppLocalizations.of(context).settingsTitle,
  child: content,
)

// ✅ CORRECT - Close bottom sheet
AppBottomSheet.close(context, result);

// ❌ WRONG - showModalBottomSheet
showModalBottomSheet(context: context, builder: (context) => content) // Use AppBottomSheet!
```

#### **Snack Bars & Messages**

```dart
// ✅ CORRECT - AppSnackBar with types
AppSnackBar.showSuccess(
  context: context,
  message: AppLocalizations.of(context).authSuccessMessage,
)

AppSnackBar.showError(
  context: context,
  message: AppLocalizations.of(context).authErrorMessage,
  actionLabel: AppLocalizations.of(context).authRetry,
  onActionPressed: () => retryAction(),
)

AppSnackBar.showWarning(
  context: context,
  message: AppLocalizations.of(context).authWarningMessage,
)

AppSnackBar.showInfo(
  context: context,
  message: AppLocalizations.of(context).authInfoMessage,
)

// ❌ WRONG - ScaffoldMessenger
ScaffoldMessenger.of(context).showSnackBar(...) // Use AppSnackBar!
```

#### **Gradients & Visual Effects**

```dart
// ✅ CORRECT - Using AppGradients
Container(
  decoration: BoxDecoration(
    gradient: AppGradients.scanButton,         // Predefined gradients
    borderRadius: BorderRadius.circular(AppRadius.md),
  ),
)

// Available gradients:
// AppGradients.premiumBanner
// AppGradients.bottomFade
// AppGradients.scanButton
// AppGradients.imageOverlay
// AppGradients.museumBackground
// AppGradients.scaffoldBottomOverlay
// AppGradients.scaffoldFullBackground

// ❌ WRONG - Custom gradients
LinearGradient(colors: [Color(0xFF...), Color(0xFF...)]) // Use AppGradients!
```

## 🌐 Internationalization & Accessibility Rules

### Translation Keys (MANDATORY Pattern)

#### **Semantic Accessibility Pattern**

For EVERY interactive element, create 3 translation keys:

```json
{
  "authSignInWithApple": "Sign in with Apple",

  "authSemanticAppleButton": "Sign in with Apple",
  "authSemanticAppleButtonHint": "Double tap to sign in with your Apple ID",
  "authSemanticAppleLogo": "Apple logo"
}
```

**Naming Convention:**

- `{feature}{ElementName}`: Display text
- `{feature}Semantic{ElementName}Button`: Semantic label
- `{feature}Semantic{ElementName}ButtonHint`: Interaction hint
- `{feature}Semantic{ElementName}Icon`: Icon description

#### **Translation Implementation Rules**

```dart
// ✅ CORRECT - Using translation keys
AppTapWidget(
  onTap: onTap,
  semanticLabel: AppLocalizations.of(context).authSemanticAppleButton,
  semanticHint: AppLocalizations.of(context).authSemanticAppleButtonHint,
  child: Row(
    children: [
      Icon(
        Icons.apple,
        semanticLabel: AppLocalizations.of(context).authSemanticAppleLogo,
      ),
      Text(AppLocalizations.of(context).authSignInWithApple),
    ],
  ),
)

// ❌ WRONG - Hardcoded text
AppTapWidget(
  semanticLabel: 'Sign in with Apple', // Use translation!
  child: Text('Sign in with Apple'), // Use translation!
)
```

### Accessibility Implementation (MANDATORY)

#### **Screen Headers**

```dart
// ✅ CORRECT - Headers with semantic annotation
Semantics(
  header: true,
  child: Text(
    AppLocalizations.of(context).authWelcomeTitle,
    style: AppTextStyles.heading1,
  ),
)

// ❌ WRONG - Text without header semantics
Text('Welcome', style: AppTextStyles.heading1) // Missing header!
```

#### **Icons**

```dart
// ✅ CORRECT - Informational icons
Icon(
  Icons.error,
  semanticLabel: AppLocalizations.of(context).errorIconSemanticLabel,
)

// ✅ CORRECT - Decorative icons
ExcludeSemantics(
  child: Icon(Icons.arrow_forward), // Purely decorative
)

// ❌ WRONG - Icon without semantic consideration
Icon(Icons.error) // Will announce "error" - needs semantic label!
```

#### **Form Fields**

```dart
// ✅ CORRECT - Accessible form field
TextFormField(
  decoration: InputDecoration(
    labelText: AppLocalizations.of(context).authEnterYourEmail,
  ),
  validator: (value) {
    if (hasError) {
      SemanticsService.announce(
        AppLocalizations.of(context).authEmailValidationError,
        TextDirection.ltr,
      );
    }
    return errorText;
  },
)

// ❌ WRONG - Form field without accessibility
TextField() // Missing labelText and validation feedback!
```

## 🔨 Error Handling Rules

### Flat Structure Pattern (MANDATORY)

When handling multiple `Result<T>` values, use early returns with `is Failure` checks instead of nested `.when()` callbacks. This creates a flat, readable structure.

```dart
// ✅ CORRECT - Flat structure with early returns
Future<Result<int>> call(String uploadId) async {
  try {
    final uploadResult = await _datasource.getUpload(uploadId);
    if (uploadResult is Failure<UploadDTO?>) {
      return Failure(uploadResult.message);
    }

    final upload = (uploadResult as Success<UploadDTO?>).data;
    if (upload == null) {
      return const Failure('Upload not found');
    }

    final photosResult = await _datasource.getPhotos(uploadId);
    if (photosResult is Failure<List<PhotoDTO>>) {
      return Failure(photosResult.message);
    }

    final photos = (photosResult as Success<List<PhotoDTO>>).data;
    // Continue with flat logic...

    return Success(photos.length);
  } on Exception catch (e) {
    AppLogger.error(e);
    return Failure('Operation failed: $e');
  }
}

// ❌ WRONG - Deeply nested .when() callbacks
Future<Result<int>> call(String uploadId) async {
  try {
    final uploadResult = await _datasource.getUpload(uploadId);

    return uploadResult.when(
      success: (upload) async {
        if (upload == null) {
          return const Failure('Upload not found');
        }

        final photosResult = await _datasource.getPhotos(uploadId);

        return photosResult.when(
          success: (photos) async {
            // Deeply nested - hard to read and maintain!
            return Success(photos.length);
          },
          failure: Failure.new,
        );
      },
      failure: Failure.new,
    );
  } on Exception catch (e) {
    return Failure('Operation failed: $e');
  }
}
```

**Flat Structure Rules:**
- ✅ **MUST** use `is Failure<T>` checks with early returns
- ✅ **MUST** cast to `Success<T>` to access `.data`
- ✅ **MUST** specify generic type in `Failure<T>` and `Success<T>` for type safety
- ✅ **MUST** keep code at consistent indentation level
- ❌ **NEVER** nest more than one `.when()` callback
- ❌ **NEVER** use deeply indented result handling

### Result<T> Pattern (MANDATORY)

#### **Domain/Data Layer**

```dart
// ✅ CORRECT - Using Result<T> everywhere
Future<Result<User>> signInWithApple() async {
  try {
    final user = await authService.signIn();
    return Success(user);
  } catch (e) {
    return Failure('Authentication failed: ${e.toString()}');
  }
}

// ❌ WRONG - Throwing exceptions
Future<User> signInWithApple() async {
  final user = await authService.signIn(); // Can throw!
  return user;
}
```

### Typed Failure Classes (RECOMMENDED)

For complex error handling, use typed failure classes instead of string messages. This allows the UI layer to handle specific errors appropriately.

#### **Defining Typed Failures**

```dart
// lib/core/tools/exceptions/failures.dart

/// Base failure class
sealed class AppFailure {
  const AppFailure();
}

/// Network-related failures
class NetworkFailure extends AppFailure {
  const NetworkFailure([this.message]);
  final String? message;
}

/// Validation failures with field-specific errors
class ValidationFailure extends AppFailure {
  const ValidationFailure(this.field, this.code);
  final String field;
  final ValidationErrorCode code;
}

enum ValidationErrorCode {
  required,
  invalidFormat,
  tooShort,
  tooLong,
  alreadyExists,
}

/// Permission/authorization failures
class PermissionFailure extends AppFailure {
  const PermissionFailure(this.code);
  final PermissionErrorCode code;
}

enum PermissionErrorCode {
  notAuthorized,
  invalidStatus,
  resourceLocked,
}

/// Resource not found
class NotFoundFailure extends AppFailure {
  const NotFoundFailure(this.resourceType, [this.resourceId]);
  final String resourceType;
  final String? resourceId;
}
```

#### **Using Typed Failures in Data Layer**

```dart
// ✅ CORRECT - Return typed failures from datasource/repository
Future<Result<void>> deletePhoto(String photoId) async {
  try {
    final photo = await _sqlClient.query('photos', where: 'id = ?', whereArgs: [photoId]);

    if (photo.isEmpty) {
      return const Failure(NotFoundFailure('photo', photoId));
    }

    final status = photo.first['status'] as String;
    if (status != 'draft') {
      return const Failure(PermissionFailure(PermissionErrorCode.invalidStatus));
    }

    await _sqlClient.delete('photos', where: 'id = ?', whereArgs: [photoId]);
    return const Success(null);
  } on SocketException {
    return const Failure(NetworkFailure());
  } on Exception catch (e) {
    AppLogger.error(e);
    return Failure(NetworkFailure(e.toString()));
  }
}
```

#### **Handling Typed Failures in Cubit**

```dart
// ✅ CORRECT - Map failures to state with specific error handling
Future<void> deletePhoto(int index) async {
  final result = await _repository.deletePhoto(photoId);

  result.when(
    success: (_) => emit(state.copyWith(/* success state */)),
    failure: (failure) {
      final errorMessage = _mapFailureToMessage(failure);
      emit(state.copyWith(errorMessage: errorMessage));
    },
  );
}

String _mapFailureToMessage(AppFailure failure) {
  return switch (failure) {
    NetworkFailure() => 'Network error. Please check your connection.',
    NotFoundFailure(:final resourceType) => '$resourceType not found.',
    PermissionFailure(:final code) => switch (code) {
      PermissionErrorCode.invalidStatus => 'Cannot delete synced photos.',
      PermissionErrorCode.notAuthorized => 'You are not authorized.',
      PermissionErrorCode.resourceLocked => 'Resource is locked.',
    },
    ValidationFailure(:final field, :final code) => _mapValidationError(field, code),
    _ => 'An unexpected error occurred.',
  };
}
```

#### **Handling Typed Failures in UI (Widget Layer)**

```dart
// ✅ CORRECT - UI shows specific feedback based on failure type
BlocListener<PhotoCubit, PhotoState>(
  listenWhen: (prev, curr) => prev.failure != curr.failure && curr.failure != null,
  listener: (context, state) {
    final failure = state.failure;
    if (failure == null) return;

    switch (failure) {
      case NetworkFailure():
        AppSnackBar.showError(
          context: context,
          message: AppLocalizations.of(context).errorNetwork,
          actionLabel: AppLocalizations.of(context).retry,
          onActionPressed: () => context.read<PhotoCubit>().retry(),
        );
      case PermissionFailure(code: PermissionErrorCode.invalidStatus):
        _showCannotDeleteSyncedPhotoDialog(context);
      case NotFoundFailure():
        AppSnackBar.showWarning(
          context: context,
          message: AppLocalizations.of(context).errorPhotoNotFound,
        );
      default:
        AppSnackBar.showError(
          context: context,
          message: AppLocalizations.of(context).errorGeneric,
        );
    }
  },
  child: // ...
)
```

**Typed Failure Rules:**
- ✅ **MUST** use sealed classes for failure hierarchy
- ✅ **MUST** define specific failure types for different error categories
- ✅ **MUST** handle failure mapping in Cubit (not in UI directly)
- ✅ **MUST** use pattern matching (switch expressions) for clean handling
- ✅ **SHOULD** include error codes for machine-readable error identification
- ✅ **SHOULD** keep failure classes in `lib/core/tools/exceptions/`
- ❌ **NEVER** expose raw exception messages to UI

#### **Presentation Layer (Cubit)**

```dart
// ✅ CORRECT - result.when() pattern in Cubit
Future<void> signInApple() async {
  emit(const AuthState.loading());
  final result = await signInWithApple();
  result.when(
    success: (user) => emit(AuthState.loaded(user: user)),
    failure: (message) => emit(AuthState.error(message)),
  );
}

// ❌ WRONG - try-catch in Cubit
Future<void> signInApple() async {
  try {
    emit(const AuthState.loading());
    final user = await signInWithApple(); // NEVER try-catch in Cubit!
    emit(AuthState.loaded(user: user));
  } catch (e) {
    emit(AuthState.error(e.toString()));
  }
}
```

## 📦 Dependency Injection Rules

### Injectable Pattern (MANDATORY)

#### **Use Cases**

```dart
@injectable
class SignInWithApple {
  SignInWithApple(this.repository);
  final AuthRepository repository;
}
```

#### **Repository Implementations**

```dart
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this.dataSource);
  final AuthDataSource dataSource;
}
```

#### **Data Sources**

```dart
@Injectable(as: AuthDataSource)
class AuthDataSourceImpl implements AuthDataSource {
  // Implementation
}
```

#### **Cubits**

```dart
@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required this.signInWithApple}) : super(const AuthState.initial());
  final SignInWithApple signInWithApple;
}
```

### Registration Rules

- ✅ **MUST** run `flutter pub run build_runner build` after adding `@injectable`
- ✅ **MUST** register in `injection.dart` if using custom modules
- ✅ **MUST** use interfaces for repository and data source injection

## 🧪 Code Quality Rules

### Freezed Classes (CRITICAL)

```dart
// ✅ CORRECT - Abstract class declaration
@freezed
abstract class User with _$User {
  const factory User({required String id}) = _User;
}

// ❌ WRONG - Missing abstract keyword
@freezed
class User with _$User { // COMPILATION ERROR!
  const factory User({required String id}) = _User;
}
```

### Import Organization (MANDATORY)

```dart
// ✅ CORRECT - Import order
// 1. Flutter SDK imports
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 2. Package imports
import 'package:injectable/injectable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// 3. Relative imports
import '../../domain/entities/user.dart';
import '../widgets/auth_button.dart';
import 'auth_state.dart';

// ❌ WRONG - Mixed import order
import '../widgets/auth_button.dart';        // Should be last!
import 'package:flutter/material.dart';      // Should be first!
import '../../domain/entities/user.dart';
```

### Linting Compliance (MANDATORY)

- ✅ **MUST** run `flutter analyze` and fix ALL warnings
- ✅ **MUST** keep lines under 80 characters
- ✅ **MUST** use constructor ordering (constructors before methods)
- ✅ **MUST** use `.withValues()` instead of deprecated `.withOpacity()`

## 🚀 Development Workflow

### Before Starting ANY Feature

1. ✅ **Plan Clean Architecture layers** (domain → data → presentation)
2. ✅ **Create translation keys** for ALL text and semantic labels
3. ✅ **Design state management** using Cubit + Result<T> pattern
4. ✅ **Plan accessibility** (headers, semantics, touch targets ≥48dp)

### During Development

1. ✅ **Create domain layer first** (entities, repositories, use cases)
2. ✅ **Implement data layer** (models, data sources, repository implementations)
3. ✅ **Build presentation layer** (cubits, states, widgets)
4. ✅ **Use core components** (AppTapWidget, AppScaffold, etc.)
5. ✅ **Test accessibility** with screen reader as you build

### After Implementation

1. ✅ **Run `flutter analyze`** and fix ALL issues
2. ✅ **Run `flutter pub run build_runner build`** for code generation
3. ✅ **Run `flutter gen-l10n`** after translation changes
4. ✅ **Test with TalkBack/VoiceOver** for accessibility
5. ✅ **Register new dependencies** in injection configuration

### Code Generation Commands

```bash
# After Freezed changes
flutter pub run build_runner build

# After translation changes
flutter gen-l10n

# Clean regeneration (conflicts)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Navigation & Routing Rules (go_router)

#### **Route Definitions**
```dart
// ✅ CORRECT - Define routes in app_router.dart
static const String auth = '/auth';
static const String home = '/home';
static const String profile = '/profile/:userId';

// Route configuration with type safety
GoRoute(
  path: '/profile/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return ProfileScreen(userId: userId);
  },
)
```

#### **Navigation Patterns**
```dart
// ✅ CORRECT - Using go_router context extension
context.go('/home');                    // Replace current route
context.push('/profile/123');           // Add to stack
context.pop();                          // Go back
context.pushReplacement('/auth');       // Replace with new route

// ✅ CORRECT - Bottom sheet navigation
AppBottomSheet.show(
  context: context,
  child: LanguageSelector(
    onLanguageSelected: (language) {
      AppBottomSheet.close(context);
      // Handle language change
    },
  ),
)

// ❌ WRONG - Navigator.push directly
Navigator.push(context, MaterialPageRoute(...)); // Use context.push()!
```

### State Persistence Rules

#### **Shared Preferences Usage**
```dart
// ✅ CORRECT - Using SharedPreferencesClient via injection
@injectable
class UserPreferencesRepository {
  UserPreferencesRepository(this.sharedPreferencesClient);
  
  final SharedPreferencesClient sharedPreferencesClient;
  
  Future<Result<void>> saveUserLanguage(String languageCode) async {
    try {
      await sharedPreferencesClient.setString('user_language', languageCode);
      return const Success(null);
    } catch (e) {
      return Failure('Failed to save language: ${e.toString()}');
    }
  }
  
  Future<Result<String?>> getUserLanguage() async {
    try {
      final language = await sharedPreferencesClient.getString('user_language');
      return Success(language);
    } catch (e) {
      return Failure('Failed to load language: ${e.toString()}');
    }
  }
}

// ❌ WRONG - Direct SharedPreferences usage
SharedPreferences.getInstance(); // Use SharedPreferencesClient via DI!
```

## ⚠️ Common Violations (NEVER DO THESE!)

### Architecture Violations

- ❌ **try-catch in Cubits** → Use `result.when()` pattern
- ❌ **Direct repository calls from widgets** → Use use cases
- ❌ **Direct service calls from widgets** → Widgets can ONLY use Cubits, NEVER services directly
- ❌ **Business logic in widgets** → Move to domain layer
- ❌ **Entities in data layer** → Use models with `toEntity()` method

### UI/UX Violations

- ❌ **GestureDetector usage** → Use AppTapWidget
- ❌ **Raw Scaffold** → Use AppScaffold
- ❌ **Hardcoded colors** → Use AppColors.instance.\*
- ❌ **Custom TextStyle** → Use AppTextStyles.\*
- ❌ **Missing semantic labels** → Required for AppTapWidget

### Accessibility Violations

- ❌ **Hardcoded semantic text** → Use translation keys
- ❌ **Icons without semantics** → Add semanticLabel or ExcludeSemantics
- ❌ **Missing screen headers** → Use Semantics(header: true)
- ❌ **Small tap targets** → Minimum 48x48dp
- ❌ **Color-only indicators** → Add icons/text backup

### UI/UX Violations

- ❌ **showModalBottomSheet** → Use AppBottomSheet.show()
- ❌ **ScaffoldMessenger** → Use AppSnackBar methods
- ❌ **Custom gradients** → Use AppGradients predefined
- ❌ **Navigator.push** → Use context.go/push with go_router
- ❌ **SharedPreferences direct** → Use SharedPreferencesClient via DI

### Code Quality Violations

- ❌ **Freezed without abstract** → Always `abstract class`
- ❌ **Missing @injectable** → Required for DI
- ❌ **Wrong import order** → Flutter → packages → relative
- ❌ **Analyzer warnings** → Must fix ALL before committing

## 📋 Pre-Implementation Checklist

Before writing ANY code, verify:

**Architecture Planning:**

- [ ] Domain entities designed with @freezed
- [ ] Repository interfaces defined with Result<T>
- [ ] Use cases planned with single responsibility
- [ ] State management designed with Cubit pattern

**Translation Preparation:**

- [ ] All text keys added to intl_en.arb
- [ ] Semantic accessibility keys created
- [ ] Pattern: `{feature}Semantic{Element}Button/ButtonHint/Icon`

**Core Component Usage:**

- [ ] AppScaffold planned for layouts
- [ ] AppTapWidget planned for interactions
- [ ] AppColors/AppTextStyles/AppSpacing planned
- [ ] Loading states with AppLoadingIndicator
- [ ] Bottom sheets with AppBottomSheet
- [ ] Messages with AppSnackBar
- [ ] Gradients with AppGradients

**Accessibility Planning:**

- [ ] Screen headers identified with Semantics(header: true)
- [ ] Touch targets ≥48dp planned
- [ ] Icon semantics planned (informational vs decorative)
- [ ] Alternative actions for complex gestures

**CRITICAL:** This checklist MUST be completed before starting ANY feature implementation. Failure to follow these guidelines will result in architecture violations, accessibility issues, and code quality problems.

---

**Remember: These are not suggestions - they are MANDATORY requirements for maintaining museo_mobile's architecture integrity, accessibility compliance, and code quality standards.**
