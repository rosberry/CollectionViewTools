//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

protocol HorizontalCollectionSectionItemsFactoryOutput: class {
    func toggle(pack: Pack)
    func toggleFavorite(template: Template)
}

final class HorizontalCollectionSectionItemsFactory {

    weak var output: HorizontalCollectionSectionItemsFactoryOutput?

    private lazy var packCellItemFactory: ViewCellItemsFactory<Pack, ImageContentView> = {
        let factory = ViewCellItemsFactory<Pack, ImageContentView>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] indexPath in
                self?.output?.toggle(pack: cellItem.object)
            }
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.imageView.image = cellItem.object.thumbnail
            view.layer.borderColor = UIColor.green.cgColor
            view.layer.borderWidth = cellItem.object.isExpanded ? 1 : 0
        }

        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fixed(140), height: .fixed(140))
        }

        return factory
    }()

    private lazy var templatesCellItemFactory: ViewCellItemsFactory<Template, TextContentView> = {
        let factory = ViewCellItemsFactory<Template, TextContentView>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] indexPath in
                self?.output?.toggleFavorite(template: cellItem.object)
            }
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.text
            view.layer.borderColor = (cellItem.object.isFavorite ? UIColor.red : UIColor.lightGray).cgColor
            view.layer.borderWidth = 1
        }

        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fixed(130), height: .fixed(130))
        }

        return factory
    }()

    func makeSectionItems(packs: [Pack]) -> [CollectionViewDiffSectionItem] {
        packs.map { pack in
            let packCellItem = packCellItemFactory.makeCellItem(object: pack)
            var cellItems: [CollectionViewDiffCellItem] = [packCellItem]
            if pack.isExpanded {
                cellItems.append(contentsOf: templatesCellItemFactory.makeCellItems(objects: pack.templates))
            }
            let sectionItem = GeneralCollectionViewDiffSectionItem(cellItems: cellItems)
            sectionItem.diffIdentifier = pack.id
            sectionItem.insets = .init(top: 2, left: 2, bottom: 2, right: 2)
            return sectionItem
        }
    }
}
