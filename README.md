# ShortcutsMacros

Swift Macros for reducing App Intents boilerplate in Shortcuts Powerhouse.

## Overview

ShortcutsMacros provides compile-time code generation for App Intents, automatically generating:
- Static metadata (title, description, category)
- Parameter summaries
- Training mode guards
- Logging integration
- Entity and Query conformances
- Snippet intent support

## Features

### @SimpleIntent
Generates AppIntent boilerplate for basic CRUD operations.

**Expected code reduction**: 43-60%

```swift
@SimpleIntent(
    title: "Delete from Data Hub",
    description: "Delete a value",
    category: "Data Hub",
    keywords: ["delete", "remove"],
    backgroundSupport: true
)
struct DeleteValueAction {
    @IntentParameter(title: "Key")
    var key: String

    @MainActor
    func perform() async throws -> IntentResult<String> {
        // custom logic
    }
}
```

Generates:
- `DeleteValueIntent` AppIntent struct
- Static metadata properties
- Parameter summary
- Wrapped perform() with training guard and logging

### @EntityIntent (Coming Week 2)
Generates AppEntity + EntityQuery boilerplate.

**Expected code reduction**: 67%

### @SnippetIntent (Coming Week 2)
Generates SnippetIntent boilerplate.

**Expected code reduction**: 60%

### @IntentParameter
Marks parameters with metadata for code generation.

### @ConfirmationFlow (Coming Week 3)
Standardizes confirmation patterns.

### @AutoSummary (Coming Week 3)
Auto-generates ParameterSummary from template.

## Architecture Preserved

All macros preserve critical patterns:
- ✅ Training mode guards (`AppIntentsGuards.isTraining()`)
- ✅ Logging (`IntentLogger` calls)
- ✅ Path sanitization (`UserFacingSanitizer`)
- ✅ MainActor isolation on perform()
- ✅ Singleton service access patterns

## Implementation Timeline

**Phase 1 (Week 1)**:
- ✅ Package setup
- ✅ @SimpleIntent macro
- [ ] Convert DeleteValueIntent (proof of concept)

**Phase 2 (Week 2)**:
- @EntityIntent macro
- @SnippetIntent macro
- Convert 5 MemorySTORE intents

**Phase 3 (Week 3)**:
- @ConfirmationFlow macro
- @AutoSummary macro
- Convert entities and snippets

**Phase 4 (Week 4)**:
- Comprehensive testing
- Documentation
- Final conversions

## Testing

Uses Swift Testing framework with:
- Unit tests for macro expansion
- Compile tests
- Runtime tests
- Training mode safety tests

Run tests:
```bash
swift test
```

## Usage

Import in your intent files:
```swift
import ShortcutsMacros
```

Then annotate your action structs with `@SimpleIntent`.

## Known Limitations

- Currently only supports struct declarations
- Complex logic should remain in custom `perform()` methods
- Parameter summaries are auto-generated (can be overridden if needed)

## Future Enhancements

- Custom summary templates
- Validation macros
- Error handling patterns
- Snippet view generation
