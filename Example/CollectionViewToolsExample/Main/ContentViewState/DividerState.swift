//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

final class DividerState {

}

extension DividerState: GenericDiffItem {
    var diffIdentifier: String {
        "divider"
    }

    func isEqual(to item: DividerState) -> Bool {
        true
    }
}
