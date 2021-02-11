//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

final class SpacerView: UIView {
    private(set) lazy var dividerView: UIView = .init()
    var dividerInsets: UIEdgeInsets = .zero
    var dividerHeight: CGFloat = 1

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
       dividerView.frame = CGRect(x: dividerInsets.left,
                                  y: dividerInsets.top == 0 ? bounds.height - dividerInsets.bottom - dividerHeight : dividerInsets.top,
                                  width: bounds.width - dividerInsets.left - dividerInsets.right,
                                  height: dividerHeight)
    }

    // MARK: - Private

    private func setup() {
        addSubview(dividerView)
        backgroundColor = .white
    }
}
