//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

/// `UniversalCollectionViewCellItem` should be associated with the object that conforms `DiffCompatible` protocol.
/// This protocol automatically allsows to conform cellItem to `DiffItem` protocol using associted object information.
public protocol DiffCompatible {
    /// `DiffComparator` is any equatable instance that describes content state of `DiffCompatible` object
    associatedtype DiffComparator: Equatable

    /// `diffIdentifier` - identifier that allows make difference one cell item from other
    var diffIdentifier: String { get }

    /// `UniversalCollectionViewCellItem` remembers `DiffComparator` at the initialization and compares it
    /// when collection updates requested
    /// `makeDiffComparator` should return equatable instance that describes content state at the moment
    func makeDiffComparator() -> DiffComparator
}

/// Your cell items and reusable view items must conform `DiffItem` protocol to work with diffing.
/// diffIdentifier: Each item must be uniquely(!!!) identified by `diffIdentifier`. Otherwise diff algorithm can work incorrectly.
/// isEqual: Compares items. Used for item updates.
public protocol DiffItem {

    var diffIdentifier: String { get }
    func isEqual(to item: DiffItem) -> Bool
}

/// Your section items must conform `DiffSectionItem` protocol to work with diffing.
/// areInsetsAndSpacingsEqual: Compares section item insets and spacings.
/// areReusableViewsEqual: Compares section item reusable view items.
/// areCellItemsEqual: Compares section item cell items.
public protocol DiffSectionItem: DiffItem {

    func areInsetsAndSpacingsEqual(to item: DiffItem) -> Bool
    func areReusableViewsEqual(to item: DiffItem) -> Bool
    func areCellItemsEqual(to item: DiffItem) -> Bool
}

final class DiffItemWrapper: DiffItem {

    let item: DiffItem

    init(item: DiffItem) {
        self.item = item
    }

    public var diffIdentifier: String {
        return item.diffIdentifier
    }

    public func isEqual(to item: DiffItem) -> Bool {
        guard let wrapper = item as? DiffItemWrapper else {
            return false
        }
        return self.item.isEqual(to: wrapper.item)
    }
}
