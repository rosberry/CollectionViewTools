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
    private(set) lazy var imageViewItemsFactory
        : ViewCellItemsFactory<ImageViewState, ImageContentView> = {
       let factory: ViewCellItemsFactory<ImageViewState, ImageContentView> = makeFactory(id: "image")
       let viewConfigurationHandler = factory.viewConfigurationHandler
       factory.viewConfigurationHandler = { view, cellItem in
           view.imageView.image = cellItem.object.imageContent.image
           view.removeActionHandler = { [weak self] in
               self?.removeEventTriggered(state: cellItem.object)
           }
           viewConfigurationHandler?(view, cellItem)
       }
        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .contentRelated)
        }

        factory.sizeConfigurationHandler = { state, collectionView, sectionItem in
            let width = collectionView.bounds.width
            let aspectRatio = state.imageContent.image.size.width / state.imageContent.image.size.height
            return CGSize(width: width, height: width / aspectRatio)
        }
        return factory
    }()

    // MARK: - TextContent
    private(set) lazy var textViewItemsFactory: ViewCellItemsFactory<TextViewState, TextContentView> = {
        let factory: ViewCellItemsFactory<TextViewState, TextContentView> = makeFactory(id: "text")
        let viewConfigurationHandler = factory.viewConfigurationHandler
        factory.viewConfigurationHandler = { view, cellItem in
           view.titleLabel.text = cellItem.object.textContent.text
           viewConfigurationHandler?(view, cellItem)
           return
        }

        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 60)
        }
        return factory
    }()

    // MARK: - Divider

    private(set) lazy var dividerViewItemsFactory: ViewCellItemsFactory<DividerState, DividerView> = {
        let factory: ViewCellItemsFactory<DividerState, DividerView> = .init()
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

    // MARK: - Content

    private(set) lazy var cellItemsFactory: ComplexCellItemsFactory =
        imageViewItemsFactory.factory(byJoining: textViewItemsFactory)
                             .factory(byJoining: dividerViewItemsFactory)

    // MARK: - Description

    private(set) lazy var descriptionViewItemsFactory: ViewCellItemsFactory<ContentViewState, TextContentView> = {
        let factory = ViewCellItemsFactory<ContentViewState, TextContentView>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] _ in
                cellItem.object.isExpanded.toggle()
                self?.updateEventTriggered()
            }
        }
        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.content.description
            view.layer.borderWidth = 0
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.content.description
        }

        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 60)
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
    private func makeFactory<Object: ContentViewState, View: UIView>(id: String) -> ViewCellItemsFactory<Object, View> {
        let factory = ViewCellItemsFactory<Object, View>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] _ in
                cellItem.object.isExpanded.toggle()
                self?.updateEventTriggered()
            }
        }

        factory.initializationHandler = { data in
            let cellItem = factory.makeCellItem(object: data)
            let separatorCellItem = self.dividerViewItemsFactory.makeCellItem(object: .init(id: data.content.id))
            guard data.isExpanded else {
                return [cellItem, separatorCellItem]
            }
            let descriptionCellItem = self.descriptionViewItemsFactory.makeCellItem(object: data)
            return [cellItem, descriptionCellItem, separatorCellItem]
        }

        factory.viewConfigurationHandler = { view, cellItem in
            if cellItem.object.isExpanded {
                view.layer.borderWidth = 2
                view.layer.borderColor = UIColor.green.cgColor
            }
            else {
                view.layer.borderWidth = 0
                view.layer.borderColor = UIColor.clear.cgColor
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
