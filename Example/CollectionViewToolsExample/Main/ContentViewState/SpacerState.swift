//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

final class SpacerState {

}

extension SpacerState: GenericDiffItem {
    var diffIdentifier: String {
        "spacer"
    }

    func isEqual(to item: SpacerState) -> Bool {
        true
    }
}
