//
//  DiffViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import Foundation
import CollectionViewTools

class DiffViewController: UIViewController {

    private lazy var groups: [Group] = []
    private let groupsCacheKey: String = "groups"

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
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    private lazy var actionsCollectionBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Diff"

        view.addSubview(mainCollectionView)
        view.addSubview(actionsCollectionBackgroundView)
        view.addSubview(actionsCollectionView)

        resetGroupsAndObjects()
        updateMainCollection(animated: false)

        actionsCollectionViewManager.sectionItems = [makeActionsSectionItem()]
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        actionsCollectionView.frame.size.width = view.bounds.width
        actionsCollectionView.frame.size.height = 50 + bottomLayoutGuide.length
        actionsCollectionView.frame.origin.y = view.bounds.height - actionsCollectionView.frame.height
        actionsCollectionView.contentInset.bottom = bottomLayoutGuide.length

        actionsCollectionBackgroundView.frame = actionsCollectionView.frame

        mainCollectionView.frame.size.width = view.bounds.width
        mainCollectionView.frame.size.height = view.bounds.height
        mainCollectionView.contentInset.bottom = actionsCollectionView.frame.height - bottomLayoutGuide.length
        mainCollectionView.scrollIndicatorInsets = mainCollectionView.contentInset
    }

    // MARK: - Models

    private func resetGroupsAndObjects() {
        let colors: [Color] = [.red, .green, .orange, .purple, .blue]
        //        let colors: [UIColor] = [.red, .green, .orange]
        var groupId = 1
        var objectId = 1
        groups = colors.enumerated().map { (groupIndex, color) -> Group in
            let objectsCount = 10 - groupIndex
            let objects = (0..<objectsCount).map { objectIndex -> Object in
                let object = Object(id: objectId, color: color, title: "\(objectIndex + 1)")
                objectId += 1
                return object
            }
            let group = Group(id: groupId, objects: objects, color: color, title: "Group \(groupIndex + 1)")
            groupId += 1
            return group
        }
    }

    private func setCachedGroups() {
        let cachedGroups = self.cachedGroups()
        if cachedGroups.count > 0 {
            groups = cachedGroups
        }
    }

    private func shuffleObjects() {
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
    }

    private func shuffleObjectsWithUpdates() {
        var allObjects = groups.reduce([Object]()) { objects, group in
            objects + group.objects
        }
        allObjects.shuffle()
        for group in groups {
            let objectsCount = group.objects.count
            group.objects.removeAll()
            for _ in 0..<objectsCount {
                if let object = allObjects.first {
                    object.title = updatedTitle(object.title)
                    group.objects.append(object)
                    allObjects.removeFirst()
                }
            }
        }
    }

    private func shuffleGroups() {
        groups.shuffle()
    }

    private func shuffleGroupsWithUpdates() {
        groups.shuffle()
        for group in groups {
            group.title = updatedTitle(group.title)
        }
    }

    private func updatedTitle(_ title: String) -> String {
        let titleComponents = title.components(separatedBy: "(")
        var secondValue = 1
        if titleComponents.count > 1 {
            let secondComponent = titleComponents[1].replacingOccurrences(of: ")", with: "")
            if let value = Int(secondComponent) {
                secondValue = value + 1
            }
        }
        return "\(titleComponents[0])(\(secondValue))"
    }

    private func delete(_ group: Group) {
        if let index = groups.firstIndex(of: group) {
            groups.remove(at: index)
            updateMainCollection(animated: true)
        }
    }

    private func delete(_ object: Object, from group: Group) {
        if let index = group.objects.firstIndex(of: object) {
            group.objects.remove(at: index)
            updateMainCollection(animated: true)
        }
    }

    private func cache(_ groups: [Group]) {
        let data = try? JSONEncoder().encode(groups)
        UserDefaults.standard.set(data, forKey: groupsCacheKey)
    }

    private func cachedGroups() -> [Group] {
        guard let data = UserDefaults.standard.value(forKey: groupsCacheKey) as? Data,
            let groups = try? JSONDecoder().decode([Group].self, from: data) else {
                return []
        }
        return groups
    }

    // MARK: - Main Collection

    private func updateMainCollection(animated: Bool, cache: Bool = true) {
        let oldSectionItems = mainCollectionViewManager.sectionItems
        let newSectionItems = makeMainSectionItems(groups: groups)
        print("<<< OLD ITEMS = \(oldSectionItems)")
        print("<<< NEW ITEMS = \(newSectionItems)")
        mainCollectionViewManager.update(with: newSectionItems,
                                         diff: CollectionViewIGListKitDiff(),
                                         ignoreCellItemsChanges: false,
                                         animated: animated,
                                         completion: { [weak self] _ in
                                            print("<<< COMPLETED!!!")
                                            if cache, let self = self {
                                                self.cache(self.groups)
                                            }

        })
    }

    func makeMainSectionItems(groups: [Group]) -> [CollectionViewDiffableSectionItem] {
        return groups.map { group in
            makeMainSectionItem(group: group)
        }
    }

    func makeMainSectionItem(group: Group) -> CollectionViewDiffableSectionItem {
        let sectionItem = GeneralCollectionViewDiffableSectionItem()
        sectionItem.diffIdentifier = "\(group.id)"
        sectionItem.cellItems.append(makeGroupTitleCellItem(group: group))
        for object in group.objects {
            let cellItem = makeColorCellItem(object: object, group: group)
            sectionItem.cellItems.append(cellItem)
        }
        sectionItem.insets = .init(top: 8, left: 8, bottom: 8, right: 8)
        sectionItem.minimumInteritemSpacing = 2
        sectionItem.minimumLineSpacing = 2
        return sectionItem
    }

    private func makeGroupTitleCellItem(group: Group) -> TextCellItem {
        let cellItem = TextCellItem(text: group.title,
                                    backgroundColor: group.color.uiColor,
                                    font: .systemFont(ofSize: 16),
                                    roundCorners: true,
                                    contentRelatedWidth: false)
        cellItem.diffIdentifier = "group_title_\(group.id)"
        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.delete(group)
        }
        return cellItem
    }

    private func makeColorCellItem(object: Object, group: Group) -> ColorCellItem {
        let cellItem = ColorCellItem(color: object.color.uiColor, title: "\(object.title)")
        cellItem.diffIdentifier = "object_item_\(object.id)"
        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.delete(object, from: group)
        }
        return cellItem
    }

    // MARK: - Actions collection

    func makeActionsSectionItem() -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = [
            makeResetActionCellItem(),
            makeCacheActionCellItem(),
            // Sections
            makeShuffleSectionsActionCellItem(),
            makeShuffleSectionsWithUpdatesActionCellItem(),
            // Sections And Cells
            makeShuffleSectionsAndCellsActionCellItem(),
            makeShuffleSectionsAndCellsWithUpdatesActionCellItem(),
            // Cells
            makeShuffleCellsActionCellItem(),
            makeShuffleCellsWithUpdatesActionCellItem(),
        ]
        sectionItem.insets = .init(top: 0, left: 8, bottom: 0, right: 8)
        sectionItem.minimumInteritemSpacing = 8
        sectionItem.minimumLineSpacing = 8
        return sectionItem
    }

    func makeResetActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Reset") { [weak self] in
            self?.resetGroupsAndObjects()
            self?.updateMainCollection(animated: true, cache: false)
        }
    }

    func makeCacheActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Use Cache") { [weak self] in
            self?.setCachedGroups()
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleCellsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle cells") { [weak self] in
            self?.shuffleObjects()
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleCellsWithUpdatesActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle cells with updates") { [weak self] in
            self?.shuffleObjectsWithUpdates()
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle sections") { [weak self] in
            self?.shuffleGroups()
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionsWithUpdatesActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle sections with updates") { [weak self] in
            self?.shuffleGroupsWithUpdates()
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionsAndCellsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle cells and sections") { [weak self] in
            self?.shuffleObjects()
            self?.shuffleGroups()
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionsAndCellsWithUpdatesActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle cells and sections with updates") { [weak self] in
            self?.shuffleObjectsWithUpdates()
            self?.shuffleGroupsWithUpdates()
            self?.updateMainCollection(animated: true)
        }
    }

    func makeActionCellItem(title: String, action: @escaping (() -> Void)) -> CollectionViewCellItem {
        let cellItem = TextCellItem(text: title, backgroundColor: .white, roundCorners: true)
        cellItem.itemDidSelectHandler = { _ in
            action()
        }
        return cellItem
    }
}
