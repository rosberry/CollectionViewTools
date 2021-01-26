//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit
import XCTest
@testable import CollectionViewTools

final class CollectionEdditingTests: CollectionViewTests {

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
}
