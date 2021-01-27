//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import UIKit

final class TextCollectionViewCell: UICollectionViewCell {

    override var isHighlighted: Bool {
        didSet {
            textContentView.isHighlighted = isHighlighted
        }
    }

    lazy var textContentView: TextContentView = .init()

    var titleLabel: UILabel {
        textContentView.titleLabel
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
