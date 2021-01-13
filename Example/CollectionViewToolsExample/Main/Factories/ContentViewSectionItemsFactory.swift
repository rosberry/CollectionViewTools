//
//  ContentViewCellItemFactory.swift
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
    private(set) lazy var imageCellItemFactory: ViewCellItemsFactory<ImageViewState, ImageContentView> = {
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
       return factory
    }()

    // MARK: - TextContent
    private(set) lazy var textCellItemFactory: ViewCellItemsFactory<TextViewState, TextContentView> = {
        let factory: ViewCellItemsFactory<TextViewState, TextContentView> = makeFactory(id: "text")
        let viewConfigurationHandler = factory.viewConfigurationHandler
        factory.viewConfigurationHandler = { view, cellItem in
           view.titleLabel.text = cellItem.object.textContent.text
           viewConfigurationHandler?(view, cellItem)
           return
        }
        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .contentRelated)
        }
        return factory
    }()

    // MARK: - Divider

    private(set) lazy var dividerCellItemFactory: ViewCellItemsFactory<DividerState, DividerView> = {
        let factory: ViewCellItemsFactory<DividerState, DividerView> = .init()
        factory.viewConfigurationHandler = { view, _ in
            view.dividerHeight = 1
            view.dividerView.backgroundColor = .lightGray
            view.dividerInsets = .init(top: 9, left: 0, bottom: 0, right: 0)
        }
        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .fixed(20))
        }
        return factory
    }()

    // MARK: - Content
    private(set) lazy var cellItemFactory: ComplexCellItemsFactory = {
        imageCellItemFactory.factory(byJoining: textCellItemFactory).factory(byJoining: dividerCellItemFactory)
    }()

    // MARK: - Description
    private(set) lazy var descriptionCellItemFactory: ViewCellItemsFactory<ContentViewState, TextContentView> = {
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
        factory.sizeTypesConfigurationHandler = { _ in
            .init(width: .fill, height: .contentRelated)
        }

        return factory
    }()

    func makeContentViewSate(_ content: Content?) -> ContentViewState? {
       guard let content = content else {
           return nil
       }
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
            let separatorCellItem = self.dividerCellItemFactory.makeCellItem(object: .init(id: data.content.id))
            guard data.isExpanded else {
                return [cellItem, separatorCellItem]
            }
            let descriptionCellItem = self.descriptionCellItemFactory.makeCellItem(object: data)
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
        let cellItems = cellItemFactory.makeCellItems(objects: contentViewStates)
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
