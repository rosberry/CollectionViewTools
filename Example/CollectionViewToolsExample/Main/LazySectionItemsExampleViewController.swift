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

    private(set) lazy var sectionItemsProvider: LazySectionItemsProvider = .init(
        factory: factory.cellItemsFactory,
        cellItemsNumberHandler: { [weak self] _ in
            (self?.contentProvider.contents.count ?? 0) * 2
        },
        sizeHandler: { [weak self] indexPath, collectionView in
            guard let self = self else {
                return .zero
            }
            guard indexPath.row % 2 == 0 else {
                return .init(width: collectionView.bounds.width, height: 20)
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
            guard let self = self,
                  indexPath.row < self.contentProvider.contents.count * 2 else {
                return nil
            }
            let content = self.contentProvider.contents[indexPath.row / 2]
            guard indexPath.row % 2 == 0 else {
                return SpacerState(content: content)
            }
            if let imageContent = content as? ImageContent {
                return ImageViewState(content: imageContent)
            }
            if let textContent = content as? TextContent {
                return TextViewState(content: textContent)
            }
            return nil
        }
    )

    // MARK: - Subviews

    private lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Feeds"
        view.addSubview(mainCollectionView)
        mainCollectionViewManager.mode = .lazy(provider: sectionItemsProvider)
        view.backgroundColor = .white
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

    func removeContentView(for viewState: ImageViewState) {
        let removingIndex = contentProvider.contents.firstIndex { content in
            content.id == viewState.id
        }
        guard let index = removingIndex,
              let cellItem = sectionItemsProvider[.init(row: index * 2, section: 0)] else {
            return
        }
        var cellItems = [cellItem]
        if let spacerCellItem = sectionItemsProvider[.init(row: index * 2 + 1, section: 0)] {
            cellItems.append(spacerCellItem)
        }
        contentProvider.contents.remove(at: index)
        mainCollectionViewManager.remove(cellItems)
    }

    func updateContentView(for viewState: ViewState & Expandable) {
        resetMainCollection()
    }
}
