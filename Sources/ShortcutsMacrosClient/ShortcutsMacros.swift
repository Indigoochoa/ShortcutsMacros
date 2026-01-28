/// Public API for ShortcutsMacros
/// Import this in your code to use macros: `import ShortcutsMacros`

// MARK: - SimpleIntent Macro (Phase 1)

/// Generates AppIntent boilerplate from a simplified declaration.
///
/// This macro automatically generates:
/// - static title and description properties
/// - static parameterSummary
/// - wrapped perform() method with training guards and logging
///
/// Example:
/// ```swift
/// @SimpleIntent(
///     title: "Delete from Data Hub",
///     description: "Delete a value from the Data Hub",
///     category: "Data Hub",
///     keywords: ["delete", "remove", "clear"],
///     requiresConfirmation: true,
///     backgroundSupport: true
/// )
/// struct DeleteValueAction {
///     @IntentParameter(title: "Key", description: "The key to delete")
///     var key: String
///
///     @IntentParameter(title: "Delete All Matches", default: false)
///     var deleteAll: Bool
///
///     @IntentParameter(title: "Skip Confirmation", default: false)
///     var skipConfirmation: Bool
///
///     @MainActor
///     func perform() async throws -> IntentResult<IntentDialog> {
///         let count = try await MemoryActions.shared.deleteValue(
///             key: key,
///             deleteAll: deleteAll,
///             skipConfirmation: skipConfirmation,
///             confirmationHandler: { entryCount in
///                 try await requireConfirmation(
///                     "Are you sure you want to delete \(entryCount) entries?",
///                     errorMessage: "Delete requires confirmation."
///                 )
///             }
///         )
///         return .result(dialog: "Deleted \(count) entries")
///     }
/// }
/// ```
///
/// The macro generates an Intent named `DeleteValueIntent` from `DeleteValueAction`.
@attached(member, names: named(title), named(description), named(parameterSummary), named(perform))
public macro SimpleIntent(
    title: String,
    description: String,
    category: String,
    keywords: [String],
    requiresConfirmation: Bool = false,
    backgroundSupport: Bool = true
) = #externalMacro(
    module: "ShortcutsMacrosPlugin",
    type: "SimpleIntentMacro"
)

// MARK: - IntentParameter Attribute

/// Marks a property as an AppIntent parameter with metadata.
///
/// Used within @SimpleIntent declarations to specify parameter details.
///
/// Example:
/// ```swift
/// @IntentParameter(title: "Key", description: "The key to delete", required: true)
/// var key: String
///
/// @IntentParameter(title: "Count", default: 5)
/// var count: Int
/// ```
@attached(peer)
public macro IntentParameter(
    title: String,
    description: String = "",
    required: Bool = false,
    default: @autoclosure () -> Any? = nil
) = #externalMacro(
    module: "ShortcutsMacrosPlugin",
    type: "IntentParameterMacro"
)

// MARK: - Phase 2+ Macros (Placeholder declarations)

/// Generates AppEntity and EntityQuery boilerplate (Phase 2)
@attached(member)
public macro EntityIntent(
    name: String,
    pluralName: String = ""
) = #externalMacro(
    module: "ShortcutsMacrosPlugin",
    type: "EntityIntentMacro"
)

/// Generates SnippetIntent boilerplate (Phase 2)
@attached(member)
public macro SnippetIntent(
    title: String,
    defaultLimit: Int = 10
) = #externalMacro(
    module: "ShortcutsMacrosPlugin",
    type: "SnippetIntentMacro"
)

/// Standardizes confirmation patterns (Phase 3)
@attached(peer)
public macro ConfirmationFlow(
    message: String,
    fallback: String
) = #externalMacro(
    module: "ShortcutsMacrosPlugin",
    type: "ConfirmationFlowMacro"
)

/// Automatically generates ParameterSummary (Phase 3)
@attached(member)
public macro AutoSummary(_ template: String) = #externalMacro(
    module: "ShortcutsMacrosPlugin",
    type: "AutoSummaryMacro"
)
