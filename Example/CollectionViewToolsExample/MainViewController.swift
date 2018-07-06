//
//  MainViewController.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

class MainViewController: UIViewController {
    
    let images = [#imageLiteral(resourceName: "nightlife-1"), #imageLiteral(resourceName: "nightlife-2"), #imageLiteral(resourceName: "nightlife-3"), #imageLiteral(resourceName: "nightlife-4"), #imageLiteral(resourceName: "nightlife-5")]
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -6, right: 0)
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        return collectionView
    }()
    
    lazy var manager: CollectionViewManager = {
        return CollectionViewManager(collectionView: self.collectionView)
    }()
    
    var imagesSectionItem: CollectionViewSectionItem {
        let sectionItem = GeneralCollectionViewSectionItem()
        sectionItem.cellItems = images.map {
            AnyCollectionViewCellItem(ImageCellItem(image: $0) { [weak self] image in
                let detailViewController = DetailViewController()
                detailViewController.image = image
                self?.navigationController?.pushViewController(detailViewController, animated: true)
            })
        }
        return sectionItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        view.addSubview(collectionView)
        manager.sectionItems = [imagesSectionItem]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 200)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.flashScrollIndicators()
    }
}

