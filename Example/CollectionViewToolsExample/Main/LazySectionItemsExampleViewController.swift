//
//  FactoryExampleViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

final class LazySectionItemsExampleViewController: UIViewController {

    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    private lazy var factory: ContentViewSectionItemsFactory = {
        let factory = ContentViewSectionItemsFactory()
        factory.output = self
        return factory
    }()
    private lazy var contentProvider: ContentProvider = .init()
    private(set) lazy var sectionItemsProvider: SectionItemsProvider = {
        LazyFactorySectionItemsProvider(
            factory: factory.cellItemFactory,
            cellItemsNumberHandler: { [weak self] _ in
                (self?.contentProvider.contents.count ?? 0) * 2
            },
            sizeHandler: { [weak self] indexPath, collectionView in
                guard let self = self else {
                    return .zero
                }
                guard indexPath.row % 2 == 0 else {
                    return .init(width: collectionView.bounds.width, height: 1)
                }
                let content = self.contentProvider.contents[indexPath.row / 2]
                if let image = (content as? ImageContent)?.image {
                    let width = collectionView.bounds.width
                    let aspectRatio = image.size.width / image.size.height
                    return .init(width: width, height: width / aspectRatio)
                }
                return .init(width: collectionView.bounds.width, height: 80)
            },
            objectHandler: { [weak self] indexPath in
                guard let self = self else {
                    return nil
                }
                guard indexPath.row % 2 == 0 else {
                    return DividerState()
                }
                let content = self.contentProvider.contents[indexPath.row / 2]
                return self.factory.makeContentViewState(content)
            }
        )
    }()

    // MARK: Subviews

    lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Feeds"
        view.addSubview(mainCollectionView)
        view.backgroundColor = .white
        mainCollectionViewManager.sectionItemsProvider = sectionItemsProvider
        resetMainCollection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mainCollectionView.frame = view.bounds
        mainCollectionView.contentInset.bottom = bottomLayoutGuide.length
    }

    // MARK: - Private

    private func resetMainCollection() {
        mainCollectionView.reloadData()
    }
}

extension LazySectionItemsExampleViewController: ContentViewCellItemFactoryOutput {
    func removeContentViewState(_ state: ContentViewState) {
        let removingIndex = contentProvider.contents.firstIndex { content in
            content.id == state.content.id
        }
        guard let index = removingIndex,
              let cellItem = sectionItemsProvider[.init(row: index * 2, section: 0)] else {
            return
        }
        var cellItems = [cellItem]
        if let dividerCellItem = sectionItemsProvider[.init(row: index * 2 + 1, section: 0)] {
            cellItems.append(dividerCellItem)
        }
        contentProvider.contents.remove(at: index)
        mainCollectionViewManager.remove(cellItems)
    }

    func reloadCollectionView() {
        resetMainCollection()
    }
}
