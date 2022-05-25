//
//  ImageCollectionViewCell.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {
    
    var removeActionHandler: (() -> Void)?
    
    // MARK: Subviews
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(removeButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = contentView.bounds
        
        let side = contentView.bounds.width / 8
        removeButton.frame = .init(x: contentView.bounds.width - side, y: 0, width: side, height: side)
    }
    
    // MARK: Actions
    
    @objc private func removeButtonPressed() {
        removeActionHandler?()
    }
}
