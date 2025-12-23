# Build Instructions

## Code Generation Required

This project uses code generation for the following packages:
- **freezed**: For immutable data classes
- **injectable**: For dependency injection
- **json_serializable**: For JSON serialization

## Run Code Generation

After pulling these changes, you **MUST** run code generation:

```bash
# Install dependencies
flutter pub get

# Generate code (run this after any changes to freezed/injectable/json models)
flutter pub run build_runner build --delete-conflicting-outputs
```

## Files That Need Generation

The following files require code generation:

### Domain Layer
- `lib/features/auth/domain/entities/user.dart` → generates `user.freezed.dart`

### Data Layer
- `lib/features/auth/data/models/user_model.dart` → generates:
  - `user_model.freezed.dart`
  - `user_model.g.dart`

### Presentation Layer
- `lib/features/auth/presentation/cubit/auth_state.dart` → generates `auth_state.freezed.dart`

### Dependency Injection
- `lib/core/config_tools/injection.dart` → generates `injection.config.dart`

## Verify Build

After running build_runner, verify everything works:

```bash
# Run analysis
flutter analyze

# Run tests
flutter test

# Run the app
flutter run
```

## Common Issues

### Issue: Missing part files
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Issue: Conflicting outputs
**Solution**: Use the `--delete-conflicting-outputs` flag as shown above

### Issue: Injectable not finding dependencies
**Solution**: Make sure all classes are annotated with `@injectable` and the module is configured in `injection.dart`

## Clean Build (if needed)

If you encounter persistent issues:

```bash
# Clean everything
flutter clean
rm -rf .dart_tool/
flutter pub get

# Regenerate code
flutter pub run build_runner build --delete-conflicting-outputs
```
