//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

final class ImageViewState: ViewState, Expandable {

    let image: UIImage
    var isExpanded: Bool = false
    let description: String

    init(id: Int, image: UIImage, description: String) {
        self.image = image
        self.description = description
        super.init(id: id)
    }

    convenience init(content: ImageContent) {
        self.init(id: content.id, image: content.image, description: content.description)
    }
}

extension ImageViewState: DiffCompatible {
    var diffIdentifier: String {
        "\(id)"
    }

    func makeDiffComparator() -> Bool {
        isExpanded
    }
}
