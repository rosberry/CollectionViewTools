//
//  File.swift
//  CollectionViewTools
//
//  Created by Anton K on 4/29/19.
//  Copyright © 2019 Rosberry. All rights reserved.
//

import Foundation

open class GeneralCollectionViewSectionDataSource: CollectionViewSectionDataSource {
    public var sources: [CollectionViewItemDataSource]

    public var sectionItemProvider: (Int) -> CollectionViewSectionItem?

    public var sectionCount: Int {
        return sources.count
    }

    public init(sources: [CollectionViewItemDataSource], sectionItemProvider: @escaping (Int) -> CollectionViewSectionItem?) {
        self.sources = sources
        self.sectionItemProvider = sectionItemProvider
    }

    open func sectionItem(at index: Int) -> CollectionViewSectionItem? {
        return sectionItemProvider(index)
    }

    open func itemDataSource(at index: Int) -> CollectionViewItemDataSource? {
        guard sources.indices.contains(index) else {
            return nil
        }

        return sources[index]
    }
}
