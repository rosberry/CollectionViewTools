//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public protocol CollectionViewDiff {

    func changes<T: DiffItem>(old: [T], new: [T]) -> [CollectionViewChange<T>]
}
