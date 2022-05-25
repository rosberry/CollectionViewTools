//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

final class Template {

    let id: String
    let text: String
    var isFavorite: Bool = false

    init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

extension Template: DiffCompatible {

    var diffIdentifier: String {
        id
    }

    func makeDiffComparator() -> Bool {
        isFavorite
    }
}
