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

    private(set) lazy var imageCellItemsFactory: ViewCellItemsFactory<ImageViewState, ImageContentView> = {
        let factory: ViewCellItemsFactory<ImageViewState, ImageContentView> = makeContentCellItemsFactory(id: "image")
        let viewConfigurationHandler = factory.viewConfigurationHandler

        factory.viewConfigurationHandler = { view, cellItem in
            view.imageView.image = cellItem.object.imageContent.image
            view.removeActionHandler = { [weak self] in
                self?.removeEventTriggered(state: cellItem.object)
            }
            viewConfigurationHandler?(view, cellItem)
        }

        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fill, height: .contentRelated)
        }

        return factory
    }()

    // MARK: - TextContent
    private(set) lazy var textViewItemsFactory: ViewCellItemsFactory<TextViewState, TextContentView> = {
        let factory = ViewCellItemsFactory<TextViewState, TextContentView>()

    private(set) lazy var textCellItemsFactory: ViewCellItemsFactory<TextViewState, TextContentView> = {
        let factory: ViewCellItemsFactory<TextViewState, TextContentView> = makeContentCellItemsFactory(id: "text")
        let viewConfigurationHandler = factory.viewConfigurationHandler

        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.textContent.text
            viewConfigurationHandler?(view, cellItem)
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
            view.backgroundColor = .gray
        }

        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .fixed(20))
        }

        return factory
    }()

    // MARK: - Content

    private(set) lazy var cellItemsFactory: CellItemFactory = imageCellItemsFactory.factory(byJoining: textCellItemsFactory)
                             .factory(byJoining: spacerCellItemsFactory)

    // MARK: - Description

    private(set) lazy var descriptionCellItemsFactory: ViewCellItemsFactory<ContentViewState, TextContentView> = {
        let factory = ViewCellItemsFactory<ContentViewState, TextContentView>()

        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.text
            view.layer.borderWidth = 0
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.content.description
        }

        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .contentRelated)
        }
        return factory
    }()

    func makeContentViewState(_ content: Content?) -> ContentViewState? {
        if let imageContent = content as? ImageContent {
            return ImageViewState(imageContent: imageContent)
        }
        if let textContent = content as? TextContent {
            return TextViewState(textContent: textContent)
        }
        return nil
    }

    // MARK: - Private

    private func makeContentCellItemsFactory<U: ContentViewState, T: UIView>(id: String) -> ViewCellItemsFactory<U, T> {
        let factory = ViewCellItemsFactory<U, T>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] _ in
                cellItem.object.isExpanded.toggle()
                self?.updateEventTriggered()
            }
        }

        factory.initializationHandler = { [weak self] data in
           let cellItem = factory.makeUniversalCellItem(object: data)
           let separatorCellItem = SpacerCellItem()
           guard data.isExpanded,
                 let descriptionCellItem = self?.descriptionCellItemsFactory.makeCellItem(object: data) else {
               return [cellItem, separatorCellItem]
           }
           return [cellItem, descriptionCellItem, separatorCellItem]
        }

        factory.viewConfigurationHandler = { view, cellItem in
            if cellItem.object.isExpanded {
                view.layer.borderWidth = 2
                view.layer.borderColor = UIColor.green.cgColor
            }
            else {
                view.layer.borderWidth = 0
            }
        }
        return factory
    }()

    // MARK: - Factory Methods

    func makeSectionItems(viewStates: [ViewState]) -> [CollectionViewDiffSectionItem] {
        [GeneralCollectionViewDiffSectionItem(cellItems: cellItemsFactory.makeCellItems(objects: viewStates))]
    }
}
