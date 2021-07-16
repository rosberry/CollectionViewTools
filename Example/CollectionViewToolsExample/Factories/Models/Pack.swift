//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

final class Pack {
    let id: String
    let thumbnail: UIImage
    let templates: [Template]
    var isExpanded: Bool = false

    init(id: String, thumbnail: UIImage, templates: [Template]) {
        self.id = id
        self.thumbnail = thumbnail
        self.templates = templates
    }
}

extension Pack: DiffCompatible {
    var diffIdentifier: String {
        id
    }

    func makeDiffComparator() -> Bool {
        isExpanded
    }
}
