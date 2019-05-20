//
//  DiffViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import Foundation
import CollectionViewTools

final class Object: Equatable {
    var color: UIColor
    var value: Int

    init(color: UIColor, value: Int) {
        self.color = color
        self.value = value
    }

    static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs.color == rhs.color
            && lhs.value == rhs.value
    }
}



class DiffViewController: UIViewController {

    private var objects: [Object] = []

    // MARK: Subviews

    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    private lazy var mainCollectionViewDiff: CollectionViewDiff = CollectionViewIGListKitDiff()
    private lazy var actionsCollectionViewManager: CollectionViewManager = .init(collectionView: actionsCollectionView)

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

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Diff"
        view.addSubview(mainCollectionView)
        view.addSubview(actionsCollectionView)
        resetMainCollection(animated: false)
        actionsCollectionViewManager.sectionItems = [makeActionsSectionItem()]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var bottomInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomInset = view.safeAreaInsets.bottom
        }
        let actionsCollectionHeight: CGFloat = 70
        mainCollectionView.frame = .init(x: 0,
                                         y: 0,
                                         width: view.bounds.width,
                                         height: view.bounds.height - actionsCollectionHeight - bottomInset)
        actionsCollectionView.frame = .init(x: 0,
                                            y: view.bounds.height - actionsCollectionHeight - bottomInset,
                                            width: view.bounds.width,
                                            height: actionsCollectionHeight)
    }

    // MARK: - Main Collection

    private func updateMainCollection(animated: Bool) {
        let sectionItems = [makeMainSectionItem(objects: objects)]
        mainCollectionViewManager.update(with: sectionItems, diff: CollectionViewIGListKitDiff(), animated: animated)
    }

    private func resetMainCollection(animated: Bool) {
        objects = makeObjects(color: .red, values: Array(0..<20))
        updateMainCollection(animated: animated)
    }

    // MARK: - Factory methods

    func makeObjects(color: UIColor, values: [Int]) -> [Object] {
        return values.map { value in
            Object(color: color, value: value)
        }
    }

    func makeMainSectionItem(objects: [Object]) -> CollectionViewDiffableSectionItem {
        let sectionItem = GeneralCollectionViewDiffableSectionItem()
        sectionItem.cellItems = objects.map { object in
            return makeColorCellItem(object: object)
        }
        sectionItem.insets = .init(top: 8, left: 8, bottom: 8, right: 8)
        sectionItem.minimumInteritemSpacing = 2
        sectionItem.minimumLineSpacing = 2
        return sectionItem
    }

    private func makeColorCellItem(object: Object) -> ColorCellItem {
        let cellItem = ColorCellItem(color: object.color, title: "\(object.value)")
        cellItem.diffIdentifier = "\(object.value)"
        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.deleteObject(object)
        }
        return cellItem
    }

    private func deleteObject(_ object: Object) {
        if let index = objects.firstIndex(of: object) {
            objects.remove(at: index)
            updateMainCollection(animated: true)
        }
    }

    func makeActionsSectionItem() -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = [
            makeResetActionCellItem(),
            // Insert cells
//            makePrependCellItemsActionCellItem(),
//            makeAppendCellItemsActionCellItem(),
//            makeInsertCellItemsInTheMiddleActionCellItem(),
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

    func makeResetActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Reset") { [weak self] in
            self?.resetMainCollection(animated: true)
        }
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
//            for sectionItem in self.mainSectionItems {
////                if sectionItem.cellItems.coun
//            }
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
