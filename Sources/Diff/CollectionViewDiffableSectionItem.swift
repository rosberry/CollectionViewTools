//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public typealias CollectionViewDiffableSectionItem = CollectionViewSectionItem & CollectionViewDiffableItem

public class GeneralCollectionViewDiffableSectionItem: CollectionViewDiffableSectionItem {

    public var identifier: String = ""

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
        hasher.combine(identifier)
    }

    public func equal(to item: CollectionViewDiffableItem) -> Bool {
        guard let item = item as? GeneralCollectionViewDiffableSectionItem else {
            return false
        }
        let cellItems = diffableCellItems
        let itemCellItems = item.diffableCellItems
        guard cellItems.count == itemCellItems.count else {
            return false
        }
        return zip(cellItems, itemCellItems).first { !$0.equal(to: $1) } == nil
    }
}
