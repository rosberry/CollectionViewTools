//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CoreGraphics

public struct SizeTypes {

    public enum SizeType {
        case fixed(_ value: CGFloat)
        case contentRelated
        case fill
    }

    let width: SizeType
    let height: SizeType

    public init(width: SizeType, height: SizeType) {
        self.width = width
        self.height = height
    }
}
