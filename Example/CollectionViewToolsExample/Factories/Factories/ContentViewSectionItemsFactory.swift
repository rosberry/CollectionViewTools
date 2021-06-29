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
                             .factory(byJoining: spacerCellItemsFactory)
                             .factory(byJoining: descriptionViewItemsFactory)

    // MARK: - ImageContent
    private(set) lazy var imageViewItemsFactory: ViewCellItemsFactory<ImageViewState, ImageContentView> = {
        let factory = ViewCellItemsFactory<ImageViewState, ImageContentView>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] indexPath in
                cellItem.object.isExpanded = !cellItem.object.isExpanded
                self?.output?.updateContentView(for: cellItem.object)
            }
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.imageView.image = cellItem.object.image
            view.layer.borderColor = UIColor.green.cgColor
            view.layer.borderWidth = cellItem.object.isExpanded ? 1 : 0
            view.removeActionHandler = { [weak self] in
                self?.output?.removeContentView(for: cellItem.object)
            }
        }

        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fill, height: .contentRelated)
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
            view.layer.borderColor = UIColor.green.cgColor
            view.layer.borderWidth = cellItem.object.isExpanded ? 1 : 0
        }

        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .contentRelated)
        }
        return factory
    }()

    // MARK: - Spacer

    private(set) lazy var spacerCellItemsFactory: ViewCellItemsFactory<SpacerState, SpacerView> = {
        let factory: ViewCellItemsFactory<SpacerState, SpacerView> = .init()

        factory.viewConfigurationHandler = { view, _ in
            view.dividerHeight = 1
            view.dividerView.backgroundColor = .gray
            view.dividerInsets = .init(top: 9, left: 0, bottom: 0, right: 0)
        }

        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .fixed(20))
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

        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .contentRelated)
        }

        return factory
    }()

    // MARK: - Factory Methods

    func makeSectionItems(viewStates: [ViewState]) -> [CollectionViewDiffSectionItem] {
        [GeneralCollectionViewDiffSectionItem(cellItems: cellItemsFactory.makeCellItems(objects: viewStates))]
    }
}
