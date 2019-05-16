//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import CollectionViewTools

extension CollectionViewManager {

    open func update(with sectionItems: [CollectionViewDiffableSectionItem],
                     ignoreCellItemsChanges: Bool = false,
                     animated: Bool,
                     completion: ((Bool) -> Void)? = nil) {
        update(with: sectionItems,
               diff: CollectionViewDeepDiff(),
               ignoreCellItemsChanges: ignoreCellItemsChanges,
               animated: animated,
               completion: completion)
    }
}

