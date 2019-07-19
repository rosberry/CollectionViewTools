//
//  ImageCollectionViewCell.swift
//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

final class HeaderView: UICollectionReusableView {
    
    var selectionHandler: (() -> Void)?
    
    // MARK: Subviews
    
    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.red.withAlphaComponent(0.2)
        addSubview(label)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()        
        label.frame = bounds
    }
    
    // MARK: - Actions
    
    @objc private func tapped() {
        selectionHandler?()
    }
}
