//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import XCTest
@testable import CollectionViewTools

class CollectionViewTests: XCTestCase {
    var expectation: XCTestExpectation!
    var viewController: TestViewController!

    override func setUp() {
        super.setUp()
        viewController = .init()
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        expectation = self.expectation(for: NSPredicate(block: { collectionView, _ in
            guard let collectionView = collectionView as? UICollectionView,
                collectionView.visibleCells.count > 0 else {
                return false
            }
            return true
        }), evaluatedWith: viewController.collectionView, handler: nil)
    }

    func testCell(item: Int, section: Int) -> TestCollectionViewCell? {
        testCell(indexPath: IndexPath(item: item, section: section))
    }

    func testCell(indexPath: IndexPath) -> TestCollectionViewCell? {
        viewController.collectionView.cellForItem(at: indexPath) as? TestCollectionViewCell
    }
}
