//
// Copyright (c) 2018 Rosberry. All rights reserved.
//

import Foundation

extension Int {
    static func random(range: Range<Int>) -> Int {
        var offset = 0
        
        if range.lowerBound < 0 {
            offset = abs(range.upperBound)
        }
        
        let minValue = UInt32(range.lowerBound + offset)
        let maxValue = UInt32(range.upperBound + offset)
        
        return Int(minValue + arc4random_uniform(maxValue - minValue)) - offset
    }
}
