//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

public class CollectionViewViewCell<View: UIView>: UICollectionViewCell {

    // MARK: Subviews

    public var view: View? {
        willSet {
            view?.removeFromSuperview()
        }
        didSet {
            guard let view = view else {
                return
            }
            contentView.addSubview(view)
            setNeedsLayout()
        }
    }

    // MARK: Life cycle

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        view?.frame = contentView.bounds
    }
}
