//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

public protocol CollectionViewCellItemDataSource: AnyObject {
    func prefetchData()
    func cancelPrefetchingData()
}

public extension CollectionViewCellItemDataSource {
    func prefetchData() {}
    func cancelPrefetchingData() {}
}
