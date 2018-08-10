//
//  MainViewController.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

class MainViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -6, right: 0)
        collectionView.clipsToBounds = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    lazy var manager: CollectionViewManager = {
        return CollectionViewManager(collectionView: self.collectionView)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Library"
        
        var images: [UIImage] = []
        for _ in 0..<10 {
            images.append(contentsOf: [#imageLiteral(resourceName: "nightlife-1"), #imageLiteral(resourceName: "nightlife-2"), #imageLiteral(resourceName: "nightlife-3"), #imageLiteral(resourceName: "nightlife-4"), #imageLiteral(resourceName: "nightlife-5")])
        }
        
        edgesForExtendedLayout = []
        view.addSubview(collectionView)
        manager.sectionItems = [makeImagesSectionItem(images: images)]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
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
}
