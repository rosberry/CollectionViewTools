//
//  Copyright © 2020 Rosberry. All rights reserved.
//

final class DividerViewState: ViewState {
    convenience init(content: Content) {
        self.init(id: content.id)
    }
}

extension DividerViewState: Equatable {
    static func == (lhs: DividerViewState, rhs: DividerViewState) -> Bool {
        true
    }
}
