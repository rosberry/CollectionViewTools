//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public protocol CollectionViewDiff {

    func changes<T: CollectionViewDiffItem>(old: [T], new: [T]) -> [CollectionViewChange<T>]
}
