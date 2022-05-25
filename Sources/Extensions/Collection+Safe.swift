//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

extension MutableCollection where Index == Int {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        index < count ? self[index] : nil
    }
}
