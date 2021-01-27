//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class TextViewState: ContentViewState, NSCopying {
    var textContent: TextContent

    init(textContent: TextContent) {
        self.textContent = textContent
        super.init(content: textContent)
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let state = TextViewState(textContent: textContent)
        state.isExpanded = isExpanded
        return state
    }
}
