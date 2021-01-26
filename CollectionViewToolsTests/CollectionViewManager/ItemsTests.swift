//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import XCTest
@testable import CollectionViewTools

final class ItemsTests: CollectionViewTests {

    func testReusableView() {
        // Given
        let title = "Title"
        let reusableViewItem = TestReusableViewItem(title: title)
        let kind = reusableViewItem.type.kind
        // When
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: [TestCollectionViewCellItem(text: "")],
                                                                                reusableViewItems: [reusableViewItem])]
        wait(for: [expectation], timeout: 10)
        //Then
        let view = viewController.collectionView.visibleSupplementaryViews(ofKind: kind).first as? TestReusableView
        XCTAssertEqual(view?.title, title, "Title shold be \(title)")
    }

    func testCellSelection() {
        // Given
        let strings = ["1", "2", "3"]
        let selectedStrings = ["one", "two", "three"]
        let indexPath = IndexPath(item: 0, section: 0)
        // When
        let cellItems = zip(strings, selectedStrings).map { string, selectedString -> TestCollectionViewCellItem in
            let cellItem = TestCollectionViewCellItem(text: string, selectedText: selectedString)
            cellItem.itemShouldSelectResolver = { _ in
                return false
            }
            cellItem.itemShouldDeselectResolver = { _ in
               return false
            }
            return cellItem
        }
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: cellItems)]
        wait(for: [expectation], timeout: 10)
        let cell = viewController.collectionView.cellForItem(at: indexPath) as? TestCollectionViewCell
        //Then

        XCTAssertFalse(viewController.manager.collectionView(viewController.collectionView, shouldSelectItemAt: indexPath),
                      "Cell should not be selectible")
        XCTAssertFalse(viewController.manager.collectionView(viewController.collectionView, shouldDeselectItemAt: indexPath),
                      "Cell should not be deselectible")

        cellItems.forEach { cellItem in
            cellItem.itemShouldSelectResolver = { _ in
                return true
            }
            cellItem.itemShouldDeselectResolver = { _ in
                return true
            }
        }

        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView, shouldSelectItemAt: indexPath),
                      "Cell should be selectible")
        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView, shouldDeselectItemAt: indexPath),
                      "Cell should be deselectible")

        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView,
                                                            shouldSelectItemAt: IndexPath(item: 0, section: 1)),
                                    "Cell should not be selectible")
        viewController.manager.collectionView(viewController.collectionView, didSelectItemAt: indexPath)
        XCTAssertEqual(cell?.text, selectedStrings[indexPath.row], "Cell text should be equal '\(selectedStrings[indexPath.row])'")
        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView, shouldDeselectItemAt: indexPath),
                      "Cell should be selectible")
        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView,
                                                            shouldDeselectItemAt: IndexPath(item: 0, section: 1)),
                                                  "Cell should not be deselectible")
        viewController.manager.collectionView(viewController.collectionView, didDeselectItemAt: indexPath)
        XCTAssertEqual(cell?.text, strings[indexPath.row], "Cell text should be equal '\(strings[indexPath.row])'")
    }

    func testCellHighlight() {
        // Given
        let strings = ["1", "2", "3"]
        let highlightedStrings = ["one", "two", "three"]
        let indexPath = IndexPath(item: 0, section: 0)
        // When
        let cellItems = zip(strings, highlightedStrings).map { string, highlightedString -> TestCollectionViewCellItem in
            let cellItem = TestCollectionViewCellItem(text: string, highlightedText: highlightedString)
            cellItem.itemShouldHighlightResolver = { _ in
                return false
            }
            return cellItem
        }
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: cellItems)]
        wait(for: [expectation], timeout: 10)
        let cell = viewController.collectionView.cellForItem(at: indexPath) as? TestCollectionViewCell
        //Then
        XCTAssertFalse(viewController.manager.collectionView(viewController.collectionView, shouldHighlightItemAt: indexPath),
                      "Cell should not be highlightable")
        cellItems.forEach { cellItem in
            cellItem.itemShouldHighlightResolver = { _ in
                return true
            }
        }
        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView, shouldHighlightItemAt: indexPath),
        "Cell should be highlightable")
        XCTAssertFalse(viewController.manager.collectionView(viewController.collectionView,
                                                             shouldHighlightItemAt: IndexPath(item: 0, section: 1)),

                       "Cell should not be highlightable")
        viewController.manager.collectionView(viewController.collectionView, didHighlightItemAt: indexPath)
        XCTAssertEqual(cell?.text, highlightedStrings[indexPath.row], "Cell text should be equal '\(highlightedStrings[indexPath.row])'")
        viewController.manager.collectionView(viewController.collectionView, didUnhighlightItemAt: indexPath)
        XCTAssertEqual(cell?.text, strings[indexPath.row], "Cell text should be equal '\(strings[indexPath.row])'")
    }

    func testSubscripts() {
        //Given
        let strings = ["1", "2", "3"]
        let title = "Test"
        let indexPath = IndexPath(item: 0, section: 0)
        // When
        let cellItems = strings.map { string in
           TestCollectionViewCellItem(text: string)
        }
        let reusableViewItem = TestReusableViewItem(title: title)
        let sectionItem = GeneralCollectionViewSectionItem(cellItems: cellItems, reusableViewItems: [reusableViewItem])
        viewController.manager.sectionItems = [sectionItem]
        //Then
        wait(for: [expectation], timeout: 10)
        let createdSectionItem = viewController.manager[0]
        let createdCellItem = viewController.manager[indexPath] as? TestCollectionViewCellItem
        XCTAssertEqual((createdSectionItem?.reusableViewItems.first as? TestReusableViewItem)?.title,
                       reusableViewItem.title,
                       "Section item title should be '\(title)'")
        XCTAssertEqual(createdCellItem?.text, strings[0], "Cell item text should be '\(strings[0])'")
    }

    func testCellReloading() {
        //Given
        let strings1 = ["1", "2", "3"]
        let indexPath = IndexPath(item: 0, section: 0)
        // When
        let cellItems = strings1.map { string in
            TestCollectionViewCellItem(text: string)
        }
        let sectionItem = GeneralCollectionViewSectionItem(cellItems: cellItems)
        viewController.manager.sectionItems = [sectionItem]
        //Then
        wait(for: [expectation], timeout: 10)
        var cell = testCell(indexPath: indexPath)
        XCTAssertEqual(cell?.text, strings1[0], "Cell text should be '\(strings1[0])'")
        let newText = "4"
        cellItems.first?.text = newText
        let expectation = XCTestExpectation(description: "Cells reloading")
        viewController.manager.reloadCellItems(cellItems) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        cell = testCell(indexPath: indexPath)
        XCTAssertEqual(cell?.text, newText, "Cell text should be '\(newText)'")
    }

    func testGetters() {
        // Given
        let cellItem = TestCollectionViewCellItem(text: "")
        XCTAssertNil(cellItem.sectionItem)
        XCTAssertNil(cellItem.indexPath)
        let sectionItem = GeneralCollectionViewSectionItem(cellItems: [cellItem])
        XCTAssertNil(sectionItem.collectionView)
        XCTAssertNil(cellItem.collectionView)
        XCTAssertNil(cellItem.cell)
        // When
        viewController.manager.sectionItems = [sectionItem]
        // Then
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(viewController.collectionView, sectionItem.collectionView)
        XCTAssertEqual(viewController.collectionView, cellItem.collectionView)
        XCTAssertEqual(cellItem.indexPath, IndexPath(item: 0, section: 0))
        XCTAssertNotNil(cellItem.sectionItem)
        XCTAssertNotNil(cellItem.cell)
    }

    func testSetters() {
        let viewItem = TestReusableViewItem(title: "")
        let cellItem = TestCollectionViewCellItem(text: "")
        let willDisplayCellHandler = cellItem.itemWillDisplayCellHandler
        let willDisplayViewHandler = cellItem.itemWillDisplayViewHandler
        let endDisplayingCellHandler = cellItem.itemDidEndDisplayingCellHandler
        let endDisplayingViewHandler = cellItem.itemDidEndDisplayingViewHandler
        let cellExpectation = XCTestExpectation(description: "Display cell expectation")
        let viewExpectation = XCTestExpectation(description: "Display view expectation")
        let cellExpectation2 = XCTestExpectation(description: "End displaying cell expectation")
        let viewExpectation2 = XCTestExpectation(description: "End displaying view expectation")
        // When
        cellItem.itemWillDisplayViewHandler = {
            willDisplayViewHandler?($0, $1, $2, $3)
            viewExpectation.fulfill()
        }
        cellItem.itemWillDisplayCellHandler = {
            willDisplayCellHandler?($0, $1)
            cellExpectation.fulfill()
        }
        cellItem.itemDidEndDisplayingViewHandler = {
            endDisplayingViewHandler?($0, $1, $2, $3)
            viewExpectation2.fulfill()
        }
        cellItem.itemDidEndDisplayingCellHandler = {
            endDisplayingCellHandler?($0, $1)
            cellExpectation2.fulfill()
        }
        let sectionItem = GeneralCollectionViewSectionItem(cellItems: [cellItem], reusableViewItems: [viewItem])
        viewController.manager.sectionItems = [sectionItem]
        // Then
        wait(for: [expectation, cellExpectation, viewExpectation], timeout: 10)
        let expectation2 = XCTestExpectation(description: "Cells reloading")
        viewController.manager.reloadCellItems([cellItem]) { _ in
            expectation2.fulfill()
        }
        wait(for: [cellExpectation2, expectation2], timeout: 10)
        let expectation3 = XCTestExpectation(description: "Cells removing")
        viewController.manager.replace(sectionItemsAt: [0], with: [GeneralCollectionViewSectionItem(cellItems: [cellItem])]) { _ in
            expectation3.fulfill()
        }
        wait(for: [viewExpectation2, expectation3], timeout: 10)
    }
}
