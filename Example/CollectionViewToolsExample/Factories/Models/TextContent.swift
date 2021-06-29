//
//  Copyright © 2020 Rosberry. All rights reserved.
//

final class TextContent: Content {

    let text: String

    init(id: Int, text: String, description: String) {
        self.text = text
        super.init(id: id, description: description)
    }
}
