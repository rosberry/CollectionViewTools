//
//  Collection+Safe.swift
//
//  Copyright © 220 Rosberry. All rights reserved.
//

import Foundation

extension MutableCollection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        get {
            indices.contains(index) ? self[index] : nil
        }
    }
}
