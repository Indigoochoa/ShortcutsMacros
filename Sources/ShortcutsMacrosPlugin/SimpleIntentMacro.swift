import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Macro that generates AppIntent boilerplate from a simplified declaration
///
/// Usage:
/// ```swift
/// @SimpleIntent(
///     title: "Delete from Data Hub",
///     description: "Delete a value",
///     category: "Data Hub",
///     keywords: ["delete", "remove"],
///     requiresConfirmation: true,
///     backgroundSupport: true
/// )
/// struct DeleteValueAction {
///     @IntentParameter(title: "Key", description: "The key to delete")
///     var key: String
///
///     @MainActor
///     func perform() async throws -> IntentResult<IntentDialog> {
///         // custom logic
///     }
/// }
/// ```
public struct SimpleIntentMacro: MemberMacro {
    enum SimpleIntentMacroError: CustomStringConvertible, Error {
        case onlyApplicableToStruct
        case missingAttribute(String)
        case invalidAttributeValue(String)

        var description: String {
            switch self {
            case .onlyApplicableToStruct:
                return "@SimpleIntent can only be applied to structs"
            case .missingAttribute(let name):
                return "Missing required attribute: \(name)"
            case .invalidAttributeValue(let name):
                return "Invalid value for attribute: \(name)"
            }
        }
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw SimpleIntentMacroError.onlyApplicableToStruct
        }

        let arguments = node.arguments

        // Convert AttributeSyntax.Arguments to LabeledExprListSyntax
        let labeledArgs = arguments.flatMap { arg -> LabeledExprListSyntax? in
            arg.as(LabeledExprListSyntax.self)
        }

        // Parse macro arguments
        let title = try extractStringArgument("title", from: labeledArgs)
        let description = try extractStringArgument("description", from: labeledArgs)
        let category = try extractStringArgument("category", from: labeledArgs)
        let keywords = try extractArrayArgument("keywords", from: labeledArgs)
        _ = try extractBoolArgument("requiresConfirmation", from: labeledArgs, default: false)
        let backgroundSupport = try extractBoolArgument("backgroundSupport", from: labeledArgs, default: true)

        // Extract parameters from struct members
        let members = structDecl.memberBlock.members
        var parameters: [ParameterInfo] = []

        for member in members {
            if let varDecl = member.decl.as(VariableDeclSyntax.self) {
                // Look for @IntentParameter attribute
                if let paramInfo = parseIntentParameter(from: varDecl) {
                    parameters.append(paramInfo)
                }
            }
        }

        // Generate AppIntent members
        var generatedMembers: [DeclSyntax] = []

        // Title - escape quotes for string literal
        let escapedTitle = title.replacingOccurrences(of: "\"", with: "\\\"")
        generatedMembers.append(
            DeclSyntax(stringLiteral: "static let title: LocalizedStringResource = \"\(escapedTitle)\"")
        )

        // Description - escape quotes for string literal
        let escapedDesc = description.replacingOccurrences(of: "\"", with: "\\\"")
        let escapedCat = category.replacingOccurrences(of: "\"", with: "\\\"")
        let descDeclSyntax: DeclSyntax = """
        static let description = IntentDescription(
            "\(raw: escapedDesc)",
            categoryName: "\(raw: escapedCat)",
            searchKeywords: \(raw: keywords)
        )
        """
        generatedMembers.append(descDeclSyntax)

        // Metadata
        generatedMembers.append(DeclSyntax(stringLiteral: "static let openAppWhenRun: Bool = false"))
        generatedMembers.append(DeclSyntax(stringLiteral: "static let isDiscoverable: Bool = true"))

        let supportedModes = backgroundSupport ? ".background" : ".foreground"
        generatedMembers.append(
            DeclSyntax(stringLiteral: "static let supportedModes: IntentModes = \(supportedModes)")
        )

        // Parameter Summary
        generatedMembers.append(generateParameterSummary(from: parameters))

        // Wrapped perform method
        if !parameters.isEmpty {
            generatedMembers.append(generateWrappedPerform(
                parameters: parameters
            ))
        }

        return generatedMembers
    }
}

// MARK: - Helper Functions

private func extractStringArgument(_ name: String, from arguments: LabeledExprListSyntax?) throws -> String {
    guard let arguments = arguments else {
        throw SimpleIntentMacro.SimpleIntentMacroError.missingAttribute(name)
    }

    for argument in arguments {
        if argument.label?.text == name || argument.label == nil {
            if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self) {
                return stringLiteral.representedLiteralValue ?? ""
            }
        }
    }

    throw SimpleIntentMacro.SimpleIntentMacroError.missingAttribute(name)
}

private func extractBoolArgument(_ name: String, from arguments: LabeledExprListSyntax?, default defaultValue: Bool) throws -> Bool {
    guard let arguments = arguments else {
        return defaultValue
    }

    for argument in arguments {
        if argument.label?.text == name {
            if let boolLiteral = argument.expression.as(BooleanLiteralExprSyntax.self) {
                return boolLiteral.literal.text == "true"
            }
        }
    }

    return defaultValue
}

private func extractArrayArgument(_ name: String, from arguments: LabeledExprListSyntax?) throws -> String {
    guard let arguments = arguments else {
        return "[]"
    }

    for argument in arguments {
        if argument.label?.text == name {
            let description = argument.expression.description
            return description.trimmingCharacters(in: CharacterSet(charactersIn: " \t\n\r"))
        }
    }

    return "[]"
}

// MARK: - Parameter Parsing

struct ParameterInfo {
    let name: String
    let type: String
    let title: String
    let description: String
    let hasDefault: Bool
    let defaultValue: String?
}

private func parseIntentParameter(from varDecl: VariableDeclSyntax) -> ParameterInfo? {
    // Look for @IntentParameter attribute
    guard varDecl.attributes.contains(where: { attr in
        if let attr = attr.as(AttributeSyntax.self) {
            return attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "IntentParameter"
        }
        return false
    }) else {
        return nil
    }

    // Extract variable name and type
    guard let binding = varDecl.bindings.first,
          let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self),
          let typeAnnotation = binding.typeAnnotation else {
        return nil
    }

    let name = identifierPattern.identifier.text
    let typeDescription = typeAnnotation.type.description
    let type = typeDescription.trimmingCharacters(in: CharacterSet(charactersIn: " \t\n\r"))

    // Extract @IntentParameter attributes
    var title = name
    var description = ""
    var hasDefault = false
    var defaultValue: String?

    for attribute in varDecl.attributes {
        if let attr = attribute.as(AttributeSyntax.self),
           attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "IntentParameter",
           let arguments = attr.arguments?.as(LabeledExprListSyntax.self) {
            // Parse title, description, default
            for arg in arguments {
                if arg.label?.text == "title" {
                    if let stringLit = arg.expression.as(StringLiteralExprSyntax.self) {
                        title = stringLit.representedLiteralValue ?? name
                    }
                }
                if arg.label?.text == "description" {
                    if let stringLit = arg.expression.as(StringLiteralExprSyntax.self) {
                        description = stringLit.representedLiteralValue ?? ""
                    }
                }
                if arg.label?.text == "default" {
                    hasDefault = true
                    let defaultDesc = arg.expression.description
                    defaultValue = defaultDesc.trimmingCharacters(in: CharacterSet(charactersIn: " \t\n\r"))
                }
            }
        }
    }

    return ParameterInfo(
        name: name,
        type: type,
        title: title,
        description: description,
        hasDefault: hasDefault,
        defaultValue: defaultValue
    )
}

// MARK: - Code Generation

private func generateParameterSummary(from parameters: [ParameterInfo]) -> DeclSyntax {
    guard !parameters.isEmpty else {
        return DeclSyntax(stringLiteral: "static var parameterSummary: some ParameterSummary { Summary(\"Action\") }")
    }

    // Get first parameter name for the summary
    let firstParamName = parameters[0].name

    var keyPaths = ""
    for param in parameters.dropFirst() {
        keyPaths += "\n                \\.$\(param.name)"
    }

    // Note: firstParamName is used in the string interpolation below
    let summaryDecl: DeclSyntax = """
    static var parameterSummary: some ParameterSummary {
        Summary("Action with \\(\\.\\(firstParamName))") {\(raw: keyPaths)
        }
    }
    """

    // Prevent unused variable warning (firstParamName is used in string interpolation above)
    _ = firstParamName

    return summaryDecl
}

private func generateWrappedPerform(
    parameters: [ParameterInfo]
) -> DeclSyntax {
    // Build parameter dictionary entries
    let paramEntries = parameters.map { param in
        "\"\(param.name)\": \\(\(param.name))"
    }.joined(separator: ", ")

    let performDecl: DeclSyntax = """
    @MainActor
    func perform() async throws -> some IntentResult {
        // Training mode guard - prevents crashes during AppIntents SSU training
        if AppIntentsGuards.isTraining() {
            return .result(dialog: "Training mode")
        }

        // Log entry
        IntentLogger.logEntry(
            intent: "Action",
            parameters: [\(raw: paramEntries)]
        )

        do {
            // Call user-provided perform logic
            let action = Self()
            let result = try await action.perform()

            // Log success
            IntentLogger.logSuccess(intent: "Action")

            return result
        } catch {
            // Log failure
            IntentLogger.logFailure(intent: "Action", error: error)
            throw error
        }
    }
    """

    return performDecl
}
