//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

public typealias CollectionViewDiffSectionItem = CollectionViewSectionItem & DiffItem

extension CollectionViewSectionItem {

    var diffCellItems: [CollectionViewDiffCellItem] {
        return cellItems.compactMap { cellItem in
            cellItem as? CollectionViewDiffCellItem
        }
    }
}

open class GeneralCollectionViewDiffSectionItem: CollectionViewDiffSectionItem, Equatable, CustomStringConvertible {

    public var diffIdentifier: String = ""

    public var cellItems: [CollectionViewCellItem]
    public var reusableViewItems: [CollectionViewReusableViewItem]

    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var insets: UIEdgeInsets = .zero

    public init(cellItems: [CollectionViewCellItem] = [], reusableViewItems: [CollectionViewReusableViewItem] = []) {
        self.cellItems = cellItems
        self.reusableViewItems = reusableViewItems
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(diffIdentifier)
    }

    open func equal(to item: DiffItem) -> Bool {
        guard let item = item as? GeneralCollectionViewDiffSectionItem else {
            return false
        }
        let cellItems = diffCellItems
        let itemCellItems = item.diffCellItems
        guard cellItems.count == itemCellItems.count else {
            return false
        }
        // TODO: add reusableViewItems here
        let areItemsEqual = zip(cellItems, itemCellItems).allSatisfy { lhs, rhs in
            lhs.equal(to: rhs)
        }
        return areItemsEqual &&
            minimumLineSpacing == item.minimumLineSpacing &&
            minimumInteritemSpacing == item.minimumInteritemSpacing &&
            insets == item.insets
    }

    public static func == (lhs: GeneralCollectionViewDiffSectionItem, rhs: GeneralCollectionViewDiffSectionItem) -> Bool {
        return lhs.equal(to: rhs)
    }

    public var description: String {
        return "\n\n sectionItem id = \(diffIdentifier) \ncellItems =\n\(cellItems)"
    }
}
