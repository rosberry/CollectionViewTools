//
// Copyright (c) 2018 Rosberry. All rights reserved.
//

import UIKit

final class TextCollectionViewCell: UICollectionViewCell {
    
    // MARK: Subviews
    
    lazy var titleLabel: UILabel = .init()
    
    // MARK: Life cycle
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = contentView.bounds
    }
}
