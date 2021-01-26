//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

final class Color: Codable, Equatable {

    let red: Int
    let green: Int
    let blue: Int
    let alpha: CGFloat

    init(r red: Int, g green: Int, b blue: Int, alpha: CGFloat = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    var uiColor: UIColor {
        return .init(red: CGFloat(red) / 255.0,
                     green: CGFloat(green) / 255.0,
                     blue: CGFloat(blue) / 255.0,
                     alpha: alpha)
    }

    static func == (lhs: Color, rhs: Color) -> Bool {
        return lhs.red == rhs.red
            && lhs.green == rhs.green
            && lhs.blue == rhs.blue
            && lhs.alpha == rhs.alpha
    }
}

extension Color {

    static let green: Color = .init(r: 126, g: 203, b: 125)
    static let blue: Color = .init(r: 103, g: 152, b: 238)
    static let orange: Color = .init(r: 255, g: 177, b: 96)
    static let red: Color = .init(r: 242, g: 86, b: 92)
    static let purple: Color = .init(r: 151, g: 114, b: 196)
    static var random: Color {
        return .init(r: .random(in: 0...255),
                     g: .random(in: 0...255),
                     b: .random(in: 0...255))
    }
}
