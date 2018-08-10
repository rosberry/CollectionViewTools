//
//  MainViewController.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

class MainViewController: UIViewController {
    
    var images: [UIImage] {
        var images: [UIImage] = []
        for _ in 0..<10 {
            images.append(contentsOf: [#imageLiteral(resourceName: "nightlife-1"), #imageLiteral(resourceName: "nightlife-2"), #imageLiteral(resourceName: "nightlife-3"), #imageLiteral(resourceName: "nightlife-4"), #imageLiteral(resourceName: "nightlife-5")])
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
            ImageCellItem(image: image) { [weak self] image in
                let detailViewController = DetailViewController()
                detailViewController.image = image
                self?.navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
        sectionItem.insets = .init(top: 0, left: 12, bottom: 0, right: 12)
        sectionItem.minimumLineSpacing = 8
        return sectionItem
    }
    
    // MARK: Actions
    
    func makeActionsSectionItem() -> CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = [
            makeResetActionCellItem()
        ]
        sectionItem.insets = .init(top: 0, left: 8, bottom: 0, right: 8)
        return sectionItem
    }
    
    func makeResetActionCellItem() -> CollectionViewCellItem {
        var cellItem = TextCellItem(text: "Reset")
        cellItem.itemDidSelectHandler = { [weak self] _, _ in
            self?.resetMainCollection()
        }
        return cellItem
    }
}
