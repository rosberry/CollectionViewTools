//
//  CollectionViewToolsTests.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import XCTest
@testable import CollectionViewTools

class CollectionViewToolsTests: XCTestCase {
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

        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView, shouldSelectItemAt: IndexPath(item: 0, section: 1)),
                                    "Cell should not be selectible")
        viewController.manager.collectionView(viewController.collectionView, didSelectItemAt: indexPath)
        XCTAssertEqual(cell?.text, selectedStrings[indexPath.row], "Cell text should be equal '\(selectedStrings[indexPath.row])'")
        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView, shouldDeselectItemAt: indexPath),
                      "Cell should be selectible")
        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView, shouldDeselectItemAt: IndexPath(item: 0, section: 1)),
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
        XCTAssertFalse(viewController.manager.collectionView(viewController.collectionView, shouldHighlightItemAt: IndexPath(item: 0, section: 1)),
                    "Cell should not be highlightable")
        viewController.manager.collectionView(viewController.collectionView, didHighlightItemAt: indexPath)
        XCTAssertEqual(cell?.text, highlightedStrings[indexPath.row], "Cell text should be equal '\(highlightedStrings[indexPath.row])'")
        viewController.manager.collectionView(viewController.collectionView, didUnhighlightItemAt: indexPath)
        XCTAssertEqual(cell?.text, strings[indexPath.row], "Cell text should be equal '\(strings[indexPath.row])'")
    }

    func testCellRemoving() {
        // Given
        let strings = ["1", "2", "3"]
        let title = "Title"
        let reusableViewItem = TestReusableViewItem(title: title)
        let kind = reusableViewItem.type.kind
        // When
        let cellItems = strings.map { string in
            TestCollectionViewCellItem(text: string)
        }
        viewController.manager.sectionItems = [GeneralCollectionViewSectionItem(cellItems: cellItems,
                                                                                reusableViewItems: [reusableViewItem])]
        wait(for: [expectation], timeout: 10)
        viewController.manager.sectionItems = []
        //Then
        XCTAssertEqual(viewController.collectionView.visibleCells.count, 0)
        let view = viewController.collectionView.visibleSupplementaryViews(ofKind: kind).first as? TestReusableView
        XCTAssertNil(view, "View should be removed")
    }

    func testCellsMoving() {
        // Given
        let strings = ["1", "2", "3"]
        let indexPath = IndexPath(item: 0, section: 0)
        let indexPath1 = IndexPath(item: 1, section: 0)
        // When
        let cellItems = strings.map { string in
            TestCollectionViewCellItem(text: string)
        }
        let sectionItem = GeneralCollectionViewSectionItem(cellItems: cellItems)
        viewController.manager.sectionItems = [sectionItem]
        //Then
        wait(for: [expectation], timeout: 10)
        XCTAssertFalse(viewController.manager.collectionView(viewController.collectionView, canMoveItemAt: indexPath))
        cellItems.forEach { cellItem in
            cellItem.itemCanMoveResolver = { _ in
                return true
            }
        }
        XCTAssertTrue(viewController.manager.collectionView(viewController.collectionView, canMoveItemAt: indexPath))
        viewController.manager.move(cellItemAt: 0, to: 1, in: sectionItem)
        let cell = viewController.collectionView.cellForItem(at: indexPath1) as? TestCollectionViewCell
        XCTAssertEqual(cell?.text, strings[0], "Cell text should be '\(strings[0])'")
    }

    func testSectionMoving() {
        // Given
        let strings1 = ["1", "2", "3"]
        let strings2 = ["4", "5", "6"]
        let indexPath = IndexPath(item: 0, section: 0)
        // When
        let cellItems1 = strings1.map { string in
            TestCollectionViewCellItem(text: string)
        }
        let cellItems2 = strings2.map { string in
            TestCollectionViewCellItem(text: string)
        }
        let sectionItem1 = GeneralCollectionViewSectionItem(cellItems: cellItems1)
        let sectionItem2 = GeneralCollectionViewSectionItem(cellItems: cellItems2)
        viewController.manager.sectionItems = [sectionItem1, sectionItem2]
        //Then
        wait(for: [expectation], timeout: 10)
        viewController.manager.move(sectionItemAt: 1, to: 0)
        let cell = viewController.collectionView.cellForItem(at: indexPath) as? TestCollectionViewCell
        XCTAssertEqual(cell?.text, strings2[0], "Cell text should be '\(strings2[0])'")
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
        XCTAssertEqual((createdSectionItem?.reusableViewItems.first as? TestReusableViewItem)?.title, reusableViewItem.title, "Section item title should be '\(title)'")
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

    func testScroll() {
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
        viewController.manager.scroll(to: cellItems.first!, at: .top, animated: false)
        XCTAssertEqual(viewController.collectionView.contentOffset.y, -44)
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

    func testReplaceAll() {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        let cellItem1 = TestCollectionViewCellItem(text: "1")
        let cellItem2 = TestCollectionViewCellItem(text: "2")
        let cellItem3 = TestCollectionViewCellItem(text: "3")
        let cellItem4 = TestCollectionViewCellItem(text: "4")

        let sectionItem = GeneralCollectionViewSectionItem(cellItems: [cellItem1, cellItem2])
        // When
        viewController.manager.sectionItems = [sectionItem]
        // Then
        wait(for: [expectation], timeout: 10)
        var cell = testCell(indexPath: indexPath)
        XCTAssertEqual(cell?.text, "1")
        let expectation = XCTestExpectation(description: "Cells replacing")
        viewController.manager.replaceAllCellItems(in: sectionItem, with: [cellItem3, cellItem4]) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
        cell = testCell(indexPath: indexPath)
        XCTAssertEqual(cell?.text, "3")
    }

    func testInsert() {
        // Given
        let indexPath = IndexPath(item: 0, section: 0)
        let cellItem1 = TestCollectionViewCellItem(text: "1")
        let cellItem2 = TestCollectionViewCellItem(text: "2")
        let cellItem3 = TestCollectionViewCellItem(text: "3")
        let cellItem4 = TestCollectionViewCellItem(text: "4")
        let cellItem5 = TestCollectionViewCellItem(text: "5")

        let sectionItem1 = GeneralCollectionViewSectionItem(cellItems: [cellItem1, cellItem2])
        let sectionItem2 = GeneralCollectionViewSectionItem(cellItems: [cellItem3, cellItem4])
        // When
        viewController.manager.sectionItems = [sectionItem1]
        // Then
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 1)
        let sectionExpectation = XCTestExpectation(description: "Section insertion")
        viewController.manager.insert([sectionItem2], at: [0]) { _ in
            sectionExpectation.fulfill()
        }
        wait(for: [sectionExpectation], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 2)
        var cell = testCell(indexPath: indexPath)
        XCTAssertEqual(cell?.text, "3")

        let cellExpectation = XCTestExpectation(description: "Cell inserion")
        viewController.manager.insert([cellItem5], to: sectionItem2, at: [0]) { _ in
            cellExpectation.fulfill()
        }
        wait(for: [cellExpectation], timeout: 10)
        cell = testCell(indexPath: indexPath)
        XCTAssertEqual(cell?.text, "5")
    }

    func testAppend() {
        // Given
        let cellItem1 = TestCollectionViewCellItem(text: "1")
        let cellItem2 = TestCollectionViewCellItem(text: "2")
        let cellItem3 = TestCollectionViewCellItem(text: "3")
        let cellItem4 = TestCollectionViewCellItem(text: "4")
        let cellItem5 = TestCollectionViewCellItem(text: "5")

        let sectionItem1 = GeneralCollectionViewSectionItem(cellItems: [cellItem1, cellItem2])
        let sectionItem2 = GeneralCollectionViewSectionItem(cellItems: [cellItem3, cellItem4])
        // When
        viewController.manager.sectionItems = [sectionItem1]
        // Then
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 1)
        let sectionExpectation = XCTestExpectation(description: "Section append")
        viewController.manager.append([sectionItem2]) { _ in
            sectionExpectation.fulfill()
        }
        wait(for: [sectionExpectation], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 2)
        var cell = testCell(item: 0, section: 1)
        XCTAssertEqual(cell?.text, "3")

        let cellExpectation = XCTestExpectation(description: "Cell append")
        viewController.manager.append([cellItem5], to: sectionItem1) { _ in
            cellExpectation.fulfill()
        }
        wait(for: [cellExpectation], timeout: 10)
        cell = testCell(item: 2, section: 0)
        XCTAssertEqual(cell?.text, "5")
    }

    func testPrepend() {
        // Given
        let cellItem1 = TestCollectionViewCellItem(text: "1")
        let cellItem2 = TestCollectionViewCellItem(text: "2")
        let cellItem3 = TestCollectionViewCellItem(text: "3")
        let cellItem4 = TestCollectionViewCellItem(text: "4")
        let cellItem5 = TestCollectionViewCellItem(text: "5")

        let sectionItem1 = GeneralCollectionViewSectionItem(cellItems: [cellItem1, cellItem2])
        let sectionItem2 = GeneralCollectionViewSectionItem(cellItems: [cellItem3, cellItem4])
        // When
        viewController.manager.sectionItems = [sectionItem1]
        // Then
        wait(for: [expectation], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 1)
        let sectionExpectation = XCTestExpectation(description: "Section append")
        viewController.manager.prepend([sectionItem2]) { _ in
            sectionExpectation.fulfill()
        }
        wait(for: [sectionExpectation], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 2)
        var cell = testCell(item: 0, section: 0)
        XCTAssertEqual(cell?.text, "3")

        let cellExpectation = XCTestExpectation(description: "Cell append")
        viewController.manager.prepend([cellItem5], to: sectionItem1) { _ in
            cellExpectation.fulfill()
        }
        wait(for: [cellExpectation], timeout: 10)
        cell = testCell(item: 0, section: 1)
        XCTAssertEqual(cell?.text, "5")
    }

    func testReplace() {
        // Given
        let cellItem1 = TestCollectionViewCellItem(text: "1")
        let cellItem2 = TestCollectionViewCellItem(text: "2")
        let cellItem3 = TestCollectionViewCellItem(text: "3")
        let cellItem4 = TestCollectionViewCellItem(text: "4")
        let cellItem5 = TestCollectionViewCellItem(text: "5")

        let sectionItem1 = GeneralCollectionViewSectionItem(cellItems: [cellItem1, cellItem2])
        let sectionItem2 = GeneralCollectionViewSectionItem(cellItems: [cellItem3, cellItem4])
        // When
        viewController.manager.sectionItems = [sectionItem1]
        // Then
        wait(for: [expectation], timeout: 10)
        let sectionExpectation = XCTestExpectation(description: "Section replace")
        viewController.manager.replace(sectionItemsAt: [0], with: [sectionItem1, sectionItem2]) { _ in
            sectionExpectation.fulfill()
        }
        XCTAssertEqual(viewController.collectionView.numberOfSections, 2)
        var cell = testCell(item: 0, section: 1)
        XCTAssertEqual(cell?.text, "3")
        wait(for: [sectionExpectation], timeout: 10)

        let sectionExpectation2 = XCTestExpectation(description: "Section replace 2")
        viewController.manager.replace(sectionItemsAt: [0, 1], with: [sectionItem1]) { _ in
            sectionExpectation2.fulfill()
        }
        wait(for: [sectionExpectation2], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 1)
        cell = testCell(item: 0, section: 0)
        XCTAssertEqual(cell?.text, "1")

        let sectionExpectation3 = XCTestExpectation(description: "Section replace 3")
        viewController.manager.replace(sectionItemsAt: [0], with: [sectionItem2]) { _ in
            sectionExpectation3.fulfill()
        }
        wait(for: [sectionExpectation3], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 1)
        cell = testCell(item: 0, section: 0)
        XCTAssertEqual(cell?.text, "3")

        let cellExpectation = XCTestExpectation(description: "Cell replace")
        viewController.manager.replace(cellItemsAt: [0, 1], with: [cellItem5], in: sectionItem2) { _ in
            cellExpectation.fulfill()
        }
        wait(for: [cellExpectation], timeout: 10)
        cell = testCell(item: 0, section: 0)
        XCTAssertEqual(cell?.text, "5")

        let cellExpectation2 = XCTestExpectation(description: "Cell replace 2")
        viewController.manager.replace(cellItemsAt: [0], with: [cellItem1], in: sectionItem2) { _ in
            cellExpectation2.fulfill()
        }
        wait(for: [cellExpectation2], timeout: 10)
        cell = testCell(item: 0, section: 0)
        XCTAssertEqual(cell?.text, "1")

        let cellExpectation3 = XCTestExpectation(description: "Cell replace 3")
        viewController.manager.replace(cellItemsAt: [0], with: [cellItem1, cellItem2], in: sectionItem2) { _ in
            cellExpectation3.fulfill()
        }
        wait(for: [cellExpectation3], timeout: 10)
        cell = testCell(item: 1, section: 0)
        XCTAssertEqual(cell?.text, "2")
    }

    func testRemove() {
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
        XCTAssertEqual(viewController.collectionView.numberOfSections, 2)
        let sectionExpectation = XCTestExpectation(description: "Section remove")
        viewController.manager.remove([sectionItem1]) { _ in
            sectionExpectation.fulfill()
        }
        wait(for: [sectionExpectation], timeout: 10)
        XCTAssertEqual(viewController.collectionView.numberOfSections, 1)
        var cell = testCell(item: 0, section: 0)
        XCTAssertEqual(cell?.text, "3")

        let cellExpectation = XCTestExpectation(description: "Cell remove")
        viewController.manager.remove([cellItem3]) { _ in
            cellExpectation.fulfill()
        }
        wait(for: [cellExpectation], timeout: 10)
        cell = testCell(item: 0, section: 0)
        XCTAssertEqual(cell?.text, "4")

        let cellExpectation2 = XCTestExpectation(description: "Cell remove 2")
        viewController.manager.removeCellItems(at: [0], from: sectionItem2) { _ in
            cellExpectation2.fulfill()
        }
        wait(for: [cellExpectation2], timeout: 10)
        cell = testCell(item: 0, section: 0)
        XCTAssertNil(cell)

        let sectionExpectation2 = XCTestExpectation(description: "Section remove 2")
        viewController.manager.remove(sectionItemsAt: [0]) { _ in
            sectionExpectation2.fulfill()
        }
        XCTAssertEqual(viewController.collectionView.numberOfSections, 0)
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

    // MARK: - Private

    private func testCell(item: Int, section: Int) -> TestCollectionViewCell? {
        testCell(indexPath: IndexPath(item: item, section: section))
    }

    private func testCell(indexPath: IndexPath) -> TestCollectionViewCell? {
        viewController.collectionView.cellForItem(at: indexPath) as? TestCollectionViewCell
    }
}
