//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import UIKit

final class ImageContentView: UIView {
    var removeActionHandler: (() -> Void)?

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
        return button
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

        let side = bounds.width / 8
        removeButton.frame = .init(x: bounds.width - side, y: 0, width: side, height: side)
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
        addSubview(removeButton)
        backgroundColor = .white
    }
}
