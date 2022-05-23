//
//  Copyright © 2022 Rosberry. All rights reserved.
//

import Foundation

final class CollectionViewCellSizeManager {
    var isSameSize: Bool = false
    
    private var universalSize: CGSize?
    private var sizeCache: [IndexPath: CGSize] = [:]

    func sizeForCellItem(at indexPath: IndexPath, sizeHandler: (() -> CGSize)) -> CGSize {
        guard isSameSize == false else {
            if let size = universalSize {
                return size
            }
            let size = sizeHandler()
            universalSize = size
            return size
        }
        if let size = sizeCache[indexPath] {
            return size
        }
        let size = sizeHandler()
        sizeCache[indexPath] = size
        return size
    }
    
    func markAsDirtyIfNeeded(cellItem: CollectionViewCellItem, oldIndexPath indexPath: IndexPath) {
        guard let size = cellItem.cachedSize else {
            sizeCache.removeValue(forKey: indexPath)
            return
        }
        if size == sizeCache[indexPath] {
            return
        }
        sizeCache.removeValue(forKey: indexPath)
    }
}

