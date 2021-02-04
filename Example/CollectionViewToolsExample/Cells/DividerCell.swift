//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

final class DividerCell: UICollectionViewCell {

    private(set) lazy var dividerView: UIView = .init()
    var dividerInsets: UIEdgeInsets = .zero
    var dividerHeight: CGFloat = 1

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(dividerView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        dividerView.frame = CGRect(x: dividerInsets.left,
                                   y: dividerInsets.top == 0 ? bounds.height - dividerInsets.bottom - dividerHeight : dividerInsets.top,
                                   width: bounds.width - dividerInsets.left - dividerInsets.right, height: dividerHeight)
    }

}
