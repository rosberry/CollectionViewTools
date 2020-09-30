//
//  FactoryExampleViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

protocol HasDescriptionProtocol: class {
    var description: String { get }
    var isExpanded: Bool { get set }
}

final class FactoryExampleViewController: UIViewController {
    
    final class ImageViewModel {
        let imageContent: ImageContent
        var isExpanded: Bool = false

        init(imageContent: ImageContent) {
            self.imageContent = imageContent
        }
    }
    
    class TextViewModel {
        let textContent: TextContent
        let description: String
        var isExpanded: Bool = false

        init(text: String, description: String) {
            self.text = text
            self.description = description
        }
    }
    
    var data: [HasDescriptionProtocol] = [ImageData(image: #imageLiteral(resourceName: "nightlife-1"), description: "First image description"),
                       ImageData(image: #imageLiteral(resourceName: "nightlife-2"), description: "Second image description"),
                       TextData(text: "Fist topic", description: "First topic description"),
                       ImageData(image: #imageLiteral(resourceName: "nightlife-3"), description: "Third image description"),
                       ImageData(image: #imageLiteral(resourceName: "nightlife-4"), description: "Foursh image description"),
                       TextData(text: "Second topic", description: "Second topic description"),
                       TextData(text: "Third topic", description: "Third topic description"),
                       TextData(text: "Foursh topic", description: "Foursh topic description"),
                       ImageData(image: #imageLiteral(resourceName: "nightlife-5"), description: "Fifth image description"),
                       TextData(text: "Fifth topic", description: "Fifth topic description")]


    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)

    private lazy var imageCellItemFactory: CellItemFactory = {
        let factory: AssociatedCellItemFactory<ImageData, ImageCollectionViewCell> = makeFactory(id: "image")
        let cellConfigurationHandler = factory.cellConfigurationHandler
        factory.cellConfigurationHandler = { data, cell, cellItem in
            cell.imageView.image = data.image
            cell.removeActionHandler = {
                self.data.removeAll { selectedData in
                    selectedData.description == data.description
                }
                self.resetMainCollection()
            }
            cellConfigurationHandler?(data, cell, cellItem)
        }
        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            let width = collectionView.bounds.width
            let aspectRatio = data.image.size.width / data.image.size.height
            return CGSize(width: width, height: width / aspectRatio)
        }
        return factory
    }()

    private lazy var textCellItemFactory: CellItemFactory = {
        let factory: AssociatedCellItemFactory<TextData, TextCollectionViewCell> = makeFactory(id: "text")
        let cellConfigurationHandler = factory.cellConfigurationHandler
        factory.cellConfigurationHandler = { data, cell, cellItem in
            cell.titleLabel.text = data.text
            cellConfigurationHandler?(data, cell, cellItem)
        }
        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 60)
        }
        return factory
    }()

    private lazy var descriptionCellItemFactory: CellItemFactory = {
        let factory = AssociatedCellItemFactory<HasDescriptionProtocol, TextCollectionViewCell>()
        factory.cellItemConfigurationHandler = { index, data, cellItem in
            cellItem.diffIdentifier = "description:\(data.description)"
            cellItem.itemDidSelectHandler = { _ in
                data.isExpanded.toggle()
                self.resetMainCollection()
            }
        }
        factory.cellConfigurationHandler = { data, cell, cellItem in
            cell.titleLabel.text = data.description
        }
        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 60)
        }
        return factory
    }()

    private lazy var separatorCellItemFactory: CellItemFactory = {
        let factory = AssociatedCellItemFactory<HasDescriptionProtocol, DividerCell>()
        factory.cellItemConfigurationHandler = { index, data, cellItem in
            cellItem.diffIdentifier = "separator:\(data.description)"
        }
        factory.cellConfigurationHandler = { _, cell, _ in
            cell.dividerView.backgroundColor = .lightGray
            cell.dividerInsets = .init(top: 9, left: 0, bottom: 0, right: 0)
        }
        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            CGSize(width: collectionView.bounds.width, height: 20)
        }
        return factory
    }()

    private lazy var cellItemFactory: CellItemFactory = {
        imageCellItemFactory.factory(byJoining: textCellItemFactory)
    }()
    
    // MARK: Subviews
    
    lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    // MARK: Lifecycle
    
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
        let sectionItems = [makeGeneralSectionItem()]
        if mainCollectionViewManager.sectionItems.isEmpty {
            mainCollectionViewManager.sectionItems = sectionItems
        }
        else {
            mainCollectionViewManager.update(with: sectionItems, animated: true)
        }
    }
    
    private func makeGeneralSectionItem() -> CollectionViewDiffSectionItem {
        let cellItems = cellItemFactory.makeCellItems(array: Array(0...1000))
        return GeneralCollectionViewDiffSectionItem(cellItems: cellItems)
    }

    private func makeFactory<U: HasDescriptionProtocol, T: UICollectionViewCell>(id: String) -> AssociatedCellItemFactory<U, T> {
        let factory = AssociatedCellItemFactory<U, T>()
        factory.cellItemConfigurationHandler = { index, data, cellItem in
            cellItem.context["isExpanded"] = data.isExpanded
            cellItem.itemDidSelectHandler = { _ in
                data.isExpanded.toggle()
                self.resetMainCollection()
            }
        }
        factory.initializationHandler = { index, data in
            let cellItem = factory.makeUniversalCellItem(object: data, index: index)
            cellItem.context["isExpanded"] = data.isExpanded
            cellItem.diffIdentifier = "\(id)\(data.description)"
            let separatorCellItem = self.separatorCellItemFactory.makeCellItems(array: [data])[0]
            guard data.isExpanded else {
                return [cellItem, separatorCellItem]
            }
            let descriptionCellItem = self.descriptionCellItemFactory.makeCellItems(array: [data])[0]
            return [cellItem, descriptionCellItem, separatorCellItem]
        }
        factory.isEqualHandler = { lhs, rhs in
            (lhs.context["isExpanded"] as? Bool) == (rhs.context["isExpanded"] as? Bool)
        }
        factory.cellConfigurationHandler = { data, cell, cellItem in
            if data.isExpanded {
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

