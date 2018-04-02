//
//  ImageAndTitleCollectionViewCell.swift
//  CollectionViewToolsExample
//
//  Created by Dmitry Frishbuter on 23/03/2018.
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit

final class ImageAndTitleCollectionViewCell: ImageCollectionViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 20)
        imageView.frame = CGRect(
            x: 0, y: titleLabel.bounds.height,
            width: bounds.width, height: bounds.height - titleLabel.bounds.height
        )
    }
}
