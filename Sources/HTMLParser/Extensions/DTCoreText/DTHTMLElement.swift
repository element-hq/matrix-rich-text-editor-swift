//
// Copyright 2024 New Vector Ltd.
// Copyright 2023 The Matrix.org Foundation C.I.C
//
// SPDX-License-Identifier: AGPL-3.0-only OR LicenseRef-Element-Commercial
// Please see LICENSE in the repository root for full details.
//

import DTCoreText

extension DTHTMLElement {
    /// Sanitize the DTHTMLElement right before it's written inside the resulting attributed string.
    func sanitize() {
        guard let childNodes = childNodes as? [DTHTMLElement] else { return }

        if tag == .a,
           attributes["data-mention-type"] != nil,
           let textNode = self.childNodes.first as? DTTextHTMLElement {
            let mentionTextNode = MentionTextNodeHTMLElement(from: textNode)
            removeAllChildNodes()
            addChildNode(mentionTextNode)
            mentionTextNode.inheritAttributes(from: self)
            mentionTextNode.interpretAttributes()
        }

        if childNodes.count == 1, let child = childNodes.first as? DTTextHTMLElement {
            if child.text() == .nbsp {
                // Removing NBSP character from e.g. <p>&nbsp;</p> since it is only used to
                // make DTCoreText able to easily parse new lines.
                removeAllChildNodes()
                let newChild = PlaceholderTextHTMLElement(from: child)
                addChildNode(newChild)
                newChild.inheritAttributes(from: self)
                newChild.interpretAttributes()
            } else {
                if tag == .code, parent().tag == .pre, var text = child.text() {
                    // Replace leading and trailing NBSP from code blocks with
                    // discardable elements (ZWSP).
                    let hasLeadingNbsp = text.hasPrefix(String.nbsp)
                    let hasTrailingNbsp = text.hasSuffix(String.nbsp)
                    guard hasLeadingNbsp || hasTrailingNbsp else { return }
                    removeAllChildNodes()
                    if hasLeadingNbsp {
                        text.removeFirst()
                        addChildNode(createDiscardableElement())
                    }
                    addChildNode(child)
                    if hasTrailingNbsp {
                        text.removeLast()
                        if text.last == .lineFeed {
                            text.removeLast()
                            addChildNode(createLineBreak())
                        }
                        addChildNode(createDiscardableElement())
                    }
                    child.setText(text)
                }
            }
        } else {
            childNodes.forEach { $0.sanitize() }
        }
    }
}

// MARK: - Helpers

/// An arbitrary enum of HTML tags that requires some specific handling
private enum DTHTMLElementTag: String {
    case pre
    case code
    case a
}

private extension DTHTMLElement {
    var tag: DTHTMLElementTag? {
        guard let name else { return nil }

        return DTHTMLElementTag(rawValue: name)
    }

    func createDiscardableElement() -> PlaceholderTextHTMLElement {
        let discardableElement = PlaceholderTextHTMLElement()
        discardableElement.inheritAttributes(from: self)
        discardableElement.interpretAttributes()
        return discardableElement
    }

    func createLineBreak() -> DTBreakHTMLElement {
        let lineBreakElement = DTBreakHTMLElement()
        lineBreakElement.inheritAttributes(from: self)
        lineBreakElement.interpretAttributes()
        return lineBreakElement
    }
}
