import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ShortcutsMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SimpleIntentMacro.self,
    ]
}
