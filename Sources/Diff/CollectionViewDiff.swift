//
//  Copyright © 2019 Rosberry. All rights reserved.
//

public protocol CollectionViewDiff {

    func changes<T: Hashable>(old: [T], new: [T]) -> [CollectionViewChange<T>]
}
