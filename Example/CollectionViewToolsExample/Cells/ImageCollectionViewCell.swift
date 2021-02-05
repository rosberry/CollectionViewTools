//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

final class ImageCollectionViewCell: UICollectionViewCell {

    var removeActionHandler: (() -> Void)? {
        didSet {
            imageContentView.removeActionHandler = removeActionHandler
        }
    }

    private(set) lazy var imageContentView: ImageContentView = .init()

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

        imageContentView.frame = contentView.bounds
    }

    @objc private func removeButtonPressed() {
        removeActionHandler?()
    }

    // MARK: - Private

    private func setup() {
        contentView.addSubview(imageContentView)
    }
}
