ShortcutsMacros

Swift macros to reduce App Intents boilerplate

This package exists to eliminate repetitive AppIntent code by generating common metadata and patterns at compile time.

It focuses on:
	•	Reducing copy-paste
	•	Enforcing consistent intent structure
	•	Preserving safety and logging conventions
	•	Keeping custom logic explicit

⸻

What it generates

From a small annotated struct, the macro generates:
	•	Static metadata (title, description, category, keywords)
	•	Parameter summaries
	•	Training mode guards
	•	Logging hooks
	•	Entity + Query conformances (planned)
	•	SnippetIntent scaffolding (planned)

⸻

Example

Input

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

Generated
	•	DeleteValueIntent : AppIntent
	•	Static metadata
	•	ParameterSummary
	•	Training mode guard
	•	Logging wrapper around perform()

Your logic stays in perform().
Everything else is generated.

⸻

Design goals

These macros do not change behavior. They only standardize structure.

They preserve:
	•	AppIntentsGuards.isTraining()
	•	IntentLogger usage
	•	UserFacingSanitizer
	•	@MainActor isolation
	•	Existing service patterns

This package is intentionally conservative.
No magic. No runtime reflection. No DSLs.

⸻

Roadmap

Phase 1
	•	Package setup
	•	@SimpleIntent
	•	Proof of concept conversion (DaleteValueIntent)

Phase 2
	•	@EntityIntent
	•	@SnippetIntent
	•	Convert MemorySTORE intents

Phase 3
	•	@ConfirmationFlow
	•	@AutoSummary
	•	Entity + snippet support

Phase 4
	•	Tests
	•	Documentation
	•	Wider adoption in project

⸻

Testing

Uses Swift Testing with:
	•	Macro expansion tests
	•	Compile tests
	•	Runtime tests
	•	Training mode safety tests

Run:

swift test


⸻

Usage

Add the package and import it:

import ShortcutsMacros

Annotate your action struct:

@SimpleIntent(...)
struct MyAction { ... }


⸻

Known limitations
	•	Only supports struct declarations
	•	Complex logic must remain in perform()
	•	Parameter summaries are auto-generated (can be overridden later)
	•	Xcode macro plugin resolution is still unreliable in some setups

⸻

Future ideas
	•	Custom summary templates
	•	Validation macros
	•	Error handling patterns
	•	Snippet view generation



