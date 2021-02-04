//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

final class FactoryExampleViewController: UIViewController {

    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    private lazy var sectionItemsFactory: ContentViewSectionItemsFactory = {
        let factory = ContentViewSectionItemsFactory()
        factory.output = self
        return factory
    }()
    private lazy var contentProvider: ContentProvider = .init()
    private lazy var contentViewStates: [ContentViewState] = {
        contentProvider.contents.compactMap(sectionItemsFactory.makeContentViewState)
    }()

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
        let sectionItems = sectionItemsFactory.makeSectionItems(contentViewStates: contentViewStates)
        if mainCollectionViewManager.sectionItems.isEmpty {
            mainCollectionViewManager.sectionItems = sectionItems
        }
        else {
            mainCollectionViewManager.update(with: sectionItems, animated: true)
        }
    }
}

extension FactoryExampleViewController: ContentViewCellItemFactoryOutput {
    func removeContentViewState(_ state: ContentViewState) {
        contentViewStates.removeAll { viewState in
            viewState.content.id == state.content.id
        }
        resetMainCollection()
    }

    func reloadCollectionView() {
        resetMainCollection()
    }
}
