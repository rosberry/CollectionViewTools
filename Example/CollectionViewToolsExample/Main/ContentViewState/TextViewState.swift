//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class TextViewState: ViewState, Expandable {
    let text: String
    let description: String
    var isExpanded: Bool = false

    init(id: Int, text: String, description: String) {
        self.text = text
        self.description = description
        super.init(id: id)
    }

    convenience init(content: TextContent) {
        self.init(id: content.id, text: content.text, description: content.description)
    }
}

extension TextViewState: Equatable {
    static func == (lhs: TextViewState, rhs: TextViewState) -> Bool {
        lhs.isExpanded == rhs.isExpanded && lhs.id == rhs.id
    }
}

extension TextViewState: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let state = TextViewState(id: id, text: text, description: description)
        state.isExpanded = isExpanded
        return state
    }
}
