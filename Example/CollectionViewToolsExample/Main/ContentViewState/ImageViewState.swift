//
//  ImageViewState.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

final class ImageViewState: ContentViewState {
    var imageContent: ImageContent

    init(imageContent: ImageContent) {
        self.imageContent = imageContent
        super.init(content: imageContent)
    }
}
