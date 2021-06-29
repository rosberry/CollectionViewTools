//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

class MainViewController: UIViewController {

    var initialImages: [UIImage] {
        return [#imageLiteral(resourceName: "nightlife-1"), #imageLiteral(resourceName: "nightlife-2"), #imageLiteral(resourceName: "nightlife-3"), #imageLiteral(resourceName: "nightlife-4"), #imageLiteral(resourceName: "nightlife-5")]
    }
    var images: [UIImage] {
        var images: [UIImage] = []
        // You can change number of cell items in section
        // for tests easily by increasing upper bound of range.
        for _ in 0..<1 {
            images.append(contentsOf: shuffledImages)
        }
        return images
    }

    var shuffledImages: [UIImage] {
        return initialImages.shuffled()
    }

    lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    lazy var actionsCollectionViewManager: CollectionViewManager = .init(collectionView: actionsCollectionView)

    // MARK: - Subviews

    private lazy var actionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        return view
    }()
    private lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        return collectionView
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
        edgesForExtendedLayout = []

        view.addSubview(mainCollectionView)
        view.addSubview(actionsCollectionBackgroundView)
        view.addSubview(actionsCollectionView)

        resetMainCollection()
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

    // MARK: - Private

    private func resetMainCollection() {
        mainCollectionViewManager.update([makeImagesSectionItem(images: images)], shouldReloadData: true) {
            print("Reload complete")
        }
        mainCollectionView.contentOffset = .zero
    }

    private func remove(_ cellItem: CollectionViewCellItem?) {
        if let cellItem = cellItem {
            mainCollectionViewManager.remove([cellItem])
        }
    }

    // MARK: - Factory methods

    func makeImagesSectionItem(images: [UIImage]) -> CollectionViewSectionItem {
        let sectionItem = ExampleSectionItem()
        sectionItem.cellItems = images.map { image in
            makeImageCellItem(image: image)
        }
        sectionItem.insets = .init(top: 0, left: 12, bottom: 12, right: 12)
        sectionItem.minimumLineSpacing = 8
        return sectionItem
    }

    private func makeImageCellItem(image: UIImage) -> ImageCellItem {
        let cellItem = ImageCellItem(image: image) { [weak self] image in
            let detailViewController = DetailViewController()
            detailViewController.image = image
            self?.navigationController?.pushViewController(detailViewController, animated: true)
        }
        cellItem.removeActionHandler = { [weak self, weak cellItem] in
            self?.remove(cellItem)
        }
        return cellItem
    }

    // MARK: - Actions cell items

    func makeActionsSectionItem() -> CollectionViewSectionItem {
        let sectionItem = makeActionsSectionItem(cellItems: [
            makeResetActionCellItem(),
            // Insert cells
            makePrependCellItemsActionCellItem(),
            makeAppendCellItemsActionCellItem(),
            makeInsertCellItemsInTheMiddleActionCellItem(),
            // Insert sections
            makePrependSectionItemActionCellItem(),
            makeAppendSectionItemActionCellItem(),
            makeInsertSectionItemInTheMiddleActionCellItem(),
            // Remove cells
            makeRemoveRandomCellActionCellItem(),
            // Remove sections
            makeRemoveRandomSectionActionCellItem(),
            // Replace cells
            makeReplaceCellItemsActionCellItem(),
            // Replace sections
            makeReplaceSectionItemsActionCellItem(),
            // Change images
            makeChangeImagesActionCellItem()
        ])
        sectionItem.insets = .init(top: 0, left: 8, bottom: 0, right: 8)
        sectionItem.minimumInteritemSpacing = 8
        sectionItem.minimumLineSpacing = 8
        return sectionItem
    }

    func makeResetActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Reset") { [weak self] in
            self?.resetMainCollection()
        }
    }

    // MARK: - Insert cells

    func makePrependCellItemsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Prepend cells") { [weak self] in
            guard let self = self else {
                return
            }
            guard let sectionItem = self.mainCollectionViewManager.sectionItems.first else {
                return
            }
            let cellItems = self.shuffledImages.map { image in
                return self.makeImageCellItem(image: image)
            }
            self.mainCollectionView.scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
            self.mainCollectionViewManager.prepend(cellItems, to: sectionItem) { [weak self] _ in
                self?.mainCollectionView.scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

    func makeAppendCellItemsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Append cells") { [weak self] in
            guard let self = self else {
                return
            }
            guard let sectionItem = self.mainCollectionViewManager.sectionItems.first else {
                return
            }
            let cellItems = self.shuffledImages.map { image in
                return self.makeImageCellItem(image: image)
            }
            self.mainCollectionView.scrollToItem(at: .init(row: sectionItem.cellItems.count - 1, section: 0), at: .bottom, animated: true)
            self.mainCollectionViewManager.append(cellItems, to: sectionItem) { [weak self] _ in
                let indexPath = IndexPath(row: sectionItem.cellItems.count - 1, section: 0)
                self?.mainCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
    }

    func makeInsertCellItemsInTheMiddleActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Insert cells in the middle") { [weak self] in
            guard let self = self else {
                return
            }
            guard let sectionItem = self.mainCollectionViewManager.sectionItems.first else {
                return
            }
            let cellItems = self.shuffledImages.map { image in
                return self.makeImageCellItem(image: image)
            }
            let initialIndex = sectionItem.cellItems.count / 2 - 1
            let indexPath = IndexPath(row: initialIndex, section: 0)
            self.mainCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
            self.mainCollectionViewManager.insert(cellItems, to: sectionItem, at: Array(initialIndex..<initialIndex + cellItems.count))
        }
    }

    // MARK: - Insert sections

    func makeAppendSectionItemActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Append section") { [weak self] in
            guard let self = self else {
                return
            }

            let sectionItems = self.mainCollectionViewManager.sectionItems
            if let sectionItem = sectionItems.last {
                let indexPath = IndexPath(row: sectionItem.cellItems.count - 1, section: sectionItems.count - 1)
                self.mainCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }

            var additionalSectionItems: [CollectionViewSectionItem] = []
            for _ in 0..<1 {
                additionalSectionItems.append(self.makeImagesSectionItem(images: self.shuffledImages))
            }
            self.mainCollectionViewManager.append(additionalSectionItems) { [weak self] _ in
                let indexPath = IndexPath(row: 0, section: sectionItems.count + additionalSectionItems.count - 1)
                self?.mainCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
    }

    func makePrependSectionItemActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Prepend section") { [weak self] in
            guard let self = self else {
                return
            }

            let sectionsCount = self.mainCollectionViewManager.sectionItems.count
            if sectionsCount > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                self.mainCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }

            var additionalSectionItems: [CollectionViewSectionItem] = []
            for _ in 0..<1 {
                additionalSectionItems.append(self.makeImagesSectionItem(images: self.shuffledImages))
            }
            self.mainCollectionViewManager.prepend(additionalSectionItems) { [weak self] _ in
                let indexPath = IndexPath(row: 0, section: 0)
                self?.mainCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
    }

    func makeInsertSectionItemInTheMiddleActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Insert section in the middle") { [weak self] in
            guard let self = self else {
                return
            }

            let sectionsCount = self.mainCollectionViewManager.sectionItems.count
            let section: Int = sectionsCount / 2
            if sectionsCount > 0 {
                let indexPath = IndexPath(row: 0, section: section)
                self.mainCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }

            var additionalSectionItems: [CollectionViewSectionItem] = []
            for _ in 0..<1 {
                additionalSectionItems.append(self.makeImagesSectionItem(images: self.shuffledImages))
            }
            let indexes = Array(section..<section + additionalSectionItems.count)
            self.mainCollectionViewManager.insert(additionalSectionItems, at: indexes)
        }
    }

    // MARK: - Remove cells

    func makeRemoveRandomCellActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Remove random cell") { [weak self] in
            guard let self = self else {
                return
            }

            let sectionItems = self.mainCollectionViewManager.sectionItems
            let nonEmptySectionsIndexes: [Int] = sectionItems.enumerated().compactMap { tuple in
                if tuple.element.cellItems.count > 0 {
                    return tuple.offset
                }
                return nil
            }

            let sectionsCount = nonEmptySectionsIndexes.count
            guard sectionsCount > 0 else {
                return
            }

            let sectionIndex = nonEmptySectionsIndexes[Int.random(in: 0..<sectionsCount)]
            let sectionItem = self.mainCollectionViewManager.sectionItems[sectionIndex]

            guard sectionItem.cellItems.count > 0 else {
                return
            }

            let cellIndex = Int.random(in: 0..<sectionItem.cellItems.count)
            self.mainCollectionView.scrollToItem(at: .init(row: cellIndex, section: sectionIndex), at: .centeredVertically, animated: true)
            // Perform remove after scroll animation stops
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.mainCollectionViewManager.removeCellItems(at: [cellIndex], from: sectionItem)
            }
        }
    }

    // MARK: - Remove sections

    func makeRemoveRandomSectionActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Remove random section") { [weak self] in
            guard let self = self else {
                return
            }

            let sectionItems = self.mainCollectionViewManager.sectionItems
            let nonEmptySectionsIndexes: [Int] = sectionItems.enumerated().compactMap { tuple in
                if tuple.element.cellItems.count > 0 {
                    return tuple.offset
                }
                return nil
            }

            let sectionsCount = nonEmptySectionsIndexes.count
            guard sectionsCount > 0 else {
                return
            }

            let sectionIndex = nonEmptySectionsIndexes[Int.random(in: 0..<sectionsCount)]

            self.mainCollectionView.scrollToItem(at: .init(row: 0, section: sectionIndex), at: .centeredVertically, animated: true)
            // Perform remove after scroll animation stops
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.mainCollectionViewManager.remove(sectionItemsAt: [sectionIndex])
            }
        }
    }

    // MARK: - Replace cells

    func makeReplaceCellItemsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Replace cells") { [weak self] in
            guard let self = self else {
                return
            }
            guard let sectionItem = self.mainCollectionViewManager.sectionItems.first else {
                return
            }
            var images = self.shuffledImages
            images.append(contentsOf: self.shuffledImages)
            let cellItems = images.map { image in
                return self.makeImageCellItem(image: image)
            }
            self.mainCollectionView.scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)

            let replaceIndexes = Array(0..<sectionItem.cellItems.count)
            self.mainCollectionViewManager.replace(cellItemsAt: replaceIndexes, with: cellItems, in: sectionItem) { [weak self] _ in
                self?.mainCollectionView.scrollToItem(at: .init(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }

    // MARK: - Replace sections

    func makeReplaceSectionItemsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Replace sections") { [weak self] in
            guard let self = self else {
                return
            }

            var sectionItems: [CollectionViewSectionItem] = []
            for _ in 0..<2 {
                sectionItems.append(self.makeImagesSectionItem(images: self.shuffledImages))
            }

            let replaceIndexes = Array(0..<self.mainCollectionViewManager.sectionItems.count)
            self.mainCollectionViewManager.replace(sectionItemsAt: replaceIndexes, with: sectionItems)
        }
    }

    // MARK: - Change images

    func makeChangeImagesActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Change images") { [weak self] in
            guard let self = self, self.images.isEmpty == false else {
                return
            }

            self.mainCollectionViewManager.sectionItems.forEach { sectionItem in
                sectionItem.cellItems.forEach { cellItem in
                    guard let cell = cellItem.cell as? ImageCollectionViewCell else {
                        return
                    }
                    cell.imageContentView.imageView.image = self.images[Int.random(in: 0..<self.images.count)]
                }
            }
        }
    }

    // MARK: - Common

    func makeActionCellItem(title: String, action: @escaping (() -> Void)) -> CollectionViewCellItem {
        let cellItem = TextCellItem(text: title, backgroundColor: .white, roundCorners: true)
        cellItem.itemDidSelectHandler = { _ in
            action()
        }
        return cellItem
    }
}

extension UIViewController {
    func makeActionsSectionItem(cellItems: [CollectionViewCellItem]) -> CollectionViewSectionItem {
        let sectionItem = ExampleSectionItem()
        sectionItem.cellItems = cellItems
        sectionItem.insets = .init(top: 0, left: 8, bottom: 0, right: 8)
        sectionItem.minimumInteritemSpacing = 8
        sectionItem.minimumLineSpacing = 8
        return sectionItem
    }
}
