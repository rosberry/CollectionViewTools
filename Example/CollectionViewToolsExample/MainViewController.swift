//
//  MainViewController.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

class MainViewController: UIViewController {
    
    var initialImages: [UIImage] {
        return [#imageLiteral(resourceName: "nightlife-1"), #imageLiteral(resourceName: "nightlife-2"), #imageLiteral(resourceName: "nightlife-3"), #imageLiteral(resourceName: "nightlife-4"), #imageLiteral(resourceName: "nightlife-5")]
    }
    var images: [UIImage] {
        var images: [UIImage] = []
        for _ in 0..<10 {
            images.append(contentsOf: initialImages)
        }
        return images
    }
    
    lazy var mainCollectionViewManager: CollectionViewManager = .init(collectionView: mainCollectionView)
    lazy var actionsCollectionViewManager: CollectionViewManager = .init(collectionView: actionsCollectionView)
    
    // MARK: Subviews
    
    private lazy var actionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var mainCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Library"
        edgesForExtendedLayout = []
        view.addSubview(mainCollectionView)
        view.addSubview(actionsCollectionView)
        
        resetMainCollection()
        actionsCollectionViewManager.sectionItems = [makeActionsSectionItem()]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        var bottomInset: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomInset = view.safeAreaInsets.bottom
        }
        let actionsCollectionHeight: CGFloat = 100
        mainCollectionView.frame = .init(x: 0,
                                         y: 0,
                                         width: view.bounds.width,
                                         height: view.bounds.height - actionsCollectionHeight - bottomInset)
        actionsCollectionView.frame = .init(x: 0,
                                            y: view.bounds.height - actionsCollectionHeight - bottomInset,
                                            width: view.bounds.width,
                                            height: actionsCollectionHeight)
    }
    
    // MARK: - Private
    
    private func resetMainCollection() {
        mainCollectionViewManager.sectionItems = [makeImagesSectionItem(images: images)]
        mainCollectionView.contentOffset = .zero
    }
    
    // MARK: - Factory methods
    
    func makeImagesSectionItem(images: [UIImage]) -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = images.map { image in
            return makeImageCellItem(image: image)
        }
        sectionItem.insets = .init(top: 0, left: 12, bottom: 0, right: 12)
        sectionItem.minimumLineSpacing = 8
        return sectionItem
    }
    
    private func makeImageCellItem(image: UIImage) -> ImageCellItem {
        return ImageCellItem(image: image) { [weak self] image in
            let detailViewController = DetailViewController()
            detailViewController.image = image
            self?.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
    
    // MARK: Actions
    
    func makeActionsSectionItem() -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = [
            makeResetActionCellItem(),
            makePrependCellItemsActionCellItem()
        ]
        sectionItem.insets = .init(top: 0, left: 8, bottom: 0, right: 8)
        sectionItem.minimumInteritemSpacing = 8
        sectionItem.minimumLineSpacing = 8
        return sectionItem
    }
    
    func makeResetActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Reset") { [weak self] in
            self?.resetMainCollection()
        }
    }
    
    func makePrependCellItemsActionCellItem() -> CollectionViewCellItem {
        return makeActionCellItem(title: "Prepend cell items") { [weak self] in
            guard let `self` = self else {
                return
            }
            guard let sectionItem = self.mainCollectionViewManager.sectionItems.first else {
                return
            }
            let cellItems = self.initialImages.map { image in
                return self.makeImageCellItem(image: image)
            }
            self.mainCollectionViewManager.prepend(cellItems, to: sectionItem)
        }
    }
    
    // MARK: Common
    
    func makeActionCellItem(title: String, action: @escaping (() -> Void)) -> CollectionViewCellItem {
        var cellItem = TextCellItem(text: title)
        cellItem.itemDidSelectHandler = { _, _ in
            action()
        }
        return cellItem
    }
}
