//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit

final class TextContentCollectionViewCell: UICollectionViewCell {

    override var isHighlighted: Bool {
        get {
            textContentView.isHighlighted
        }
        set {
            textContentView.isHighlighted = newValue
        }
    }

    lazy var textContentView: TextContentView = .init()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textContentView.frame = contentView.bounds
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return textContentView.sizeThatFits(.init(width: CGFloat.greatestFiniteMagnitude,
                                                  height: .greatestFiniteMagnitude))
    }

    // MARK: - Private

    private func setup() {
        addSubview(textContentView)
    }
}
