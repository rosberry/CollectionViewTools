//
//  FactoryExampleViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

final class LazySectionItemsExampleViewController: UIViewController {

    // MARK: Subviews

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true

        return collectionView
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Library"
        view.addSubview(collectionView)
        view.backgroundColor = .white
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        collectionView.contentInset.bottom = bottomLayoutGuide.length
    }
}

