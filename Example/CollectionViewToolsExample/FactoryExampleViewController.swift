//
//  FactoryExampleViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

private var diffIdentifierAssociationKey = "diff_identifier"

protocol HasDescriptionProtocol {
    var description: String { get }
}

final class FactoryExampleViewController: UIViewController {
    
    struct ImageData: HasDescriptionProtocol {
        let image: UIImage
        let description: String
    }
    
    struct TextData: HasDescriptionProtocol {
        let text: String
        let description: String
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
    
    private lazy var unfoldedItemsFactory: CellItemFactory = {
        let factory = AssociatedCellItemFactory<HasDescriptionProtocol, TextCollectionViewCell>()
        let sizeCell = TextCollectionViewCell()
        
        factory.cellConfigurationHandler = { data, cell, cellItem in
            cell.titleLabel.text = data.description
        }

        factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
            let width = collectionView.bounds.width
            sizeCell.titleLabel.text = data.description
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
                cell.removeActionHandler = { [weak self] in
                    self?.remove(cellItem)
                }
            }
            
            factory.sizeConfigurationHandler = { data, collectionView, sectionItem in
                let width = collectionView.bounds.width
                let aspectRatio = data.image.size.width / data.image.size.height
                return CGSize(width: width, height: width / aspectRatio)
            }
            
            return factory
        }()
        return textCellItemFactory.factory(byJoining: imageCellItemFactory)
    }()

    private lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    private var unfoldedIndices = [Int]()
    private lazy var spaceItem = UniversalCollectionViewCellItem<DividerCell>()
    
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
        mainCollectionViewManager.update([makeGeneralSectionItem()], shouldReloadData: true) {
            print("Reload complete")
        }
        mainCollectionView.contentOffset = .zero
    }
    
    private func makeGeneralSectionItem() -> CollectionViewSectionItem {
        let cellItems = cellItemFactory.makeCellItems(array: data)
        return GeneralCollectionViewSectionItem(cellItems: cellItems)
    }
    
    private func makeFactory<U: Any, T: UICollectionViewCell>() -> AssociatedCellItemFactory<U, T> {
        let factory = AssociatedCellItemFactory<U, T>()
        spaceItem.configurationHandler = { cell in
            cell.dividerView.backgroundColor = .gray
            cell.dividerInsets = .init(top: 0, left: 0, bottom: 8, right: 0)
        }
        spaceItem.sizeConfigurationHandler = { collectionView, _ in
            return CGSize(width: collectionView.bounds.width, height: 16)
        }
        factory.initializationHandler = { [weak factory, weak self] index, data in
            guard let self = self, let factory = factory else {
                return []
            }
            return self.initializeCellItems(with: data, at: index, using: factory)
        }
        
        return factory
    }
    
    private func initializeCellItems<U: Any, T: UICollectionViewCell>(with data: U,
                                                                      at index: Int,
                                                                      using factory: AssociatedCellItemFactory<U, T>) ->[CollectionViewCellItem?] {
        let mainCellItem = factory.makeUniversalCellItem(object: data, index: index)
        if let descriptionItem = unfoldedItemsFactory.makeCellItems(object: data, index: index).first {
            mainCellItem.itemDidSelectHandler = { _ in
                if let position = self.unfoldedIndices.firstIndex(of: index) {
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

    private func remove(_ cellItem: CollectionViewCellItem?) {
        guard let cellItem = cellItem else {
            return
        }
        mainCollectionViewManager.remove([cellItem])
        guard let indexPath = cellItem.indexPath else {
            mainCollectionViewManager.remove([cellItem])
            return
        }
        let secton = mainCollectionViewManager.sectionItems[indexPath.section]
        let dividerIndex = indexPath.row + 1
        guard secton.cellItems.count > dividerIndex else {
            mainCollectionViewManager.remove([cellItem])
            return
        }
        guard let separatorCellItem = secton.cellItems[dividerIndex] as?  UniversalCollectionViewCellItem<DividerCell> else {
            mainCollectionViewManager.remove([cellItem])
            return
        }
        mainCollectionViewManager.remove([cellItem, separatorCellItem])
    }
}

