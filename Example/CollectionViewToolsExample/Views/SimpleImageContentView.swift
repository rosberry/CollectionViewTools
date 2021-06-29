//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

final class SimpleImageContentView: UIView {
    var removeActionHandler: (() -> Void)?

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

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

        imageView.frame = bounds
    }

    @objc private func removeButtonPressed() {
        removeActionHandler?()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let image = imageView.image else {
            return .zero
        }
        let aspect = image.size.height / image.size.width
        let width = size.width
        let height = width * aspect
        return .init(width: width, height: height)
    }

    // MARK: - Private

    private func setup() {
        addSubview(imageView)
        backgroundColor = .white
    }
}
