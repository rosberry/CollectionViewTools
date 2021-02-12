//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public class CollectionViewViewCellItem<Object: DiffCompatible, View: UIView>: UniversalCollectionViewCellItem<Object, CollectionViewViewCell<View>> {

    var cachedConstrainedSize: CGSize?
    var sizeTypes: SizeTypes?
    public weak var sizeCell: CollectionViewViewCell<View>?

    public override func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        return sizeConfigurationHandler?(collectionView, sectionItem) ?? size(for: sizeCell, in: collectionView, sectionItem: sectionItem)
    }

    func size(for cell: CollectionViewViewCell<View>?,
              in collectionView: UICollectionView,
              sectionItem: CollectionViewSectionItem) -> CGSize {
        cachedConstrainedSize = nil
        var size = calculateSize(for: collectionView, sectionItem: sectionItem)
        if (size.width == 0 || size.height == 0),
           let cell = cell {
            configure(cell)
            let constrainedSize = cachedConstrainedSize ?? calculateConstrainedSize(for: collectionView, sectionItem: sectionItem)
            let contentRelatedSize = cell.view?.sizeThatFits(constrainedSize) ?? .zero
            if size.width == 0 {
                size.width = contentRelatedSize.width
            }
            if size.height == 0 {
                size.height = contentRelatedSize.height
            }
        }
        return size
    }

    public func calculateSize(for collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        let width: CGFloat
        let height: CGFloat

        var constrainedSize: CGSize {
            if let size = cachedConstrainedSize {
                return size
            }
            let size = calculateConstrainedSize(for: collectionView, sectionItem: sectionItem)
            cachedConstrainedSize = size
            return size
        }

        if let sizeTypes = sizeTypes {
            switch sizeTypes.width {
            case .fixed(let value):
                width = value
            case .fill:
                width = constrainedSize.width
            default:
                width = 0
            }
            switch sizeTypes.height {
            case .fixed(let value):
                height = value
            case .fill:
                height = constrainedSize.height
            default:
                height = 0
            }
        }
        else {
            width = 0
            height = 0
        }
        return .init(width: width, height: height)
    }

    // MARK: - Private

    private func calculateConstrainedSize(for collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }

        switch layout.scrollDirection {
        case .horizontal:
            let height = collectionView.bounds.height -
                         collectionView.contentInset.top - collectionView.contentInset.bottom -
                         sectionItem.insets.top - sectionItem.insets.bottom
            return .init(width: .greatestFiniteMagnitude, height: height)
        case .vertical:
            let width = collectionView.bounds.width -
                        collectionView.contentInset.left - collectionView.contentInset.right -
                        sectionItem.insets.left - sectionItem.insets.right
            return .init(width: width, height: .greatestFiniteMagnitude)
        @unknown default:
            return .zero
        }
    }
}
