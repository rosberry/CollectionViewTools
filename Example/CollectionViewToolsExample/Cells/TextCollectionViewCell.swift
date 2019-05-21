//
// Copyright (c) 2018 Rosberry. All rights reserved.
//

import UIKit

final class TextCollectionViewCell: UICollectionViewCell {

    override var isHighlighted: Bool {
        didSet {
            titleLabel.alpha = isHighlighted ? 0.7 : 1.0
        }
    }

    // MARK: Subviews
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    // MARK: Life cycle
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 4
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return titleLabel.sizeThatFits(.init(width: .greatestFiniteMagnitude, height: size.height))
    }
}
