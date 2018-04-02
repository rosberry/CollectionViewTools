//
//  MainViewController.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

class DataModel {
    let title: String
    let image: UIImage

    init(title: String, image: UIImage) {
        self.title = title
        self.image = image
    }
}

class MainViewController: UIViewController {
    
    private let dataModels = [
        DataModel(title: "nightlife-1", image: #imageLiteral(resourceName: "nightlife-1")),
        DataModel(title: "nightlife-2", image: #imageLiteral(resourceName: "nightlife-1")),
        DataModel(title: "nightlife-3", image: #imageLiteral(resourceName: "nightlife-3")),
        DataModel(title: "nightlife-4", image: #imageLiteral(resourceName: "nightlife-4")),
        DataModel(title: "nightlife-5", image: #imageLiteral(resourceName: "nightlife-5"))
    ]
    
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
    
    var imagesSectionItem: CollectionViewSectionItemProtocol {
        let sectionItem = CollectionViewSectionItem()
        sectionItem.cellItems = dataModels.map { model in
            var cellItem = ImageAndTitleCellItem(image: model.image, title: model.title)
//            cellItem.itemDidSelectHandler = { [weak self] (collectionView, indexPath) in
//                guard let `self` = self else {
//                    return
//                }
//                let detailViewController = DetailViewController()
//                detailViewController.image = model.image
//                self.navigationController?.pushViewController(detailViewController, animated: true)
//            }
            return AnyCollectionViewCellItem.init(cellItem)
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

