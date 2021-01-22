//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var image: UIImage?
    private lazy var imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.clipsToBounds = true

        imageView.contentMode = .scaleAspectFill
        imageView.image = image
        view.addSubview(imageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let image = image {
            let imageAspect = image.size.width / image.size.height
            let imageViewSize = CGSize(width: view.bounds.width, height: view.bounds.width / imageAspect)
            imageView.frame = CGRect(x: 0,
                                     y: (view.bounds.size.height - imageViewSize.height) / 2,
                                     width: imageViewSize.width,
                                     height: imageViewSize.height)
        }
    }
}
