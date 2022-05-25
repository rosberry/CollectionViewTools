//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
@testable import CollectionViewTools

final class TestViewController: UIViewController {

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var manager = CollectionViewManager(collectionView: collectionView)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}
