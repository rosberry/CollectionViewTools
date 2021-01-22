//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

/// `CollectionViewDiffSectionItem` is a composition of `CollectionViewSectionItem` and `DiffSectionItem`.
/// Use it to create new section items or just conform `DiffSectionItem` protocol in your existing section items.
public typealias CollectionViewDiffSectionItem = CollectionViewSectionItem & DiffSectionItem

extension CollectionViewSectionItem {

    /// Array of `CollectionViewDiffCellItem` objects mapped from `cellItems` array
    var diffCellItems: [CollectionViewDiffCellItem] {
        return cellItems.compactMap { cellItem in
            cellItem as? CollectionViewDiffCellItem
        }
    }

    /// Array of `CollectionViewDiffReusableViewItem` objects mapped from `reusableViewItems` array
    var diffReusableViewItems: [CollectionViewDiffReusableViewItem] {
        return reusableViewItems.compactMap { cellItem in
            cellItem as? CollectionViewDiffReusableViewItem
        }
    }
}

/// Section item that inherits from `GeneralCollectionViewSectionItem` and conforms `DiffSectionItem` protocol.
open class GeneralCollectionViewDiffSectionItem: GeneralCollectionViewSectionItem, DiffSectionItem {

    public var diffIdentifier: String = ""

    open func isEqual(to item: DiffItem) -> Bool {
        guard let item = item as? GeneralCollectionViewDiffSectionItem else {
            return false
        }
        return areInsetsAndSpacingsEqual(to: item) &&
                areReusableViewsEqual(to: item) &&
                areCellItemsEqual(to: item)
    }

    open func areInsetsAndSpacingsEqual(to item: DiffItem) -> Bool {
        guard let item = item as? GeneralCollectionViewDiffSectionItem else {
            return false
        }
        return minimumLineSpacing == item.minimumLineSpacing &&
                minimumInteritemSpacing == item.minimumInteritemSpacing &&
                insets == item.insets
    }

    open func areReusableViewsEqual(to item: DiffItem) -> Bool {
        guard let item = item as? GeneralCollectionViewDiffSectionItem else {
            return false
        }
        let reusableViewItems = diffReusableViewItems
        let itemReusableViewItems = item.diffReusableViewItems
        guard reusableViewItems.count == itemReusableViewItems.count else {
            return false
        }
        return zip(reusableViewItems, itemReusableViewItems).allSatisfy { lhs, rhs in
            lhs.isEqual(to: rhs)
        }
    }

    open func areCellItemsEqual(to item: DiffItem) -> Bool {
        guard let item = item as? GeneralCollectionViewDiffSectionItem else {
            return false
        }
        let cellItems = diffCellItems
        let itemCellItems = item.diffCellItems
        guard cellItems.count == itemCellItems.count else {
            return false
        }
        return zip(cellItems, itemCellItems).allSatisfy { lhs, rhs in
            lhs.isEqual(to: rhs)
        }
    }
}

extension GeneralCollectionViewDiffSectionItem: Equatable {

    public static func == (lhs: GeneralCollectionViewDiffSectionItem, rhs: GeneralCollectionViewDiffSectionItem) -> Bool {
        return lhs.isEqual(to: rhs)
    }
}

extension GeneralCollectionViewDiffSectionItem: CustomStringConvertible {

    public var description: String {
        return "\n\n sectionItem id = \(diffIdentifier) \ncellItems =\n\(cellItems)"
    }
}
