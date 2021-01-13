//
//  ImageViewState.swift
//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import Foundation

final class ImageViewState: ContentViewState, NSCopying {
    var imageContent: ImageContent

    init(imageContent: ImageContent) {
        self.imageContent = imageContent
        super.init(content: imageContent)
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let state = ImageViewState(imageContent: imageContent)
        state.isExpanded = isExpanded
        return state
    }
}
