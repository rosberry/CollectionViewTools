//
//  Copyright © 2019 Rosberry. All rights reserved.
//

final class CollectionViewDiffResult {

    typealias SectionChanges = CollectionViewChanges<CollectionViewDiffSectionItem>
    typealias SectionUpdate = CollectionViewUpdate<CollectionViewDiffSectionItem>
    typealias CellChanges = CollectionViewChanges<CollectionViewDiffCellItem>
    typealias CellChangesMap = [SectionUpdate: CellChanges]

    let sectionChanges: SectionChanges
    let sectionUpdates: [SectionUpdate]
    let hasSectionUpdates: Bool

    let cellChangesMap: CellChangesMap
    let cellUpdatesMap: CellChangesMap
    let cellDeletesInsertsMovesMap: CellChangesMap
    let hasCellUpdates: Bool
    let hasCellDeletesInsertsMoves: Bool

    init(sectionChanges: SectionChanges, cellChangesMap: CellChangesMap) {
        self.sectionChanges = sectionChanges
        self.cellChangesMap = cellChangesMap

        var sectionUpdates: [SectionUpdate] = []
        var cellUpdatesMap: CellChangesMap = [:]
        var cellDeletesInsertsMovesMap: CellChangesMap = [:]

        for update in sectionChanges.updates {
            if let cellChanges = cellChangesMap[update] {
                if cellChanges.hasDeletes ||
                    cellChanges.hasInserts ||
                    cellChanges.hasMoves {
                    cellDeletesInsertsMovesMap[update] = cellChanges
                }
                if cellChanges.hasUpdates {
                    cellUpdatesMap[update] = cellChanges
                }
            }
            else {
                sectionUpdates.append(update)
            }
        }

        self.sectionUpdates = sectionUpdates
        self.cellUpdatesMap = cellUpdatesMap
        self.cellDeletesInsertsMovesMap = cellDeletesInsertsMovesMap

        hasSectionUpdates = sectionUpdates.count > 0
        self.hasCellUpdates = cellUpdatesMap.count > 0
        self.hasCellDeletesInsertsMoves = cellDeletesInsertsMovesMap.count > 0
    }
}

final class CollectionViewDiffResultProvider {

    let backgroundQueue: DispatchQueue = .init(label: "DiffBackgroundQueue", qos: .background)
    let semaphore: DispatchSemaphore = .init(value: 1)

    func diffResult(for sectionItems: [CollectionViewDiffSectionItem],
                    in manager: CollectionViewManager,
                    diff: CollectionViewDiff,
                    completion: @escaping (CollectionViewDiffResult?) -> Void) {
        backgroundQueue.async {
            self.semaphore.wait()

            let oldSectionItems = manager.diffSectionItems

            let sectionDiffs = diff.changes(old: self.wrappers(for: oldSectionItems),
                                            new: self.wrappers(for: sectionItems))
            if sectionDiffs.isEmpty {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            let sectionChanges = CollectionViewChanges<CollectionViewDiffSectionItem>(changes: sectionDiffs)
            var cellChangesMap: CollectionViewDiffResult.CellChangesMap = [:]
            for update in sectionChanges.updates {
                let cellDiffs = diff.changes(old: self.wrappers(for: update.oldItem.diffCellItems),
                                             new: self.wrappers(for: update.newItem.diffCellItems))
                if cellDiffs.isEmpty {
                    continue
                }
                let cellChanges = CollectionViewChanges<CollectionViewDiffCellItem>(changes: cellDiffs)
                cellChangesMap[update] = cellChanges
            }
            let result = CollectionViewDiffResult(sectionChanges: sectionChanges, cellChangesMap: cellChangesMap)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    private func wrappers(for items: [CollectionViewDiffItem]) -> [CollectionViewDiffItemWrapper] {
        return items.map { item in
            CollectionViewDiffItemWrapper(item: item)
        }
    }
}
