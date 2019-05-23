//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public typealias CollectionViewDiffableSectionItem = CollectionViewSectionItem &
                                                     CollectionViewDiffableItem

open class GeneralCollectionViewDiffableSectionItem: CollectionViewDiffableSectionItem, Equatable, CustomStringConvertible {

    public var diffIdentifier: String = ""

    public var cellItems: [CollectionViewManager.CellItem]
    public var reusableViewItems: [CollectionViewReusableViewItem]

    public var minimumLineSpacing: CGFloat = 0
    public var minimumInteritemSpacing: CGFloat = 0
    public var insets: UIEdgeInsets = .zero

    public init(cellItems: [CollectionViewManager.CellItem] = [], reusableViewItems: [CollectionViewReusableViewItem] = []) {
        self.cellItems = cellItems
        self.reusableViewItems = reusableViewItems
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(diffIdentifier)
    }

    open func equal(to item: CollectionViewDiffableItem) -> Bool {
        guard let item = item as? GeneralCollectionViewDiffableSectionItem else {
            return false
        }
        let cellItems = diffableCellItems
        let itemCellItems = item.diffableCellItems
        guard cellItems.count == itemCellItems.count else {
            return false
        }
        // TODO: add reusableViewItems here
        return zip(cellItems, itemCellItems).first { !$0.equal(to: $1) } == nil &&
               minimumLineSpacing == item.minimumLineSpacing &&
               minimumInteritemSpacing == item.minimumInteritemSpacing &&
               insets == item.insets
    }

    public static func == (lhs: GeneralCollectionViewDiffableSectionItem, rhs: GeneralCollectionViewDiffableSectionItem) -> Bool {
        return lhs.equal(to: rhs)
    }

    public var description: String {
//        return "\n\n sectionItem id = \(diffIdentifier) \ncellItems =\n\(cellItems)"
        return "id = \(diffIdentifier) items = \(cellItems.count)"
    }
}
