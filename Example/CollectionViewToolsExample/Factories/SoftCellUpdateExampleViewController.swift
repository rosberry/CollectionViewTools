//
//  Copyright © 2021 Rosberry. All rights reserved.
//

import UIKit
import CollectionViewTools

final class SoftCellUpdateExampleViewController: UIViewController {

    private lazy var manager: CollectionViewManager = .init(collectionView: collectionView)
    private lazy var factory: HorizontalCollectionSectionItemsFactory = {
        let factory = HorizontalCollectionSectionItemsFactory()
        factory.output = self
        return factory
    }()

    private let packs: [Pack] = [
        .init(id: "1", thumbnail: #imageLiteral(resourceName: "nightlife-1"), templates: [
            .init(id: "1.1", text: "A"),
            .init(id: "1.2", text: "B"),
            .init(id: "1.3", text: "C"),
            .init(id: "1.4", text: "D"),
            .init(id: "1.5", text: "E")
        ]),
        .init(id: "2", thumbnail: #imageLiteral(resourceName: "nightlife-2"), templates: [
            .init(id: "2.1", text: "F"),
            .init(id: "2.2", text: "G"),
            .init(id: "2.3", text: "H")
        ]),
        .init(id: "3", thumbnail: #imageLiteral(resourceName: "nightlife-3"), templates: [
            .init(id: "3.1", text: "I"),
            .init(id: "3.2", text: "J"),
            .init(id: "3.3", text: "K"),
            .init(id: "3.4", text: "L")
        ]),
        .init(id: "4", thumbnail: #imageLiteral(resourceName: "nightlife-3"), templates: [
            .init(id: "4.1", text: "M"),
            .init(id: "4.2", text: "N"),
            .init(id: "4.3", text: "O"),
            .init(id: "4.4", text: "P"),
            .init(id: "4.5", text: "Q"),
            .init(id: "4.6", text: "R"),
            .init(id: "4.7", text: "S"),
            .init(id: "4.8", text: "T"),
            .init(id: "4.9", text: "U")
        ])
    ]

    private var displayedPacks: [Pack] = []

    // MARK: - Subviews

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.green.cgColor
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = true
        switchControl.backgroundColor = UIColor.red
        switchControl.layer.cornerRadius = 15
        switchControl.clipsToBounds = true
        switchControl.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        return switchControl
    }()

    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .gray
        label.text = "Unfold any pack from bottom placed picker and tap some nested item.\nUse switch at top right corner to change cell update mode"
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.addSubview(imageView)
        view.addSubview(switchControl)
        view.addSubview(placeholderLabel)
        updateCollection()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let collectionHeight: CGFloat = 150
        let bottom: CGFloat = view.bounds.height - view.safeAreaInsets.bottom
        collectionView.frame = .init(x: 0, y: bottom - collectionHeight,
                                     width: view.bounds.width, height: collectionHeight)

        let imageInset: CGFloat = 16
        let top = view.safeAreaInsets.top
        let imageWidth = view.bounds.width - 2 * imageInset
        let imageHeight = collectionView.frame.minY - view.safeAreaInsets.top - 2 * imageInset
        imageView.frame = .init(x: imageInset, y: top + imageInset, width: imageWidth, height: imageHeight)
        placeholderLabel.frame = imageView.frame

        switchControl.frame = .init(x: imageWidth - 50, y: top + 40, width: 51, height: 31)
    }

    // MARK: - Actions

    @objc private func switchValueChanged() {
        switch switchControl.isOn {
        case true:
            manager.cellUpdateMode = .soft
        case false:
            manager.cellUpdateMode = .hard
        }
    }

    // MARK: - Private

    private func updateCollection() {
        if let favoritePack = makeFavoritePack() {
            displayedPacks = [favoritePack] + self.packs
        }
        else {
            displayedPacks = self.packs
        }
        let sectionItems = factory.makeSectionItems(packs: displayedPacks)
        if manager.sectionItems.isEmpty {
            manager.sectionItems = sectionItems
        }
        else {
            manager.update(with: sectionItems, animated: true)
        }
    }

    private func makeFavoritePack() -> Pack? {
        let templates: [Template] = packs.flatMap { pack in
            pack.templates.compactMap { template in
                guard template.isFavorite else {
                    return nil
                }
                let template = Template(id: "f:" + template.id, text: template.text)
                template.isFavorite = true
                return template
            }
        }
        guard templates.isEmpty == false else {
            return nil
        }
        let pack = Pack(id: "0", thumbnail: #imageLiteral(resourceName: "favorite"), templates: templates)
        if let first = displayedPacks.first,
           first.id == "0" {
            pack.isExpanded = first.isExpanded
        }
        return pack
    }
}

extension SoftCellUpdateExampleViewController: HorizontalCollectionSectionItemsFactoryOutput {

    func toggle(pack: Pack) {
        if pack.isExpanded {
            pack.isExpanded.toggle()
            placeholderLabel.isHidden = false
        }
        else {
            placeholderLabel.isHidden = true
            displayedPacks.forEach { storedPack in
                storedPack.isExpanded = pack.id == storedPack.id
            }
        }
        imageView.image = pack.isExpanded ? pack.thumbnail : nil
        updateCollection()
        for sectionItem in manager.sectionItems {
            guard let sectionItem = sectionItem as? CollectionViewDiffSectionItem,
                  sectionItem.diffIdentifier == pack.id,
                  let cellItem = sectionItem.cellItems.first else {
                continue
            }
            manager.scroll(to: cellItem, at: .left, animated: true)
            return
        }
    }

    func toggleFavorite(template: Template) {
        if template.id.starts(with: "f:") {
            togleFavoriteInFavoritesPack(template: template)
        }
        else {
            template.isFavorite.toggle()
            updateCollection()
        }
    }

    func togleFavoriteInFavoritesPack(template: Template) {
        let id = template.id.dropFirst(2)
        let components = id.split(separator: ".")
        guard var packNumber = Int(components[0]),
              var templateNumber = Int(components[1]) else {
            return
        }
        packNumber -= 1
        templateNumber -= 1
        guard packs.count > packNumber,
              packs[packNumber].templates.count > templateNumber else {
            return
        }
        let template = packs[packNumber].templates[templateNumber]
        guard template.id == String(id) else {
            return
        }
        template.isFavorite = false
        updateCollection()
    }
}
