//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

final class FactoryExampleViewController: UIViewController {

    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    private lazy var factory: ContentViewSectionItemsFactory = {
        let factory = ContentViewSectionItemsFactory()
        factory.output = self
        return factory
    }()
    private lazy var contentProvider: ContentProvider = .init()
    private lazy var viewStates: [ViewState] = makeViewStates()

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
        let sectionItems = factory.makeSectionItems(viewStates: viewStates)
        if mainCollectionViewManager.sectionItems.isEmpty {
            mainCollectionViewManager.sectionItems = sectionItems
        }
        else {
            mainCollectionViewManager.update(with: sectionItems, animated: true)
        }
    }

    private func makeViewStates() -> [ViewState] {
        contentProvider.contents.flatMap { content -> [ViewState] in
            let contentState: ViewState
            if let imageContent = content as? ImageContent {
                contentState = ImageViewState(content: imageContent)
            }
            else if let textContent = content as? TextContent {
                contentState = TextViewState(content: textContent)
            }
            else {
                return []
            }
            let spacerState = SpacerState(content: content)
            return  [contentState, spacerState]
        }
    }
}

extension FactoryExampleViewController: ContentViewCellItemFactoryOutput {
    func updateContentView(for viewState: ViewState & Expandable) {
        let stateIndex = viewStates.firstIndex { state in
            state is Expandable && state.id == viewState.id
        }
        guard let index = stateIndex else {
            return
        }
        if viewState.isExpanded {
            viewStates.insert(DescriptionViewState(id: viewState.id, text: viewState.description), at: index + 1)
        }
        else {
            viewStates.remove(at: index + 1)
        }
        resetMainCollection()
    }

    func removeContentView(for viewState: ImageViewState) {
        viewStates.removeAll { state in
            state.id == viewState.id
        }
        resetMainCollection()
    }
}
