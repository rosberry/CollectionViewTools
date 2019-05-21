//
//  DiffViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import Foundation
import CollectionViewTools

final class Group: Equatable, CustomStringConvertible {

    let id: Int
    var objects: [Object]

    init(id: Int, objects: [Object]) {
        self.id = id
        self.objects = objects
    }

    static func == (lhs: Group, rhs: Group) -> Bool {
        return lhs.id == rhs.id
            && lhs.objects == rhs.objects
    }

    var description: String {
        return "id = \(id), objects = \(objects)"
    }
}

final class Object: Equatable, CustomStringConvertible {

    let id: Int
    var color: UIColor
    var value: Int

    init(id: Int, color: UIColor, value: Int) {
        self.id = id
        self.color = color
        self.value = value
    }

    static func == (lhs: Object, rhs: Object) -> Bool {
        return lhs.id == rhs.id
            && lhs.color == rhs.color
            && lhs.value == rhs.value
    }

    var description: String {
        let colorString = "\(color)".replacingOccurrences(of: "UIExtendedSRGBColorSpace ", with: "")
        return "id = \(id), color = \(colorString), value = \(value)"
    }
}

class DiffViewController: UIViewController {

    private lazy var groups: [Group] = []

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
        let actionsCollectionHeight: CGFloat = 40
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
        let oldSectionItems = mainCollectionViewManager.sectionItems
        let newSectionItems = makeMainSectionItems(groups: groups)
        if oldSectionItems.count > 0, newSectionItems.count > 0 {
            print("<<< OLD ITEMS = \(oldSectionItems)")
            print("<<< NEW ITEMS = \(newSectionItems)")
        }
        mainCollectionViewManager.update(with: newSectionItems,
                                         diff: CollectionViewIGListKitDiff(),
                                         animated: animated)
    }

    private func resetMainCollection(animated: Bool) {
        groups = makeGroups()

//        groups = [
//            Group(id: 1, objects: [
//                Object(id: 2, color: .red, value: 2),
//                Object(id: 12, color: .green, value: 6),
//                Object(id: 6, color: .red, value: 6),
//                Object(id: 5, color: .red, value: 5),
//                Object(id: 4, color: .red, value: 4),
//                Object(id: 9, color: .green, value: 3),
//                ])
//        ]

        updateMainCollection(animated: animated)
    }

    private func shuffleMainCells(animated: Bool) {
//        let green = groups[0]
//        let blue = groups[1]
//
//        let greenZero = green.objects[0]
//        let blueOne = blue.objects[1]
//
//        green.objects.remove(at: 0)
//        green.objects.insert(blueOne, at: 0)
//
//        blue.objects.remove(at: 1)
//        blue.objects.insert(greenZero, at: 1)

//        groups = [
//            Group(id: 2, objects: [
//                Object(id: 1, color: .red, value: 1),
//                Object(id: 2, color: .red, value: 2),
//                Object(id: 3, color: .red, value: 3),
//                Object(id: 4, color: .red, value: 4),
//                Object(id: 5, color: .red, value: 5),
//                Object(id: 6, color: .red, value: 6),
//                ])
//        ]

        var allObjects = groups.reduce([Object]()) { objects, group in
            objects + group.objects
        }
        allObjects.shuffle()
        for group in groups {
            let objectsCount = group.objects.count
            group.objects.removeAll()
            for _ in 0..<objectsCount {
                if let object = allObjects.first {
                    group.objects.append(object)
                    allObjects.removeFirst()
                }
            }
        }
        updateMainCollection(animated: animated)
    }

    private func shuffleMainSections(animated: Bool) {
        groups.shuffle()
        updateMainCollection(animated: animated)
    }

    // MARK: - Factory methods

    func makeGroups() -> [Group] {
        let colors: [UIColor] = [.red, .green, .orange, .purple]
        var groupId = 1
        var objectId = 1
        return colors.map { color -> Group in
            let objects = (0..<6).map { index -> Object in
                let object = Object(id: objectId, color: color, value: index + 1)
                objectId += 1
                return object
            }
            let group = Group(id: groupId, objects: objects)
            groupId += 1
            return group
        }
    }

    func makeMainSectionItems(groups: [Group]) -> [CollectionViewDiffableSectionItem] {
        return groups.map { group in
            makeMainSectionItem(group: group)
        }
    }

    func makeMainSectionItem(group: Group) -> CollectionViewDiffableSectionItem {
        let sectionItem = GeneralCollectionViewDiffableSectionItem()
        sectionItem.diffIdentifier = "\(group.id)"
        sectionItem.cellItems = group.objects.map { object in
            makeColorCellItem(object: object, group: group)
        }
        sectionItem.insets = .init(top: 8, left: 8, bottom: 8, right: 8)
        sectionItem.minimumInteritemSpacing = 2
        sectionItem.minimumLineSpacing = 2
        return sectionItem
    }

    private func makeColorCellItem(object: Object, group: Group) -> ColorCellItem {
        let cellItem = ColorCellItem(color: object.color, title: "\(object.value)")
        cellItem.diffIdentifier = "\(object.id)"
        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.delete(object, from: group)
        }
        return cellItem
    }

    private func delete(_ object: Object, from group: Group) {
        if let index = group.objects.firstIndex(of: object) {
            group.objects.remove(at: index)
            updateMainCollection(animated: true)
        }
    }

    func makeActionsSectionItem() -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = [
            makeResetActionCellItem(),
            // Cells
            makeShuffleCellsActionCellItem(),
            // Sections
            makeShuffleSectionsActionCellItem()
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

    func makeShuffleCellsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle cells") { [weak self] in
            self?.shuffleMainCells(animated: true)
        }
    }

    func makeShuffleSectionsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle sections") { [weak self] in
            self?.shuffleMainSections(animated: true)
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
