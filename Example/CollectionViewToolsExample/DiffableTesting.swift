//
//  Copyright © 2019 Rosberry. All rights reserved.
//

import DeepDiff
//import IGListKit
import CollectionViewTools

final class DiffableTesting {

    func test() {
        testInserts()
        testDeletes()
    }

    private func testInserts() {
        let old: [DiffableTestObject] = [
            .init(id: 1, value: "Test1"),
            .init(id: 2, value: "Test2"),
        ]
        let new: [DiffableTestObject] = [
            .init(id: 1, value: "Test1"),
            .init(id: 3, value: "Test1"),
            .init(id: 2, value: "Test2_1")
        ]
        let deepDiffChanges = CollectionViewDeepDiff().changes(old: old, new: new)
        let igListKitChanges = CollectionViewIGListKitDiff().changes(old: old, new: new)

        print("<<< INSERTS")
        print("<<< DEEP DIFF \(deepDiffChanges)")
        print("<<< IG LIST KIT \(igListKitChanges)")
    }

    private func testDeletes() {
        let old: [DiffableTestObject] = [
            .init(id: 1, value: "Test1"),
            .init(id: 2, value: "Test2"),
        ]
        let new: [DiffableTestObject] = [
            .init(id: 2, value: "Test2_1"),
        ]
        let deepDiffChanges = CollectionViewDeepDiff().changes(old: old, new: new)
        let igListKitChanges = CollectionViewIGListKitDiff().changes(old: old, new: new)

        print("<<< DELETES")
        print("<<< DEEP DIFF \(deepDiffChanges)")
        print("<<< IG LIST KIT \(igListKitChanges)")
    }
}
