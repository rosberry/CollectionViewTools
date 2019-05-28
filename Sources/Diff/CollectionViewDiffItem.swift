//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public protocol CollectionViewDiffItem {

    var diffIdentifier: String { get }
    
    func equal(to item: CollectionViewDiffItem) -> Bool
}

public typealias CollectionViewDiffSectionItem = CollectionViewSectionItem & CollectionViewDiffItem

public typealias CollectionViewDiffCellItem = CollectionViewCellItem & CollectionViewDiffItem

public final class CollectionViewDiffItemWrapper: CollectionViewDiffItem {

    let item: CollectionViewDiffItem

    init(item: CollectionViewDiffItem) {
        self.item = item
    }

    public var diffIdentifier: String {
        return item.diffIdentifier
    }

    public func equal(to item: CollectionViewDiffItem) -> Bool {
        guard let wrapper = item as? CollectionViewDiffItemWrapper else {
            return false
        }
        return self.item.equal(to: wrapper.item)
    }
}

extension CollectionViewManager {

    var diffSectionItems: [CollectionViewDiffSectionItem] {
        return sectionItems.compactMap { sectionItem in
            sectionItem as? CollectionViewDiffSectionItem
        }
    }
}

extension CollectionViewSectionItem {

    var diffCellItems: [CollectionViewDiffCellItem] {
        return cellItems.compactMap { cellItem in
            cellItem as? CollectionViewDiffCellItem
        }
    }
}
