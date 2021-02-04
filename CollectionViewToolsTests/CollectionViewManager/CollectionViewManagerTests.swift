//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import XCTest
@testable import CollectionViewTools

class CollectionViewToolsTests: CollectionViewTests {

    class TestZoomView: UIView {
    }

    class TestScrollDelegate: NSObject, UIScrollViewDelegate {

        let view = TestZoomView()

        var willZoomingTriggered = false
        var didZoomingTriggered = false
        var didZoomTriggered = false
        var willDraggingTriggered = false
        var willEndDraggingTriggered = false
        var didDraggingTriggered = false
        var willDeceleratingTriggered = false
        var didDeceleratingTriggered = false
        var endAnimationTriggered = false
        var didScrollToTopTriggered = false

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            didZoomTriggered = true
        }

        func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            willZoomingTriggered = true
        }

        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            didZoomingTriggered = true
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return view
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            willDraggingTriggered = true
        }

        func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                       withVelocity velocity: CGPoint,
                                       targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            willEndDraggingTriggered = true
        }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            didDraggingTriggered = true
        }

        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
            willDeceleratingTriggered = true
        }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            didDeceleratingTriggered = true
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            endAnimationTriggered = true
        }

        func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
            didScrollToTopTriggered = true
        }
    }

    func testManager() {
        // Given
        let strings = ["1", "2", "3"]
        let indexPath = IndexPath(item: 0, section: 0)
        // When
        let cellItems = strings.map { string in
            TestCollectionViewCellItem(text: string)
        }
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: cellItems)]
        wait(for: [expectation], timeout: 10)
        //Then
        XCTAssertEqual(viewController.collectionView.visibleCells.count, 3, "Should be displayed \(strings.count) cells")
        for cell in viewController.collectionView.visibleCells {
            XCTAssertTrue(cell is TestCollectionViewCell, "Cell should be an instance of `TestCollectionViewCell`")
        }
        let cell = viewController.collectionView.cellForItem(at: indexPath) as? TestCollectionViewCell
        XCTAssertEqual(cell?.text, strings.first, "Cell text should be equal '\(strings[indexPath.row])'")
    }

    func testScroll() {
        // Given
        let numbers = Array(repeating: 0, count: 500)
        let collectionView = viewController.collectionView
        let delegate = TestScrollDelegate()
        // When
        let cellItems = numbers.map { number in
            TestCollectionViewCellItem(text: "\(number)")
        }
        let sectionItem = GeneralCollectionViewSectionItem(cellItems: cellItems)
        viewController.manager.sectionItems = [sectionItem]
        viewController.manager.scrollDelegate = delegate
        //Then
        wait(for: [expectation], timeout: 10)
        viewController.manager.scroll(to: cellItems.last!, at: .top, animated: false)
        XCTAssertGreaterThan(viewController.collectionView.contentOffset.y, viewController.view.bounds.height)
        let shouldScroll = viewController.collectionView.delegate?.scrollViewShouldScrollToTop?(collectionView)
        XCTAssertTrue(shouldScroll == true)
        XCTAssertFalse(delegate.didScrollToTopTriggered)
        viewController.manager.scroll(to: cellItems.first!, at: .top, animated: false)
        XCTAssertLessThanOrEqual(viewController.collectionView.contentOffset.y, 0)
        viewController.collectionView.delegate?.scrollViewDidScrollToTop?(collectionView)
        XCTAssertTrue(delegate.didScrollToTopTriggered)
    }

    func testScrollTop() {
        // Given
        let numbers = Array(repeating: 0, count: 500)
        // When
        let cellItems = numbers.map { number in
            TestCollectionViewCellItem(text: "\(number)")
        }
        let sectionItem = GeneralCollectionViewSectionItem(cellItems: cellItems)
        viewController.manager.sectionItems = [sectionItem]
        //Then
        wait(for: [expectation], timeout: 10)
        viewController.manager.scroll(to: cellItems.last!, at: .top, animated: false)
        XCTAssertGreaterThan(viewController.collectionView.contentOffset.y, viewController.view.bounds.height)
        let collectionView = viewController.collectionView
        let shouldScroll = viewController.collectionView.delegate?.scrollViewShouldScrollToTop?(collectionView)
        XCTAssertTrue(shouldScroll == true)
    }

    func testPrefetch() {
         // Given
        let numbers = Array(0...500)
        let indexPath = IndexPath(row: 499, section: 0)
        // When
        let cellItems = numbers.map { _ in
           TestAsyncCollectionViewCellItem()
        }
        let cellItem = cellItems[indexPath.row]
        let sectionItem = GeneralCollectionViewSectionItem(cellItems: cellItems)
        viewController.manager.sectionItems = [sectionItem]
        //Then
        wait(for: [expectation], timeout: 10)
        let collectionView = viewController.collectionView
        XCTAssertEqual(cellItem.state, .undefined)
        viewController.collectionView.prefetchDataSource?.collectionView(collectionView, prefetchItemsAt: [indexPath])
        XCTAssertEqual(cellItem.state, .prefetching)
        viewController.collectionView.prefetchDataSource?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
        XCTAssertEqual(cellItem.state, .cancelled)
    }

    func testRecalculateIndexPath() {
        // Given
        let cellItem1 = TestCollectionViewCellItem(text: "1")
        let cellItem2 = TestCollectionViewCellItem(text: "2")
        let cellItem3 = TestCollectionViewCellItem(text: "3")
        let cellItem4 = TestCollectionViewCellItem(text: "4")

        let sectionItem1 = GeneralCollectionViewSectionItem(cellItems: [cellItem1, cellItem2])
        let sectionItem2 = GeneralCollectionViewSectionItem(cellItems: [cellItem3, cellItem4])

        // When
        viewController.manager.sectionItems = [sectionItem1, sectionItem2]
        // Then
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(cellItem1.indexPath, IndexPath(row: 0, section: 0))
        XCTAssertEqual(cellItem4.indexPath, IndexPath(row: 1, section: 1))

        viewController.manager.sectionItems[0] = sectionItem2
        viewController.manager.sectionItems[1] = sectionItem1
        viewController.manager.sectionItems[0].cellItems[1] = cellItem3
        viewController.manager.sectionItems[0].cellItems[0] = cellItem4

        viewController.manager.recalculateIndexPaths()

        XCTAssertEqual(sectionItem1.index, 1)
        XCTAssertEqual(cellItem1.indexPath, IndexPath(row: 0, section: 1))
        XCTAssertEqual(cellItem3.indexPath, IndexPath(row: 1, section: 0))
    }

    func testMoveItems() {
        // Given
        let indexPath1 = IndexPath(row: 0, section: 0)
        let indexPath2 = IndexPath(row: 1, section: 0)
        let cellItem1 = TestCollectionViewCellItem(text: "1")
        let cellItem2 = TestCollectionViewCellItem(text: "2")

        // When
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: [cellItem1, cellItem2])]
        // Then
        wait(for: [expectation], timeout: 10)
        var cell = testCell(indexPath: indexPath1)
        XCTAssertEqual(cell?.text, cellItem1.text)
        viewController.collectionView.moveItem(at: indexPath1, to: indexPath2)
        cell = testCell(indexPath: indexPath1)
        XCTAssertEqual(cell?.text, cellItem2.text)
    }

    func testZoom() {
        //Given
        let delegate = TestScrollDelegate()
        //When
        viewController.manager.scrollDelegate = delegate
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: [TestCollectionViewCellItem(text: "")])]
        wait(for: [expectation], timeout: 10)
        //Then
        let collectionView = viewController.collectionView
        let view = collectionView.delegate?.viewForZooming?(in: collectionView) as? TestZoomView
        collectionView.delegate?.scrollViewWillBeginZooming?(collectionView, with: view)
        collectionView.delegate?.scrollViewDidZoom?(collectionView)
        collectionView.delegate?.scrollViewDidEndZooming?(collectionView, with: view, atScale: 1)
        XCTAssertNotNil(view)
        XCTAssertTrue(delegate.willZoomingTriggered)
        XCTAssertTrue(delegate.didZoomTriggered)
        XCTAssertTrue(delegate.didZoomingTriggered)
    }

    func testDragging() {
        //Given
        let delegate = TestScrollDelegate()
        let velocity = CGPoint(x: 0, y: 1)
        var offset = CGPoint(x: 0, y: 0)
        let offsetPointer = withUnsafeMutablePointer(to: &offset) { $0 }
        //When
        viewController.manager.scrollDelegate = delegate
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: [TestCollectionViewCellItem(text: "")])]
        wait(for: [expectation], timeout: 10)
        //Then
        let collectionView = viewController.collectionView
        collectionView.delegate?.scrollViewWillBeginDragging?(collectionView)
        collectionView.delegate?.scrollViewWillEndDragging?(collectionView,
                                                            withVelocity: velocity,
                                                            targetContentOffset: offsetPointer)
        collectionView.delegate?.scrollViewDidEndDragging?(collectionView, willDecelerate: true)
        XCTAssertTrue(delegate.willDraggingTriggered)
        XCTAssertTrue(delegate.willEndDraggingTriggered)
        XCTAssertTrue(delegate.didDraggingTriggered)
    }

    func testDecelerating() {
        //Given
        let delegate = TestScrollDelegate()
        //When
        viewController.manager.scrollDelegate = delegate
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: [TestCollectionViewCellItem(text: "")])]
        wait(for: [expectation], timeout: 10)
        //Then
        let collectionView = viewController.collectionView
        collectionView.delegate?.scrollViewWillBeginDecelerating?(collectionView)
        collectionView.delegate?.scrollViewDidEndDecelerating?(collectionView)
        collectionView.delegate?.scrollViewDidEndScrollingAnimation?(collectionView)

        XCTAssertTrue(delegate.willDeceleratingTriggered)
        XCTAssertTrue(delegate.didDeceleratingTriggered)
        XCTAssertTrue(delegate.endAnimationTriggered)
    }

    func testLazyFactoryProvider() {
        // Given
        let numbers = [Array(0..<3), Array(0..<5), Array(0..<2)]
        let indexPath = IndexPath(item: 0, section: 0)

        viewController.manager.sectionItemsProvider = LazyAssociatedFactorySectionItemsProvider<Int, TestCollectionViewCell>(
            sectionItemsNumberHandler: {
                numbers.count
            },
            cellItemsNumberHandler: { section in
                numbers[section].count
            },
            makeSectionItemHandler: { _ in
                GeneralCollectionViewDiffSectionItem()
            },
            cellConfigurationHandler: { cell, cellItem in
                cell.text = "\(cellItem.object)"
            },
            sizeHandler: { _, collectionView in
                .init(width: collectionView.bounds.width, height: 80)
            },
            objectHandler: { indexPath in
                numbers[indexPath.section][indexPath.row]
            }
        )

        // When
        wait(for: [expectation], timeout: 10)

        //Then
        for cell in viewController.collectionView.visibleCells {
            XCTAssertTrue(cell is TestCollectionViewCell, "Cell should be an instance of `TestCollectionViewCell`")
        }
        let cell = viewController.collectionView.cellForItem(at: indexPath) as? TestCollectionViewCell
        XCTAssertEqual(cell?.text, String(numbers[0][0]), "Cell text should be equal '\(numbers[indexPath.row])'")
    }

    func testLazySectionItems() {
        // Given
        let numbers = Array(0...1000)
        let indexPath = IndexPath(item: 1000, section: 0)
        let delegate = TestScrollDelegate()

        viewController.manager.sectionItemsProvider = LazyAssociatedFactorySectionItemsProvider<Int, TestCollectionViewCell>(
            cellItemsNumberHandler: { _ in
                numbers.count
            },
            makeSectionItemHandler: { _ in
                LazyCollectionViewSectionItem()
            },
            cellConfigurationHandler: { cell, cellItem in
                cell.text = "\(cellItem.object)"
            },
            sizeHandler: { _, collectionView in
                .init(width: collectionView.bounds.width, height: 80)
            },
            objectHandler: { indexPath in
                numbers[indexPath.row]
            }
        )

        // When
        viewController.manager.scrollDelegate = delegate
        //Then
        wait(for: [expectation], timeout: 10)
        viewController.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        XCTAssertGreaterThan(viewController.collectionView.contentOffset.y, viewController.view.bounds.height)
    }
}

extension Int: GenericDiffItem {
    public var diffIdentifier: String {
        "\(self)"
    }

    public func isEqual(to item: Int) -> Bool {
        return self == item
    }
}
