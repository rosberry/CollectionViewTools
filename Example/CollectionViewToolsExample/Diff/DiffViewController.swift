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
    private var lastGroupId: Int = 1
    private var lastObjectId: Int = 1


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
        mainCollectionView.contentInset.top = 8
        mainCollectionView.contentInset.bottom = 8 + actionsCollectionView.frame.height - bottomLayoutGuide.length
        mainCollectionView.scrollIndicatorInsets = mainCollectionView.contentInset
    }

    // MARK: - Models

    private func makeGroup(color: Color, objectsCount: Int) -> Group {
        let objects = (0..<objectsCount).map { objectIndex -> Object in
            let object = Object(id: lastObjectId, color: color, title: "\(lastObjectId)")
            lastObjectId += 1
            return object
        }
        let group = Group(id: lastGroupId, objects: objects, color: color, title: "Section \(lastGroupId)")
        lastGroupId += 1
        return group
    }

    private func resetGroupsAndObjects() {
        let colors: [Color] = [.red, .green, .orange, .purple, .blue]
        lastGroupId = 1
        lastObjectId = 1
        groups = colors.enumerated().map { (groupIndex, color) -> Group in
            let objectsCount = 10 - groupIndex
            return makeGroup(color: color, objectsCount: objectsCount)
        }
    }

    private func setCachedGroups() {
        let cachedGroups = self.cachedGroups()
        if cachedGroups.count > 0 {
            groups = cachedGroups
        }
    }

    private func shuffleAllObjects(withUpdates: Bool) {
        var allObjects = groups.reduce([Object]()) { objects, group in
            objects + group.objects
        }
        allObjects.shuffle()
        for group in groups {
            let objectsCount = group.objects.count
            group.objects.removeAll()
            for _ in 0..<objectsCount {
                if let object = allObjects.first {
                    if withUpdates {
                        object.title = updatedTitle(object.title)
                    }
                    group.objects.append(object)
                    allObjects.removeFirst()
                }
            }
        }
    }

    private func shuffleGroupObjects(withUpdates: Bool) {
        for group in groups {
            group.objects.shuffle()
            if withUpdates {
                for object in group.objects {
                    object.title = updatedTitle(object.title)
                }
            }
        }
    }

    private func shuffleGroups(withTitleUpdates: Bool, objectUpdates withObjectUpdates: Bool) {
        groups.shuffle()
        if withTitleUpdates {
            for group in groups {
                group.title = updatedTitle(group.title)
            }
        }
        if withObjectUpdates {
            for group in groups {
                for object in group.objects {
                    object.title = updatedTitle(object.title)
                }
            }
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

    private func insertGroup(after group: Group) {
        if let index = groups.firstIndex(of: group) {
            let newGroup = makeGroup(color: .random, objectsCount: 10)
            groups.insert(newGroup, at: index + 1)
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
                                         diff: CollectionViewDeepDiff(),
                                         ignoreCellItemsChanges: false,
                                         animated: animated,
                                         completion: { [weak self] _ in
                                            if cache, let self = self {
                                                self.cache(self.groups)
                                            }

        })
    }

    func makeMainSectionItems(groups: [Group]) -> [CollectionViewDiffableSectionItem] {
        return groups.reduce([]) { (result, group) in
            result + [makeGroupSectionItem(group: group), makePlusSectionItem(after: group)]
        }
    }

    func makeGroupSectionItem(group: Group) -> CollectionViewDiffableSectionItem {
        let sectionItem = GeneralCollectionViewDiffableSectionItem()
        sectionItem.diffIdentifier = "\(group.id)"
        sectionItem.cellItems.append(makeGroupTitleCellItem(group: group))
        for object in group.objects {
            let cellItem = makeColorCellItem(object: object, group: group)
            sectionItem.cellItems.append(cellItem)
        }
        sectionItem.insets = .init(top: 0, left: 8, bottom: 0, right: 8)
        sectionItem.minimumInteritemSpacing = 2
        sectionItem.minimumLineSpacing = 2
        return sectionItem
    }

    func makePlusSectionItem(after group: Group) -> CollectionViewDiffableSectionItem {
        let sectionItem = GeneralCollectionViewDiffableSectionItem()
        sectionItem.diffIdentifier = "plus_\(group.id)"
        sectionItem.cellItems.append(makeGroupPlusCellItem(group: group))
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

    private func makeGroupPlusCellItem(group: Group) -> TextCellItem {
        let cellItem = TextCellItem(text: "+",
                                    backgroundColor: .white,
                                    font: .systemFont(ofSize: 20),
                                    roundCorners: false,
                                    contentRelatedWidth: false)
        cellItem.diffIdentifier = "group_plus_\(group.id)"
        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.insertGroup(after: group)
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
            makeShuffleAllCellsActionCellItem(),
            makeShuffleAllCellsWithUpdatesActionCellItem(),
            makeShuffleSectionCellsActionCellItem(),
            makeShuffleSectionCellsWithUpdatesActionCellItem()

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

    func makeShuffleSectionsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle sections") { [weak self] in
            self?.shuffleGroups(withTitleUpdates: false, objectUpdates: false)
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionsWithUpdatesActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle sections with updates") { [weak self] in
            self?.shuffleGroups(withTitleUpdates: true, objectUpdates: true)
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionsAndCellsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle cells and sections") { [weak self] in
            self?.shuffleAllObjects(withUpdates: false)
            self?.shuffleGroups(withTitleUpdates: false, objectUpdates: false)
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionsAndCellsWithUpdatesActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle cells and sections with updates") { [weak self] in
            self?.shuffleAllObjects(withUpdates: true)
            self?.shuffleGroups(withTitleUpdates: true, objectUpdates: false)
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleAllCellsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle all cells") { [weak self] in
            self?.shuffleAllObjects(withUpdates: false)
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleAllCellsWithUpdatesActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle all cells with updates") { [weak self] in
            self?.shuffleAllObjects(withUpdates: true)
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionCellsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle section cells") { [weak self] in
            self?.shuffleGroupObjects(withUpdates: false)
            self?.updateMainCollection(animated: true)
        }
    }

    func makeShuffleSectionCellsWithUpdatesActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Shuffle section cells with updates") { [weak self] in
            self?.shuffleGroupObjects(withUpdates: true)
            self?.updateMainCollection(animated: true)
        }
    }

    func makeActionCellItem(title: String,
                            backgroundColor: UIColor = .white,
                            action: @escaping (() -> Void)) -> TextCellItem {
        let cellItem = TextCellItem(text: title, backgroundColor: backgroundColor, roundCorners: true)
        cellItem.diffIdentifier = "action_\(title)"
        cellItem.itemDidSelectHandler = { _ in
            action()
        }
        return cellItem
    }
}
