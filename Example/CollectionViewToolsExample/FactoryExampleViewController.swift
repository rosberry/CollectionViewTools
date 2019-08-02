//
//  FactoryExampleViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

class FactoryExampleViewController: UIViewController {
    
    struct ImageData {
        let image: UIImage
        let description: String
    }
    
    struct TextData {
        let text: String
        let description: String
    }
    
    var data: [Any] = [ImageData(image: #imageLiteral(resourceName: "nightlife-1"), description: "First image description"),
                       ImageData(image: #imageLiteral(resourceName: "nightlife-2"), description: "Second image description"),
                       TextData(text: "Fist topic", description: "First topic description"),
                       ImageData(image: #imageLiteral(resourceName: "nightlife-3"), description: "Third image description"),
                       ImageData(image: #imageLiteral(resourceName: "nightlife-4"), description: "Foursh image description"),
                       TextData(text: "Second topic", description: "Second topic description"),
                       TextData(text: "Third topic", description: "Third topic description"),
                       TextData(text: "Foursh topic", description: "Foursh topic description"),
                       ImageData(image: #imageLiteral(resourceName: "nightlife-5"), description: "Fifth image description"),
                       TextData(text: "Fifth topic", description: "Fifth topic description")]
    
    private lazy var unfoldedItemsFactory: CellItemFactory = {
        let factory = AssociatedCellItemFactory<Any, TextCollectionViewCell>()
        let sizeCell = TextCollectionViewCell()
        factory.cellConfigurationHandler = { data, cell, cellItem in
            let text: String
            if let data = data as? ImageData {
                text = data.description
            }
            else if let data = data as? TextData {
                text = data.description
            }
            else {
                text = ""
            }
            cell.titleLabel.text = text
        }
        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            let width = collectionView.bounds.width
            let height = sizeCell.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude)).height
            return CGSize(width: width, height: height + 48)
        }
        return factory
    }()
    
    private lazy var cellItemFactory: CellItemFactory = {
        let textCellItemFactory: CellItemFactory = {
            let factory: AssociatedCellItemFactory<TextData, TextCollectionViewCell> = makeFactory()
            
            factory.cellConfigurationHandler = { data, cell, cellItem in
                cell.titleLabel.text = data.text
            }
            
            factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
                return CGSize(width: collectionView.bounds.width, height: 60)
            }
            
            return factory
        }()
        
        let imageCellItemFactory: CellItemFactory = {
            let factory: AssociatedCellItemFactory<ImageData, ImageCollectionViewCell> = makeFactory()
            
            factory.cellConfigurationHandler = { data, cell, cellItem in
                cell.imageView.image = data.image
            }
            
            factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
                let width = collectionView.bounds.width
                let aspectRatio = data.image.size.width / data.image.size.height
                return CGSize(width: width, height: width / aspectRatio)
            }
            
            return factory
        }()
        return textCellItemFactory.join(imageCellItemFactory)
    }()

    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    private var unfoldedIndices = [Int]()
    
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
        edgesForExtendedLayout = []
        view.addSubview(mainCollectionView)
        view.backgroundColor = .white
        
        resetMainCollection()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var bottomInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomInset = view.safeAreaInsets.bottom
        }
        mainCollectionView.frame = .init(x: 0,
                                         y: 0,
                                         width: view.bounds.width,
                                         height: view.bounds.height - bottomInset)
    }
    
    // MARK: - Private
    
    private func resetMainCollection() {
        mainCollectionViewManager.update([makeGeneralSectionItem()], shouldReloadData: true) {
            print("Reload complete")
        }
        mainCollectionView.contentOffset = .zero
    }
    
    private func makeGeneralSectionItem() -> CollectionViewSectionItem {
        let cellItems = cellItemFactory.makeCellItems(for: data)
        return GeneralCollectionViewSectionItem(cellItems: cellItems)
    }
    
    private func makeActionsSectionItem() -> CollectionViewSectionItem {
        return makeActionsSectionItem(cellItems: [])
    }
    
    private func makeFactory<U: Any, T: UICollectionViewCell>() -> AssociatedCellItemFactory<U, T> {
        let factory = AssociatedCellItemFactory<U, T>()
        let spaceItem = UniversalCollectionViewCellItem<DividerCell>()
        spaceItem.configurationHandler = { cell in
            cell.dividerView.backgroundColor = .gray
            cell.dividerInsets = .init(top: 0, left: 0, bottom: 8, right: 0)
        }
        spaceItem.sizeConfigurationHandler = { collectionView, _ in
            return CGSize(width: collectionView.bounds.width, height: 16)
        }
        factory.initializationHandler = { [weak factory, weak self] index, data in
            guard let self = self, let factory = factory  else {
                return []
            }
            let mainCellItem = factory.makeUniversalCellItem(for: data, at: index)
            if let descriptionItem = self.unfoldedItemsFactory.makeCellItems(for: data, at: index).first {
                mainCellItem.itemDidSelectHandler = { _ in
                    if let position = self.unfoldedIndices.index(of: index) {
                        self.unfoldedIndices.remove(at: position)
                        self.mainCollectionViewManager.remove([descriptionItem])
                    }
                    else {
                        self.unfoldedIndices.append(index)
                        if let sectionItem = mainCellItem.sectionItem,
                            let startIndex = mainCellItem.indexPath?.row {
                            self.mainCollectionViewManager.insert([descriptionItem], to: sectionItem, at: [startIndex + 1])
                        }
                    }
                }
            }
            return [mainCellItem, spaceItem]
        }
        
        return factory
    }
    
    private func makeDivider() {
        
    }
}
