//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

final class FavoritableTextContentView: UIView {

    var isHighlighted: Bool = false {
        didSet {
            alpha = isHighlighted ? 0.7 : 1.0
        }
    }

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    

    let favoriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

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
        titleLabel.frame = bounds
        let side = bounds.width / 3
        favoriteImageView.frame = .init(x: bounds.width - side - 2, y: 2, width: side, height: side)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return titleLabel.sizeThatFits(.init(width: size.width,
                                             height: .greatestFiniteMagnitude))
    }

    // MARK: - Private

    private func setup() {
        addSubview(titleLabel)
        addSubview(favoriteImageView)
        backgroundColor = .white
    }
}
