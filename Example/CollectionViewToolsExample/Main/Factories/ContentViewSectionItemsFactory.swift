//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

protocol ContentViewCellItemFactoryOutput {
    func updateContentView(for viewState: ViewState & Expandable)
    func removeContentView(for viewState: ImageViewState)
}

final class ContentViewSectionItemsFactory {

    var output: ContentViewCellItemFactoryOutput?

    // MARK: - Factories

    // MARK: - Content

    private(set) lazy var cellItemsFactory: ComplexCellItemsFactory =
        imageViewItemsFactory.factory(byJoining: textViewItemsFactory)
                             .factory(byJoining: dividerViewItemsFactory)
                             .factory(byJoining: descriptionViewItemsFactory)

    // MARK: - ImageContent
    private(set) lazy var imageViewItemsFactory
        : ViewCellItemsFactory<ImageViewState, ImageContentView> = {
        let factory = ViewCellItemsFactory<ImageViewState, ImageContentView>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] indexPath in
                cellItem.object.isExpanded = !cellItem.object.isExpanded
                self?.output?.updateContentView(for: cellItem.object)
            }
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.imageView.image = cellItem.object.image

            if cellItem.object.isExpanded {
                view.layer.borderWidth = 2
                view.layer.borderColor = UIColor.green.cgColor
            }
            else {
                view.layer.borderWidth = 0
                view.layer.borderColor = UIColor.clear.cgColor
            }

            view.removeActionHandler = { [weak self] in
               self?.output?.removeContentView(for: cellItem.object)
            }
        }

        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .contentRelated)
        }

        factory.sizeConfigurationHandler = { state, collectionView, sectionItem in
            let width = collectionView.bounds.width
            let aspectRatio = state.image.size.width / state.image.size.height
            return CGSize(width: width, height: width / aspectRatio)
        }

        return factory
    }()

    // MARK: - TextContent
    private(set) lazy var textViewItemsFactory: ViewCellItemsFactory<TextViewState, TextContentView> = {
        let factory = ViewCellItemsFactory<TextViewState, TextContentView>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] indexPath in
                cellItem.object.isExpanded = !cellItem.object.isExpanded
                self?.output?.updateContentView(for: cellItem.object)
            }
        }

        factory.viewConfigurationHandler = { view, cellItem in
           view.titleLabel.text = cellItem.object.text
           if cellItem.object.isExpanded {
               view.layer.borderWidth = 2
               view.layer.borderColor = UIColor.green.cgColor
           }
           else {
               view.layer.borderWidth = 0
               view.layer.borderColor = UIColor.clear.cgColor
           }
        }

        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 60)
        }
        return factory
    }()

    // MARK: - Description

    private(set) lazy var descriptionViewItemsFactory: ViewCellItemsFactory<DescriptionViewState, TextContentView> = {
        let factory = ViewCellItemsFactory<DescriptionViewState, TextContentView>()

        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.text
            view.layer.borderWidth = 0
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.text
            view.layer.borderWidth = 0
        }

        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 60)
        }
        return factory
    }()

    // MARK: - Divider

    private(set) lazy var dividerViewItemsFactory: ViewCellItemsFactory<DividerViewState, DividerView> = {
        let factory: ViewCellItemsFactory<DividerViewState, DividerView> = .init()
        factory.viewConfigurationHandler = { view, _ in
            view.dividerHeight = 1
            view.dividerView.backgroundColor = .lightGray
            view.dividerInsets = .init(top: 9, left: 0, bottom: 0, right: 0)
        }

        factory.sizeConfigurationHandler = {_, collectionView, sectionItem in
            .init(width: collectionView.bounds.inset(by: sectionItem.insets).width, height: 20)
        }
        return factory
    }()

    // MARK: - Factory Methods

    func makeSectionItems(viewStates: [ViewState]) -> [CollectionViewDiffSectionItem] {
        [GeneralCollectionViewDiffSectionItem(cellItems: cellItemsFactory.makeCellItems(objects: viewStates))]
    }
}
