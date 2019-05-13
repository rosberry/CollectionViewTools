//
//  DiffViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import Foundation
import CollectionViewTools

class DiffViewController: UIViewController {

    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    private lazy var actionsCollectionViewManager: CollectionViewManager = .init(collectionView: actionsCollectionView)

    // MARK: Subviews

    private lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    private lazy var actionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .lightGray
        return view
    }()
    private lazy var mainSectionItems: [CollectionViewSectionItem] = [makeColorSectionItem(color: .red, itemsCount: 20),
                                                                      makeColorSectionItem(color: .orange, itemsCount: 20),
                                                                      makeColorSectionItem(color: .green, itemsCount: 20)]

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Diff"
        view.addSubview(mainCollectionView)
        mainCollectionViewManager.sectionItems = mainSectionItems
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        mainCollectionView.frame = view.bounds
    }

    // MARK: - Factory methods

    func makeColorSectionItem(color: UIColor, itemsCount: Int) -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = (0..<itemsCount).map { _ in
            return makeColorCellItem(color: color)
        }
        sectionItem.insets = .init(top: 8, left: 8, bottom: 8, right: 8)
        sectionItem.minimumInteritemSpacing = 2
        sectionItem.minimumLineSpacing = 2
        return sectionItem
    }

    private func makeColorCellItem(color: UIColor) -> ColorCellItem {
        let cellItem = ColorCellItem(color: color)
        cellItem.identifier = UUID().uuidString
        return cellItem
    }

    func makeActionsSectionItem() -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = [
            //            makeResetActionCellItem(),
            // Insert cells
//            makePrependCellItemsActionCellItem(),
//            makeAppendCellItemsActionCellItem(),
            makeInsertCellItemsInTheMiddleActionCellItem(),
            // Insert sections
            //            makePrependSectionItemActionCellItem(),
            //            makeAppendSectionItemActionCellItem(),
            //            makeInsertSectionItemInTheMiddleActionCellItem(),
            //            // Remove cells
            //            makeRemoveRandomCellActionCellItem(),
            //            // Remove sections
            //            makeRemoveRandomSectionActionCellItem(),
            //            // Replace cells
            //            makeReplaceCellItemsActionCellItem(),
            //            // Replace sections
            //            makeReplaceSectionItemsActionCellItem()
        ]
        sectionItem.insets = .init(top: 0, left: 8, bottom: 0, right: 8)
        sectionItem.minimumInteritemSpacing = 8
        sectionItem.minimumLineSpacing = 8
        return sectionItem
    }

    // MARK: Insert cells

//    func makePrependCellItemsActionCellItem() -> CollectionViewCellItem {
//        return makeActionCellItem(title: "Prepend cells") { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            guard let sectionItem = self.mainCollectionViewManager.sectionItems.first else {
//                return
//            }
//            let cellItems = self.shuffledImages.map { image in
//                return self.makeImageCellItem(image: image)
//            }
//            self.mainCollectionView.scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
//            self.mainCollectionViewManager.prepend(cellItems, to: sectionItem) { [weak self] _ in
//                self?.mainCollectionView.scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
//            }
//        }
//    }
//
//    func makeAppendCellItemsActionCellItem() -> CollectionViewCellItem {
//        return makeActionCellItem(title: "Append cells") { [weak self] in
//            guard let `self` = self else {
//                return
//            }
//            guard let sectionItem = self.mainCollectionViewManager.sectionItems.first else {
//                return
//            }
//            let cellItems = self.shuffledImages.map { image in
//                return self.makeImageCellItem(image: image)
//            }
//            self.mainCollectionView.scrollToItem(at: .init(row: sectionItem.cellItems.count - 1, section: 0), at: .bottom, animated: true)
//            self.mainCollectionViewManager.append(cellItems, to: sectionItem) { [weak self] _ in
//                let indexPath = IndexPath(row: sectionItem.cellItems.count - 1, section: 0)
//                self?.mainCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//            }
//        }
//    }

    func makeInsertCellItemsInTheMiddleActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Insert cells in the middle") { [weak self] in
            guard let `self` = self else {
                return
            }
            for sectionItem in self.mainSectionItems {
//                if sectionItem.cellItems.coun
            }
        }
    }

    func makeActionCellItem(title: String, action: @escaping (() -> Void)) -> CollectionViewCellItem {
        let cellItem = TextCellItem(text: title)
        cellItem.itemDidSelectHandler = { _ in
            action()
        }
        return cellItem
    }
}
