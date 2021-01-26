//
//  Copyright © 2020 Rosberry. All rights reserved.
//

@testable import CollectionViewTools

final class TestAsyncCollectionViewCellItem: CollectionViewCellItem {

    enum State {
        case undefined
        case prefetching
        case prefetched
        case cancelled
    }

    let reuseType: ReuseType = .class(TestCollectionViewCell.self)
    var timer: Timer?
    var state: State = .undefined

    func configure(_ cell: UICollectionViewCell) {
    }

    func cancelPrefetchingData() {
        timer?.invalidate()
        timer = nil
        state = .cancelled
    }

    func prefetchData() {
        state = .prefetching
        timer = Timer.scheduledTimer(withTimeInterval: 5000, repeats: false, block: { _ in
            self.state = .prefetched
        })
    }

    func size(in collectionView: UICollectionView, sectionItem: CollectionViewSectionItem) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 80)
    }
}
