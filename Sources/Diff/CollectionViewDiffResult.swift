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
    var sectionItems: [CollectionViewDiffSectionItem]?

    func diffResult(for sectionItems: [CollectionViewDiffSectionItem],
                    in manager: CollectionViewManager,
                    diff: CollectionViewDiff,
                    async: Bool = false,
                    completion: @escaping (CollectionViewDiffResult?) -> Void) {
        func complete(with result: CollectionViewDiffResult?) {
            if async {
                self.semaphore.signal()
                DispatchQueue.main.async {
                    completion(result)
                }
            }
            else {
                completion(result)
            }
        }
        func calculateDiff() {
            let oldSectionItems = self.sectionItems ?? manager.diffSectionItems
            self.sectionItems = sectionItems

            let sectionDiffs = diff.changes(old: wrappers(for: oldSectionItems),
                                            new: wrappers(for: sectionItems))
            if sectionDiffs.isEmpty {
                complete(with: nil)
                return
            }
            let sectionChanges = CollectionViewChanges<CollectionViewDiffSectionItem>(changes: sectionDiffs)
            var cellChangesMap: CollectionViewDiffResult.CellChangesMap = [:]
            for update in sectionChanges.updates {
                let cellDiffs = diff.changes(old: wrappers(for: update.oldItem.diffCellItems),
                                             new: wrappers(for: update.newItem.diffCellItems))
                if cellDiffs.isEmpty {
                    continue
                }
                let cellChanges = CollectionViewChanges<CollectionViewDiffCellItem>(changes: cellDiffs)
                cellChangesMap[update] = cellChanges
            }
            let result = CollectionViewDiffResult(sectionChanges: sectionChanges, cellChangesMap: cellChangesMap)
            complete(with: result)
        }
        if async {
            backgroundQueue.async {
                self.semaphore.wait()
                calculateDiff()
            }
        }
        else {
            calculateDiff()
        }
    }

    private func wrappers(for items: [CollectionViewDiffItem]) -> [CollectionViewDiffItemWrapper] {
        return items.map { item in
            CollectionViewDiffItemWrapper(item: item)
        }
    }
}
