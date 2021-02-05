//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

protocol ContentViewCellItemFactoryOutput {
    func reloadCollectionView()
    func removeContentViewState(_ state: ContentViewState)
}

final class ContentViewSectionItemsFactory {

    typealias State = ContentViewState
    var output: ContentViewCellItemFactoryOutput?

    // MARK: - Factories

    // MARK: - ImageContent

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

        factory.cellItemConfigurationHandler = { cellItem in
           cellItem.itemDidSelectHandler = { [weak self] _ in
               cellItem.object.isExpanded.toggle()
               self?.updateEventTriggered()
           }
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
    }

    // MARK: - Factory methods

    func makeSectionItems(contentViewStates: [ContentViewState]) -> [CollectionViewDiffSectionItem] {
        let cellItems = cellItemsFactory.makeCellItems(objects: contentViewStates)
        let sectionItem = GeneralCollectionViewDiffSectionItem(cellItems: cellItems)
        sectionItem.diffIdentifier = "Contents"
        return [sectionItem]
    }

    func removeEventTriggered(state: ContentViewState) {
        output?.removeContentViewState(state)
    }

    func updateEventTriggered() {
        output?.reloadCollectionView()
    }
}
