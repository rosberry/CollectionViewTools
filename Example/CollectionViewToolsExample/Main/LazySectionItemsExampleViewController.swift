//
//  FactoryExampleViewController.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

final class LazySectionItemsExampleViewController: UIViewController {

    struct Events {
        let month: String
        let array: [Int]
    }

    var data: [Events] = [.init(month: "May, 2020", array: Array(1..<100)),
                          .init(month: "June, 2020", array: Array(100..<200)),
                          .init(month: "July, 2020", array: Array(200..<300)),
                          .init(month: "August, 2020", array: Array(300..<400))]

    // MARK: Subviews

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true

        return collectionView
    }()


    private lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)

    private lazy var sectionItemsProvider: SectionItemsProvider = {
        LazyFactorySectionItemsProvider(
            factory: cellItemsFactory,
            sectionItemsNumberHandler: { [weak self] in
                self?.data.count ?? 0
            },
            cellItemsNumberHandler: { [weak self] index in
                self?.data[index].array.count ?? 0
            },
            sizeHandler: { _, collectionView in
                .init(width: collectionView.bounds.width, height: 80)
            },
            makeSectionItemHandler: { index in
                LazyCollectionViewSectionItem(reusableViewItems: [
                    HeaderViewItem(title: "Section \(index)",
                                   backgroundColor: UIColor.black.withAlphaComponent(0.5),
                                   isFolded: false)
                ])
            },
            objectHandler: { [weak self] indexPath in
                self?.data[indexPath.section].array[indexPath.row]
            }
        )
    }()

    private lazy var cellItemsFactory: CellItemFactory = {
        let factory = AssociatedCellItemFactory<Int, TextCollectionViewCell>()
        factory.cellConfigurationHandler = { number, cell, cellItem in
            cell.titleLabel.text = "\(number)"
        }
        return factory
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Library"
        view.addSubview(collectionView)
        view.backgroundColor = .white
        collectionViewManager.sectionItemsProvider = sectionItemsProvider
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        collectionView.contentInset.bottom = bottomLayoutGuide.length
    }
}

