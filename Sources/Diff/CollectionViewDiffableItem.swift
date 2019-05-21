//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public protocol CollectionViewDiffableItem {

    var diffIdentifier: String { get }
    
    func equal(to item: CollectionViewDiffableItem) -> Bool
}

public final class CollectionViewDiffableItemWrapper: CollectionViewDiffableItem {

    let item: CollectionViewDiffableItem

    init(item: CollectionViewDiffableItem) {
        self.item = item
    }

    public var diffIdentifier: String {
        return item.diffIdentifier
    }

    public func equal(to item: CollectionViewDiffableItem) -> Bool {
        guard let wrapper = item as? CollectionViewDiffableItemWrapper else {
            return false
        }
        return self.item.equal(to: wrapper.item)
    }
}
