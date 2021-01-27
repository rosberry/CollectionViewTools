//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import CollectionViewTools

final class DescriptionViewState: ViewState {
    let text: String

    init(id: Int, text: String) {
        self.text = text
        super.init(id: id)
    }

    convenience init(content: Content) {
        self.init(id: content.id, text: content.description)
    }
}

extension DescriptionViewState: Equatable {
    static func == (lhs: DescriptionViewState, rhs: DescriptionViewState) -> Bool {
        lhs.text == rhs.text
    }
}
