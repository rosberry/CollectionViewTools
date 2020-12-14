//
//  ContentViewCellItemFactory.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

protocol ContentViewCellItemFactoryOutput {
    func reloadCollectionView()
    var contents: [Content] { get }
}

final class ContentViewSectionItemsFactory {

    var output: ContentViewCellItemFactoryOutput?

    typealias State = ContentViewState

    private lazy var contentViewStates: [ContentViewState] = output?.contents.compactMap { content in
        if let imageContent = content as? ImageContent {
            return ImageViewState(imageContent: imageContent)
        }
        if let textContent = content as? TextContent {
            return TextViewState(textContent: textContent)
        }
        return nil
    } ?? []

    // MARK: - Factories

    // MARK: - ImageContent
    private lazy var imageCellItemFactory: CellItemFactory = {
        let factory: AssociatedCellItemFactory<ImageViewState, ImageCollectionViewCell> = makeFactory(id: "image")
        let cellConfigurationHandler = factory.cellConfigurationHandler
        factory.cellConfigurationHandler = { cell, cellItem in
            cell.imageView.image = cellItem.object.imageContent.image
            cell.removeActionHandler = {
                self.contentViewStates.removeAll { state in
                    state.content.id == cellItem.object.content.id
                }
                self.output?.reloadCollectionView()
            }
            cellConfigurationHandler?(cell, cellItem)
        }
        factory.sizeConfigurationHandler = { state, collectionView, sectionItem in
            let width = collectionView.bounds.width
            let aspectRatio = state.imageContent.image.size.width / state.imageContent.image.size.height
            return CGSize(width: width, height: width / aspectRatio)
        }
        return factory
    }()

    // MARK: - TextContent
    private lazy var textCellItemFactory: CellItemFactory = {
        let factory: AssociatedCellItemFactory<TextViewState, TextCollectionViewCell> = makeFactory(id: "text")
        let cellConfigurationHandler = factory.cellConfigurationHandler
        factory.cellConfigurationHandler = { cell, cellItem in
            cell.titleLabel.text = cellItem.object.textContent.text
            cellConfigurationHandler?(cell, cellItem)
            return
        }
        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 60)
        }
        return factory
    }()

    // MARK: - Content
    private lazy var cellItemFactory: CellItemFactory = {
        imageCellItemFactory.factory(byJoining: textCellItemFactory)
    }()

    // MARK: - Description
    private lazy var descriptionCellItemFactory: CellItemFactory = {
        let factory = AssociatedCellItemFactory<ContentViewState, TextCollectionViewCell>()
        factory.cellItemConfigurationHandler = { index, cellItem in
            cellItem.itemDidSelectHandler = { _ in
                cellItem.object.isExpanded.toggle()
                self.output?.reloadCollectionView()
            }
        }
        factory.cellConfigurationHandler = { cell, cellItem in
            cell.titleLabel.text = cellItem.object.content.description
        }
        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 60)
        }
        return factory
    }()

    // MARK: - Factory methods

    func makeSectionItems() -> [CollectionViewDiffSectionItem] {
        let cellItems = cellItemFactory.makeCellItems(array: contentViewStates)
        let sectionItem = GeneralCollectionViewDiffSectionItem(cellItems: cellItems)
        sectionItem.diffIdentifier = "Contents"
        return [sectionItem]
    }

    // MARK: - Private
    private func makeFactory<U: ContentViewState, T: UICollectionViewCell>(id: String) -> AssociatedCellItemFactory<U, T> {
        let factory = AssociatedCellItemFactory<U, T>()

        factory.cellItemConfigurationHandler = { index, cellItem in
            cellItem.itemDidSelectHandler = { _ in
                cellItem.object.isExpanded.toggle()
                self.output?.reloadCollectionView()
            }
        }

        factory.initializationHandler = { index, data in
            let cellItem = factory.makeUniversalCellItem(object: data, index: index)
            let separatorCellItem = DividerCellItem()
            guard data.isExpanded else {
                return [cellItem, separatorCellItem]
            }
            let descriptionCellItem = self.descriptionCellItemFactory.makeCellItems(array: [data])[0]
            return [cellItem, descriptionCellItem, separatorCellItem]
        }

        factory.cellConfigurationHandler = { cell, cellItem in
            if cellItem.object.isExpanded {
                cell.layer.borderWidth = 2
                cell.layer.borderColor = UIColor.green.cgColor
            }
            else {
                cell.layer.borderWidth = 0
            }
        }
        return factory
    }
}
