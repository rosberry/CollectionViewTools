//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

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

extension TextViewState: DiffCompatible {
    var diffIdentifier: String {
        "\(id)"
    }

    func makeDiffComparator() -> Bool {
        isExpanded
    }
}
