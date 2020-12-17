//
//  DividerCell.swift
//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

final class DividerCell: UICollectionViewCell {
    
    private(set) lazy var dividerView: DividerView = .init()
    var dividerInsets: UIEdgeInsets = .zero {
        didSet {
            dividerView.dividerInsets = dividerInsets
        }
    }
    var dividerHeight: CGFloat = 1 {
        didSet {
            dividerView.dividerHeight = dividerHeight
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dividerView.frame = bounds
    }

    // MARK: - Private

    private func setup() {
        addSubview(dividerView)
    }
}
