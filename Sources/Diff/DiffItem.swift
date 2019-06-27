//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public protocol DiffItem {

    var diffIdentifier: String { get }

    func equal(to item: DiffItem) -> Bool
}

public final class DiffItemWrapper: DiffItem {

    let item: DiffItem

    init(item: DiffItem) {
        self.item = item
    }

    public var diffIdentifier: String {
        return item.diffIdentifier
    }

    public func equal(to item: DiffItem) -> Bool {
        guard let wrapper = item as? DiffItemWrapper else {
            return false
        }
        return self.item.equal(to: wrapper.item)
    }
}

