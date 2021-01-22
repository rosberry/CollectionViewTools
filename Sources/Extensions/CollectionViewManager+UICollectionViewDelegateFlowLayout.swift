//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit.UICollectionView

extension CollectionViewManager: UICollectionViewDelegateFlowLayout {

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
        sectionItemsProvider.sizeForCellItem(at: indexPath, in: collectionView)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionItemsProvider[section]?.insets ?? .zero
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionItemsProvider[section]?.minimumLineSpacing ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionItemsProvider[section]?.minimumInteritemSpacing ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> CGSize {
        let optionalItem = sectionItemsProvider[section]?.reusableViewItems.first { reusableViewItem in
            reusableViewItem.type == .header
        }
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForFooterInSection section: Int) -> CGSize {
        let optionalItem = sectionItemsProvider[section]?.reusableViewItems.first { reusableViewItem in
            reusableViewItem.type == .footer
        }
        guard let item = optionalItem else {
            return .zero
        }
        return item.size(for: collectionView, with: collectionViewLayout)
    }
}
