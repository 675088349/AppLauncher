import SwiftUI
import AppKit

struct SearchBar: NSViewRepresentable {
    @Binding var text: String

    func makeNSView(context: Context) -> NSSearchField {
        let search = NSSearchField(string: "")
        search.placeholderString = "搜索应用"
        search.delegate = context.coordinator
        search.sendsSearchStringImmediately = true
        return search
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(text: $text) }

    final class Coordinator: NSObject, NSSearchFieldDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        func controlTextDidChange(_ obj: Notification) {
            if let field = obj.object as? NSSearchField {
                text = field.stringValue
            }
        }
    }
}

