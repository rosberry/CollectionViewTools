//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import UIKit

final class FactoriesViewController: UIViewController {

    // MARK: - Subviews

    private lazy var factoryExampleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Factory Example", for: .normal)
        button.addTarget(self, action: #selector(factoryExampleButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var lazyFactoryExampleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Lazy Factory Example", for: .normal)
        button.addTarget(self, action: #selector(lazyFactoryExampleButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var softUpdateExampleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Soft Cell Update Example", for: .normal)
        button.addTarget(self, action: #selector(softCellUpdateExampleButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var buttons: [UIButton] = [
        factoryExampleButton,
        lazyFactoryExampleButton,
        softUpdateExampleButton
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buttons.forEach { button in
            view.addSubview(button)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let inset: CGFloat = 16
        let width = view.bounds.width - 2 * inset
        let height: CGFloat = 48
        let topToSafeArea: CGFloat = 48 + view.safeAreaInsets.top

        buttons.enumerated().forEach { index, button in
            button.frame = .init(x: inset, y: topToSafeArea + CGFloat(index) * (height + inset),
                                 width: width, height: height)
        }
    }

    // MARK: - Actions

    @objc private func factoryExampleButtonPressed() {
        let viewController = FactoryExampleViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func lazyFactoryExampleButtonPressed() {
        let viewController = LazySectionItemsExampleViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc private func softCellUpdateExampleButtonPressed() {
        let viewController = SoftCellUpdateExampleViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
