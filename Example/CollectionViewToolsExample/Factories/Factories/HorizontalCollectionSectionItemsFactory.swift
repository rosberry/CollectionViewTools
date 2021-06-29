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

    private lazy var packCellItemFactory: ViewCellItemsFactory<Pack, SimpleImageContentView> = {
        let factory = ViewCellItemsFactory<Pack, SimpleImageContentView>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] indexPath in
                self?.output?.toggle(pack: cellItem.object)
            }
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.imageView.image = cellItem.object.thumbnail
            view.imageView.contentMode = .scaleAspectFill
            view.layer.borderColor = UIColor.green.cgColor
            view.layer.borderWidth = cellItem.object.isExpanded ? 1 : 0
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
        }

        factory.sizeTypesConfigurationHandler = { cellItem in
            .init(width: .fixed(140), height: .fixed(140))
        }

        return factory
    }()

    private lazy var templatesCellItemFactory: ViewCellItemsFactory<Template, FavoritableTextContentView> = {
        let factory = ViewCellItemsFactory<Template, FavoritableTextContentView>()

        factory.cellItemConfigurationHandler = { cellItem in
            cellItem.itemDidSelectHandler = { [weak self] indexPath in
                self?.output?.toggleFavorite(template: cellItem.object)
            }
        }

        factory.viewConfigurationHandler = { view, cellItem in
            view.titleLabel.text = cellItem.object.text
            view.titleLabel.textColor = .black
            if cellItem.object.isFavorite {
                view.layer.borderColor = UIColor.red.cgColor
                view.favoriteImageView.image = #imageLiteral(resourceName: "favorite")
            }
            else {
                view.layer.borderColor = UIColor.lightGray.cgColor
                view.favoriteImageView.image = nil
            }
            view.layer.borderWidth = 1
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
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
            sectionItem.minimumInteritemSpacing = 2
            return sectionItem
        }
    }
}
