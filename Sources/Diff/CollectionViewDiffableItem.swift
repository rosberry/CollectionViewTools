//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public protocol CollectionViewDiffableItem {

    var identifier: String { get }
    
    func equal(to item: CollectionViewDiffableItem) -> Bool
}

public final class CollectionViewDiffableItemWrapper: Hashable {

    let item: CollectionViewDiffableItem

    init(item: CollectionViewDiffableItem) {
        self.item = item
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(item.identifier)
    }

    public static func == (lhs: CollectionViewDiffableItemWrapper, rhs: CollectionViewDiffableItemWrapper) -> Bool {
        return lhs.item.equal(to: rhs.item)
    }
}
