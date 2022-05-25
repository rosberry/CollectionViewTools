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
            sectionUpdates.append(update)
        }

        self.sectionUpdates = sectionUpdates
        self.cellUpdatesMap = cellUpdatesMap
        self.cellDeletesInsertsMovesMap = cellDeletesInsertsMovesMap

        hasSectionUpdates = sectionUpdates.count > 0
        hasCellUpdates = cellUpdatesMap.count > 0
        hasCellDeletesInsertsMoves = cellDeletesInsertsMovesMap.count > 0
    }

    static func diffResult(for sectionItems: [CollectionViewDiffSectionItem],
                           in manager: CollectionViewManager,
                           diff: CollectionViewDiffAdaptor,
                           async: Bool = false) -> CollectionViewDiffResult? {
        let sectionDiffs = diff.changes(old: wrappers(for: manager.diffSectionItems),
                                        new: wrappers(for: sectionItems))
        if sectionDiffs.isEmpty {
            return nil
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
        return result
    }

    private static func wrappers(for items: [DiffItem]) -> [DiffItemWrapper] {
        return items.map { item in
            DiffItemWrapper(item: item)
        }
    }
}
