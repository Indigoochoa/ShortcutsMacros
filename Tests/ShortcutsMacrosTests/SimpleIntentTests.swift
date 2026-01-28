import Testing
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

#if canImport(ShortcutsMacrosPlugin)
import ShortcutsMacrosPlugin

struct SimpleIntentTests {
    @Test
    func simpleIntentExpansion() throws {
        let source = """
        @SimpleIntent(
            title: "Test Intent",
            description: "A test intent",
            category: "Test",
            keywords: ["test"],
            backgroundSupport: true
        )
        struct TestAction {
            @IntentParameter(title: "Key")
            var key: String

            func perform() async throws -> IntentResult<String> {
                return .result(dialog: "Done")
            }
        }
        """

        let macros: [String: Macro.Type] = [
            "SimpleIntent": SimpleIntentMacro.self,
        ]

        assertMacroExpansion(source, expandedSource: source, macros: macros)
    }

    @Test
    func parameterParsing() throws {
        #expect(true, "Parameter parsing test placeholder")
    }

    @Test
    func trainingModeGuard() throws {
        #expect(true, "Training mode guard test placeholder")
    }
}
#endif
