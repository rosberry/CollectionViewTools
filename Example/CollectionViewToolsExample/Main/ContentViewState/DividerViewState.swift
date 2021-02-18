//
//  Copyright © 2020 Rosberry. All rights reserved.
//

final class SpacerState: ViewState {
    convenience init(content: Content) {
        self.init(id: content.id)
    }
}

extension SpacerState: Equatable {
    static func == (lhs: SpacerState, rhs: SpacerState) -> Bool {
        true
    }
}
