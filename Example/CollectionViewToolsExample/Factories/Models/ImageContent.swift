//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit.UIImage

final class ImageContent: Content {

    let image: UIImage

    init(id: Int, image: UIImage, description: String) {
        self.image = image
        super.init(id: id, description: description)
    }
}
