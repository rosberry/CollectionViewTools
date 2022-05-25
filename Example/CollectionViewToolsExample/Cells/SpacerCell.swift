//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

final class SpacerCell: UICollectionViewCell {

    private(set) lazy var spacerView: SpacerView = .init()

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
        spacerView.frame = bounds
    }

    // MARK: - Private

    private func setup() {
        addSubview(spacerView)
    }

}
