//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import Foundation
import CollectionViewTools

final class DiffViewController: UIViewController {

    typealias Diff = (name: String, value: CollectionViewDiffAdaptor)

    private lazy var groups: [Group] = []
    private let groupsCacheKey: String = "groups"
    private var lastGroupId: Int = 1
    private var lastObjectId: Int = 1
    private let defaultObjectsCount: Int = 10

    // MARK: - Subviews

    private lazy var mainCollectionViewDiffs: [Diff] = [("DeepDiff", CollectionViewDeepDiffAdaptor()),
                                                         ("IGListKit", CollectionViewIGListKitDiffAdaptor())]
    private lazy var mainCollectionViewDiff: Diff = mainCollectionViewDiffs[0]
    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
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

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "CollectionViewTools"
        updateRightBarButtonItem()

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

    private func updateRightBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: mainCollectionViewDiff.name,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(presentDiffSelectionPopup))
    }

    // MARK: - Models

    private func makeGroup(color: Color, title: String, objectsCount: Int) -> Group {
        let objects = (0..<objectsCount).map { objectIndex in
            makeObject(color: color, title: "\(objectIndex + 1)")
        }
        let group = Group(id: lastGroupId, objects: objects, color: color, title: title)
        lastGroupId += 1
        return group
    }

    private func makeObject(color: Color, title: String) -> Object {
        let object = Object(id: lastObjectId, color: color, title: title)
        lastObjectId += 1
        return object
    }

    func group(forId groupId: Int) -> Group? {
        return groups.first { group -> Bool in
            group.id == groupId
        }
    }

    private func resetGroupsAndObjects() {
        let colors: [Color] = [.red, .green, .orange, .purple, .blue]
        lastGroupId = 1
        lastObjectId = 1
        groups = colors.enumerated().map { (groupIndex, color) -> Group in
            makeGroup(color: color,
                      title: groupTitle(with: groupIndex + 1),
                      objectsCount: defaultObjectsCount)
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
        shuffleGroupObjects(for: groups, withUpdates: withUpdates)
    }

    private func shuffleGroupObjects(for groups: [Group], withUpdates: Bool) {
        for group in groups {
            if let group = self.group(forId: group.id) {
                group.objects.shuffle()
                if withUpdates {
                    for object in group.objects {
                        object.title = updatedTitle(object.title)
                    }
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
        }
    }

    private func delete(_ object: Object, from group: Group) {
        if let group = self.group(forId: group.id),
           let index = group.objects.firstIndex(of: object) {
            group.objects.remove(at: index)
        }
    }

    private func insertGroup(after group: Group) {
        if let index = groups.firstIndex(of: group) {
            let newGroup = makeGroup(color: .random,
                                     title: groupTitle(with: groups.count + 1),
                                     objectsCount: defaultObjectsCount)
            groups.insert(newGroup, at: index + 1)
        }
    }

    private func insertObject(in group: Group, after object: Object?) {
        guard let group = self.group(forId: group.id) else {
            return
        }
        var index = 0
        if let object = object,
            let idx = group.objects.firstIndex(of: object) {
            index = idx
        }
        let newObject = makeObject(color: group.color, title: "\(group.objects.count + 1)")
        group.objects.insert(newObject, at: index + 1)
    }

    private func addObject(in group: Group) {
        guard let group = self.group(forId: group.id) else {
            return
        }
        insertObject(in: group, after: group.objects.last)
    }

    private func cacheGroups() {
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

    private func groupTitle(with index: Int) -> String {
        return "Section \(index)"
    }

    // MARK: - Main Collection

    private func updateMainCollection(animated: Bool, cache: Bool = true) {
        let sectionItems = makeMainSectionItems(groups: groups)
        mainCollectionViewManager.update(with: sectionItems,
                                         diffAdaptor: mainCollectionViewDiff.value,
                                         ignoreCellItemsChanges: false,
                                         animated: animated,
                                         completion: { [weak self] _ in
                                            if cache {
                                                self?.cacheGroups()
                                            }

        })
    }

    func makeMainSectionItems(groups: [Group]) -> [CollectionViewDiffSectionItem] {
        return groups.reduce([]) { (result, group) in
            result + [makeGroupSectionItem(group: group),
                      makeGroupActionsSectionItem(group: group),
                      makePlusSectionItem(after: group)]
        }
    }

    func makeGroupSectionItem(group: Group) -> CollectionViewDiffSectionItem {
        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.reusableViewItems = [makeGroupHeaderItem(group: group)]
        sectionItem.diffIdentifier = "\(group.id)"
        sectionItem.insets = .init(top: 2, left: 8, bottom: 0, right: 8)
        sectionItem.minimumInteritemSpacing = 2
        sectionItem.minimumLineSpacing = 2
        if !group.isFolded {
            for object in group.objects {
                let cellItem = makeObjectCellItem(object: object, group: group)
                sectionItem.cellItems.append(cellItem)
            }
        }
        return sectionItem
    }

    func makeGroupActionsSectionItem(group: Group) -> CollectionViewDiffSectionItem {
        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.diffIdentifier = "actions_\(group.id)"
        sectionItem.insets = .init(top: 8, left: 8, bottom: 0, right: 8)
        sectionItem.minimumInteritemSpacing = 2
        sectionItem.minimumLineSpacing = 2
        sectionItem.cellItems = [
            makeMainActionCellItem(title: "Add cell") { [weak self] in
                self?.addObject(in: group)
                self?.updateMainCollection(animated: true, cache: false)
            },
            makeMainActionCellItem(title: "Shuffle cells") { [weak self] in
                self?.shuffleGroupObjects(for: [group], withUpdates: false)
                self?.updateMainCollection(animated: true, cache: false)
            }
        ]
        return sectionItem
    }

    func makePlusSectionItem(after group: Group) -> CollectionViewDiffSectionItem {
        let sectionItem = GeneralCollectionViewDiffSectionItem()
        sectionItem.diffIdentifier = "plus_\(group.id)"
        sectionItem.cellItems.append(makeGroupPlusCellItem(group: group))
        return sectionItem
    }

    private func makeGroupHeaderItem(group: Group) -> HeaderViewItem {
        let headerItem = HeaderViewItem(title: group.title,
                                        backgroundColor: group.color.uiColor,
                                        isFolded: group.isFolded)
        headerItem.diffIdentifier = "group_header_\(group.id)"
        headerItem.foldHandler = { [weak self] in
            if let group = self?.group(forId: group.id) {
                group.isFolded.toggle()
                self?.updateMainCollection(animated: true, cache: false)
            }
        }
        headerItem.removeHandler = { [weak self] in
            self?.delete(group)
            self?.updateMainCollection(animated: true, cache: false)
        }
        return headerItem
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
            self?.updateMainCollection(animated: true, cache: false)
        }
        return cellItem
    }

    private func makeObjectCellItem(object: Object, group: Group) -> ColorCellItem {
        let cellItem = ColorCellItem(color: object.color.uiColor, title: "\(object.title)")
        cellItem.diffIdentifier = "object_item_\(object.id)"
        cellItem.itemDidSelectHandler = { [weak self] _ in
            self?.delete(object, from: group)
            self?.updateMainCollection(animated: true, cache: false)
        }
        return cellItem
    }

    func makeMainActionCellItem(title: String, action: @escaping (() -> Void)) -> TextCellItem {
        let cellItem = TextCellItem(text: title, backgroundColor: UIColor.black.withAlphaComponent(0.2), roundCorners: true)
        cellItem.diffIdentifier = "action_\(title)"
        cellItem.itemDidSelectHandler = { _ in
            action()
        }
        return cellItem
    }

    // MARK: - Actions collection

    func makeActionsSectionItem() -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = [
            makeResetActionCellItem(),
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
            makeShuffleSectionCellsWithUpdatesActionCellItem(),
            // Cache
            makeCacheActionCellItem()
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

    // MARK: - Diff Selection

    @objc private func presentDiffSelectionPopup() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        mainCollectionViewDiffs.forEach { diff in
            let action = UIAlertAction(title: diff.name, style: .default) { [weak self] _ in
                self?.mainCollectionViewDiff = diff
                self?.updateRightBarButtonItem()
            }
            let isSelected = mainCollectionViewDiff.name == diff.name
            action.setValue(NSNumber(value: isSelected), forKey: "checked")
            alertController.addAction(action)
        }
        alertController.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        present(alertController, animated: true)
    }
}
