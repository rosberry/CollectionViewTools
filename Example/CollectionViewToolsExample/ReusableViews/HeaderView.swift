//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

final class HeaderView: UICollectionReusableView {

    var foldHandler: (() -> Void)?
    var removeHandler: (() -> Void)?

    // MARK: - Subviews

    private(set) lazy var contentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()

    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private(set) lazy var foldButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(foldButtonPressed), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return button
    }()

    private(set) lazy var removeButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.setTitle("Remove", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(removeButtonPressed), for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(contentView)
        addSubview(foldButton)
        addSubview(removeButton)
        addSubview(label)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let inset: CGFloat = 8

        contentView.frame.origin = CGPoint(x: inset, y: 0)
        contentView.frame.size = CGSize(width: bounds.width - 2 * inset, height: bounds.height)

        removeButton.sizeToFit()
        removeButton.frame.origin.x = bounds.width - removeButton.frame.width - 2 * inset
        removeButton.center.y = 0.5 * bounds.height

        foldButton.sizeToFit()
        foldButton.frame.origin.x = removeButton.frame.minX - foldButton.frame.width - inset
        foldButton.center.y = 0.5 * bounds.height

        label.frame.origin = CGPoint(x: 2 * inset, y: 0)
        label.frame.size = CGSize(width: foldButton.frame.minX - 3 * inset, height: bounds.height)
    }

    // MARK: - Actions

    @objc private func removeButtonPressed() {
        removeHandler?()
    }

    @objc private func foldButtonPressed() {
        foldHandler?()
    }
}
