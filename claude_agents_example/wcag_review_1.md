# Flutter WCAG Accessibility Checklist for Code Review (for Claude Agent)

This checklist ensures that Flutter apps meet **WCAG 2.1 AA** standards and accessibility best practices from the start of development.

---

## 🧭 Screen Reader Support (TalkBack / VoiceOver)

- [ ] **AUTOMATIC**: Use **`AppTapWidget`** with REQUIRED semantic parameters (enforced by compiler).
- [ ] **AUTOMATIC**: Use **`SelectableItem`** with REQUIRED semantic parameters (enforced by compiler).
- [ ] **MANDATORY**: Use translation keys for ALL semantic labels and hints (NEVER hardcode).
- [ ] **PATTERN**: Create `{feature}Semantic{Element}Button` and `{feature}Semantic{Element}ButtonHint` translation keys.
- [ ] Ensure all icons and images have meaningful `semanticLabel` descriptions from translations.
- [ ] Provide `hint` text for interactive elements (e.g. from `authSemanticAppleButtonHint`).
- [ ] Use **`MergeSemantics`** for grouping logically related elements.
- [ ] Use **`ExcludeSemantics`** to hide decorative or duplicate elements.
- [ ] Test with **TalkBack** (Android) and **VoiceOver** (iOS) on physical devices.
- [ ] Ensure all controls are operable and read aloud correctly.

### **SIMPLIFIED**: Built-in Accessibility with AppTapWidget

```dart
// ✅ CORRECT - AppTapWidget with built-in accessibility (REQUIRED parameters)
AppTapWidget(
  onTap: onTap,
  semanticLabel: AppLocalizations.of(context).authSemanticAppleButton,    // REQUIRED!
  semanticHint: AppLocalizations.of(context).authSemanticAppleButtonHint, // REQUIRED!
  child: Container(...),
)

// ❌ WRONG - Missing required parameters (COMPILATION ERROR!)
AppTapWidget(
  onTap: onTap,
  child: Container(...), // ERROR: semanticLabel and semanticHint required!
)

// ✅ CORRECT - SelectableItem with built-in accessibility
SelectableItem(
  isSelected: isSelected,
  semanticLabel: AppLocalizations.of(context).languageItemSemanticLabel,
  semanticHint: AppLocalizations.of(context).languageItemSemanticHint,
  onTap: onSelectLanguage,
  child: Text(language.nativeName),
)

// ❌ WRONG - Hardcoded semantic text
AppTapWidget(
  onTap: onTap,
  semanticLabel: 'Sign in with Apple',  // Should use translation!
  semanticHint: 'Double tap to sign in', // Should use translation!
  child: Container(...),
)

// ❌ WRONG - SelectableItem without semantic parameters (COMPILATION ERROR!)
SelectableItem(
  isSelected: isSelected,
  onTap: onTap,
  child: Text('Item'), // ERROR: semanticLabel and semanticHint required!
)
```

---

## 🎨 Color & Contrast

- [ ] **MANDATORY**: Verify text contrast ≥ **4.5:1** (normal text) or **3:1** (large text).
- [ ] Use color contrast analyzers to validate palette choices.
- [ ] Provide alternate indicators beyond color (icons, labels, text).
- [ ] Avoid using color alone to indicate state or error.
- [ ] Offer a **high-contrast mode** if possible.
- [ ] Test interface in grayscale and common color-blind modes.
- [ ] **CRITICAL**: All text must be readable according to WCAG AA standards (minimum 4.5:1 contrast ratio).

---

## 🔠 Text Scaling & Readability

- [ ] Do **not** override system `textScaleFactor`.
- [ ] Ensure layouts adapt gracefully up to **200–300%** font scale.
- [ ] Use responsive layouts (`Flexible`, `Expanded`, etc.) to avoid clipping text.
- [ ] Avoid fixed-size text containers.
- [ ] Don’t embed essential text inside images.
- [ ] Test with system “Large Text” / “Larger Accessibility Sizes” settings.

---

## 🧩 Semantic Structure

- [ ] Prefer built-in accessible widgets (`TextButton`, `Switch`, `Checkbox`, etc.).
- [ ] **MANDATORY**: Use `Semantics(header: true)` for section headers (equivalent to h1, h2, h3).
- [ ] Group related elements using `MergeSemantics`.
- [ ] Maintain logical widget order to match reading/focus order.
- [ ] Hide duplicate decorative content from screen readers.
- [ ] Check semantic tree in **Flutter DevTools → Semantics Debugger**.
- [ ] **CRITICAL**: Mark decorative elements with `ExcludeSemantics` or `Semantics(container: true, explicitChildNodes: false)`.
- [ ] **SCREEN TITLES**: Each screen must have a unique, descriptive title (not generic like "Profile" but "User Profile Settings").

---

## 🤲 Gestures & Navigation

- [ ] **CRITICAL**: Provide alternative actions for multi-touch or motion gestures (no swipe-only functionality).
- [ ] Use standard and predictable navigation (bottom bar, drawer, back button).
- [ ] Ensure all tap targets ≥ **48x48dp** (Android) / **44x44pt** (iOS).
- [ ] Avoid requiring gestures not supported by assistive technologies.
- [ ] Enable keyboard navigation where applicable (`FocusNode`, `FocusableActionDetector`).
- [ ] Support both portrait and landscape orientations unless impossible.
- [ ] **MANDATORY**: Add alternative buttons for swipe-based actions (e.g., delete buttons instead of swipe-to-delete).

---

## 🎯 Focus Management & Context

- [ ] Maintain intuitive **focus traversal** order.
- [ ] Visibly indicate the focused element (highlight/border).
- [ ] Don't auto-navigate or shift context without user action.
- [ ] Announce significant changes using `SemanticsService.announce()`.
- [ ] Respect user's "Reduce Motion" preference (`MediaQuery.of(context).reduceMotion`).
- [ ] Limit flashing/moving content to avoid motion sensitivity triggers.
- [ ] **FORMS**: Screen reader should automatically focus on the first input field.
- [ ] **FORMS**: Error messages should be announced immediately when validation fails.

---

## 🗣️ Advanced Screen Reader Communication

### Action Description Patterns
- [ ] **MANDATORY**: Use specific action descriptions instead of generic ones:
  - ❌ "Confirm" → ✅ "Confirm language selection"
  - ❌ "Submit" → ✅ "Submit login form"  
  - ❌ "Save" → ✅ "Save profile changes"

### Element Announcement Order & Semantic Hint Patterns
- [ ] **PATTERN**: Natural English with clear actions:
  - ✅ "Language selector. Double tap to change app language"
  - ✅ "English selected" (for selected items) 
  - ✅ "English. Double tap to select English" (for unselected items)
  - ❌ "Selected language: English" (verbose)
  - ❌ "English to select double tap" (awkward word order)

#### **Semantic Hint Translation Patterns**
- [ ] **SELECTED ITEMS**: Use `{itemName} selected` format (concise and natural)
  - ✅ `"languageItemSelected": "{languageName} selected"`
  - ❌ `"Selected language: {languageName}"` (verbose)

- [ ] **ACTION BUTTONS**: Use `Double tap to {action}` format (natural English)
  - ✅ `"authAppleButtonHint": "Double tap to sign in with Apple ID"`
  - ✅ `"languageItemUnselected": "Double tap to select {languageName}"`
  - ✅ `"resendCodeButton": "Double tap to resend verification code"`
  - ✅ `"confirmButton": "Double tap to confirm and apply selected language"`
  - ❌ `"{item} to {action} double tap"` (awkward word order)

- [ ] **INPUT FIELDS**: Use descriptive instructions without "double tap"
  - ✅ `"otpInputHint": "Enter the 6-digit verification code sent to your email"`
  - ✅ `"emailInputHint": "Enter your email address"`
  - ❌ `"Email to enter double tap"` (not applicable for inputs)

### Decorative Content Exclusion
- [ ] **MANDATORY**: Exclude decorative elements from screen reader:
```dart
// ✅ Correct - decorative icon excluded
ExcludeSemantics(
  child: Icon(Icons.arrow_forward, color: Colors.grey),
)

// ✅ Correct - background decoration excluded  
Semantics(
  container: true,
  explicitChildNodes: false,
  child: DecorativeBackgroundWidget(),
)

// ❌ Wrong - decorative element will be announced
Icon(Icons.arrow_forward, color: Colors.grey) // Screen reader will say "arrow forward"
```

### Alternative Text for Images
- [ ] **INFORMATIONAL IMAGES**: Provide concise, specific descriptions of purpose/content:
  - ✅ "Product photo: Red sneakers, size 10"
  - ✅ "Chart showing 25% increase in sales"
  - ❌ "Image" or "Picture"
- [ ] **DECORATIVE IMAGES**: Mark with `ExcludeSemantics` or empty `semanticLabel: ''`

### Form Accessibility
- [ ] **AUTO-FOCUS**: First input field should receive focus when screen opens
- [ ] **ERROR ANNOUNCEMENTS**: Validation errors announced immediately via `SemanticsService.announce()`
- [ ] **FIELD LABELS**: Clear, descriptive labels for all inputs

```dart
// ✅ Correct form field with accessibility
Semantics(
  label: AppLocalizations.of(context).authEmailFieldLabel,
  hint: AppLocalizations.of(context).authEmailFieldHint,
  textField: true,
  child: TextFormField(
    autofocus: true, // Auto-focus first field
    decoration: InputDecoration(
      labelText: AppLocalizations.of(context).authEnterYourEmail,
      errorText: validationError,
    ),
    validator: (value) {
      if (hasError) {
        // Announce error immediately
        SemanticsService.announce(
          AppLocalizations.of(context).authValidationError,
          TextDirection.ltr,
        );
      }
      return validationError;
    },
  ),
)
```

---

## 🌍 WCAG 2.1 AA Key Criteria Alignment

- [ ] **Perceivable:** Alt texts, color contrast, text resizing, orientation flexibility.
- [ ] **Operable:** Keyboard focus, gesture alternatives, no time-based traps.
- [ ] **Understandable:** Clear labels, form hints, error messages, predictable behavior.
- [ ] **Robust:** Works with TalkBack, VoiceOver, switch devices, dynamic text sizes.

---

## 🧰 Accessibility Tools & Libraries

- [ ] Use Flutter’s **`meetsGuideline()`** tests for:
  - `androidTapTargetGuideline`
  - `iOSTapTargetGuideline`
  - `labeledTapTargetGuideline`
  - `textContrastGuideline`
- [ ] Enable **Semantics Debugger** or **DevTools a11y inspector** in debug mode.
- [ ] Integrate **`accessibility_tools`** package for live checks in development.
- [ ] Optionally add **`flutter_accessibility_scanner`** for automatic WCAG validation.
- [ ] Use Android’s **Accessibility Scanner** and iOS **Accessibility Inspector** before release.

---

## 🧪 Accessibility Testing Routine

- [ ] Test every screen with TalkBack and VoiceOver manually.
- [ ] Run automated a11y tests in CI using `meetsGuideline()` expectations.
- [ ] Include a11y verification in **code review checklists**.
- [ ] Test on various device settings (large text, high contrast, grayscale, reduced motion).
- [ ] Audit with Android and iOS accessibility tools regularly.
- [ ] Maintain accessibility as part of continuous QA – not a one-time task.

---

### ✅ Reference

Based on Flutter Accessibility Docs, WCAG 2.1 AA, and verified Flutter a11y libraries (2025).
