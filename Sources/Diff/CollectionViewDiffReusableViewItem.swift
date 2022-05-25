//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

/// `CollectionViewDiffReusableViewItem` is a composition of `CollectionViewReusableViewItem` and `DiffItem`.
/// Use it to create new reusable view items or just conform `DiffItem` protocol in your existing reusable view items.
public typealias CollectionViewDiffReusableViewItem = CollectionViewReusableViewItem & DiffItem
