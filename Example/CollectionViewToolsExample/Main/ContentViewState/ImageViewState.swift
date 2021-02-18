//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

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

extension ImageViewState: Equatable {
    static func == (lhs: ImageViewState, rhs: ImageViewState) -> Bool {
        lhs.isExpanded == rhs.isExpanded && lhs.id == rhs.id
    }
}

extension ImageViewState: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let state = ImageViewState(id: id, image: image, description: description)
        state.isExpanded = isExpanded
        return state
    }
}
