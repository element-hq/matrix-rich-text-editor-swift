//
// Copyright 2024 New Vector Ltd.
// Copyright 2023 The Matrix.org Foundation C.I.C
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE in the repository root for full details.
//

import Foundation

protocol ComposerModelWrapperProtocol {
    // Rust direct bindings
    func setContentFromHtml(html: String) -> ComposerUpdate
    func setContentFromMarkdown(markdown: String) -> ComposerUpdate
    func getContentAsHtml() -> String
    func getContentAsMessageHtml() -> String
    func getContentAsMarkdown() -> String
    func getContentAsMessageMarkdown() -> String
    func getContentAsPlainText() -> String
    func clear() -> ComposerUpdate
    func select(startUtf16Codeunit: UInt32, endUtf16Codeunit: UInt32) -> ComposerUpdate
    func replaceText(newText: String) -> ComposerUpdate
    func replaceTextIn(newText: String, start: UInt32, end: UInt32) -> ComposerUpdate
    func replaceTextSuggestion(newText: String, suggestion: SuggestionPattern) -> ComposerUpdate
    func backspace() -> ComposerUpdate
    func enter() -> ComposerUpdate
    func setLink(url: String, attributes: [Attribute]) -> ComposerUpdate
    func setLinkWithText(url: String, text: String, attributes: [Attribute]) -> ComposerUpdate
    func insertMention(url: String, text: String, attributes: [Attribute]) -> ComposerUpdate
    func insertMentionAtSuggestion(url: String, text: String, suggestion: SuggestionPattern, attributes: [Attribute]) -> ComposerUpdate
    func removeLinks() -> ComposerUpdate
    func toTree() -> String
    func getCurrentDomState() -> ComposerState
    func actionStates() -> [ComposerAction: ActionState]
    func getLinkAction() -> LinkAction

    // Extensions
    func apply(_ action: ComposerAction) -> ComposerUpdate
    var reversedActions: Set<ComposerAction> { get }
}

/// Defines a delegate that can provide fallback content in case something goes wrong within the model.
protocol ComposerModelWrapperDelegate: AnyObject {
    func fallbackContent() -> String
}

/// Provides a wrapper around `ComposerModel` that handles failures and reset to
/// a fallback content if needed. This wrapper exists because we are currently tweaking
/// the generated bindings to be able to catch Rust panics on the Swift side (see `make ios`).
/// If the bindings are restored to their standard state, this class can be removed and occurences
/// of `ComposerModelWrapper()` just needs to be replaced with `newComposerModel()`.
final class ComposerModelWrapper: ComposerModelWrapperProtocol {
    // MARK: - Private

    private var model = newComposerModel()

    // MARK: - Internal

    // MARK: Rust direct bindings

    weak var delegate: ComposerModelWrapperDelegate?

    func setContentFromHtml(html: String) -> ComposerUpdate {
        execute { try $0.setContentFromHtml(html: html) }
    }

    func setContentFromMarkdown(markdown: String) -> ComposerUpdate {
        execute { try $0.setContentFromMarkdown(markdown: markdown) }
    }

    func getContentAsHtml() -> String {
        model.getContentAsHtml()
    }

    func getContentAsMessageHtml() -> String {
        model.getContentAsMessageHtml()
    }
    
    func getContentAsMarkdown() -> String {
        model.getContentAsMarkdown()
    }

    func getContentAsMessageMarkdown() -> String {
        model.getContentAsMessageMarkdown()
    }
    
    func getContentAsPlainText() -> String {
        model.getContentAsPlainText()
    }

    func clear() -> ComposerUpdate {
        execute { try $0.clear() }
    }

    func select(startUtf16Codeunit: UInt32, endUtf16Codeunit: UInt32) -> ComposerUpdate {
        execute { try $0.select(startUtf16Codeunit: startUtf16Codeunit, endUtf16Codeunit: endUtf16Codeunit) }
    }

    func replaceText(newText: String) -> ComposerUpdate {
        execute { try $0.replaceText(newText: newText) }
    }

    func replaceTextIn(newText: String, start: UInt32, end: UInt32) -> ComposerUpdate {
        execute { try $0.replaceTextIn(newText: newText, start: start, end: end) }
    }

    func replaceTextSuggestion(newText: String, suggestion: SuggestionPattern) -> ComposerUpdate {
        execute { try $0.replaceTextSuggestion(newText: newText, suggestion: suggestion, appendSpace: true) }
    }

    func backspace() -> ComposerUpdate {
        execute { try $0.backspace() }
    }

    func enter() -> ComposerUpdate {
        execute { try $0.enter() }
    }

    func setLink(url: String, attributes: [Attribute]) -> ComposerUpdate {
        execute { try $0.setLink(url: url, attributes: attributes) }
    }

    func setLinkWithText(url: String, text: String, attributes: [Attribute]) -> ComposerUpdate {
        execute { try $0.setLinkWithText(url: url, text: text, attributes: attributes) }
    }

    func insertMention(url: String, text: String, attributes: [Attribute]) -> ComposerUpdate {
        execute { try $0.insertMention(url: url, text: text, attributes: attributes) }
    }

    func insertMentionAtSuggestion(url: String, text: String, suggestion: SuggestionPattern, attributes: [Attribute]) -> ComposerUpdate {
        execute { try $0.insertMentionAtSuggestion(url: url, text: text, suggestion: suggestion, attributes: attributes) }
    }
    
    func insertAtRoomMention() -> ComposerUpdate {
        execute { try $0.insertAtRoomMention() }
    }
    
    func insertAtRoomMentionAtSuggestion(_ suggestion: SuggestionPattern) -> ComposerUpdate {
        execute { try $0.insertAtRoomMentionAtSuggestion(suggestion: suggestion) }
    }

    func removeLinks() -> ComposerUpdate {
        execute { try $0.removeLinks() }
    }

    func toTree() -> String {
        model.toTree()
    }

    func getCurrentDomState() -> ComposerState {
        model.getCurrentDomState()
    }

    func actionStates() -> [ComposerAction: ActionState] {
        model.actionStates()
    }

    func getLinkAction() -> LinkAction {
        model.getLinkAction()
    }
    
    func getMentionsState() -> MentionsState {
        model.getMentionsState()
    }

    // MARK: Extensions

    func apply(_ action: ComposerAction) -> ComposerUpdate {
        execute { try $0.apply(action) }
    }

    var reversedActions: Set<ComposerAction> {
        model.reversedActions
    }
}

// MARK: - Private

private extension ComposerModelWrapper {
    /// Execute some failable action on the model and restore provided fallback content if needed.
    func execute(_ action: @escaping (ComposerModel) throws -> ComposerUpdate) -> ComposerUpdate {
        do {
            let update = try action(model)
            return update
        } catch {
            model = newComposerModel()
            if let fallbackContent = delegate?.fallbackContent() {
                do {
                    let update = try model.replaceText(newText: fallbackContent)
                    return update
                } catch {
                    // If setting the fallback content fails, just reset to empty.
                    model = newComposerModel()
                    // Provide an empty update
                    // swiftlint:disable:next force_try
                    return try! model.clear()
                }
            } else {
                // Provide an empty update
                // swiftlint:disable:next force_try
                return try! model.clear()
            }
        }
    }
}
