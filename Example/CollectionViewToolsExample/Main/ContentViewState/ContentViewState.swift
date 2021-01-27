//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

class ContentViewState {
    var isExpanded: Bool = false
    var content: Content

    init(content: Content) {
        self.content = content
    }
}

extension ContentViewState: CanBeDiff {
    var debugDescription: String {
        "\(content.id)"
    }

    static func == (lhs: ContentViewState, rhs: ContentViewState) -> Bool {
        lhs.isExpanded == rhs.isExpanded
    }
}
