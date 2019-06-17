//
//  ReusableView.swift
//  CollectionViewToolsExample
//
//  Created by Стас Клюхин on 17/06/2019.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

final class ReusableView: UICollectionReusableView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
