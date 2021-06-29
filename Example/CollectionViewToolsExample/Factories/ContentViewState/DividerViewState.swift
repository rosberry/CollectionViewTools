//
//  Copyright © 2020 Rosberry. All rights reserved.
//

import CollectionViewTools

final class SpacerState: ViewState {
    convenience init(content: Content) {
        self.init(id: content.id)
    }
}

extension SpacerState: DiffCompatible {
    
    var diffIdentifier: String {
        "\(id)"
    }

    func makeDiffComparator() -> Bool {
        true
    }
}
