//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

final class Object: Codable, Equatable, CustomStringConvertible {

    let id: Int
    var color: Color
    var title: String

    init(id: Int, color: Color, title: String) {
        self.id = id
        self.color = color
        self.title = title
    }

    static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs.id == rhs.id
            && lhs.color == rhs.color
            && lhs.title == rhs.title
    }

    var description: String {
        let colorString = "\(color)".replacingOccurrences(of: "UIExtendedSRGBColorSpace ", with: "")
        return "id = \(id), color = \(colorString), title = \(title)"
    }
}
