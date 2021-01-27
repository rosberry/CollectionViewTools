//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

final class DividerState: CanBeDiff {

    var id: Int

    init(id: Int) {
        self.id = id
    }

    var debugDescription: String {
        "\(id)"
    }

    static func == (lhs: DividerState, rhs: DividerState) -> Bool {
        true
    }
}
