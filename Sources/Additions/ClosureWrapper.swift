//
//  Copyright © 2016 Rosberry. All rights reserved.
//

import Foundation

final class ClosureWrapper<HandlerType> {
    private var handler: HandlerType?

    init(_ handler: HandlerType?) {
        self.handler = handler
    }

    static func handler(for object: Any, key: UnsafeRawPointer!) -> HandlerType? {
        if let wrapper = objc_getAssociatedObject(object, key) as? ClosureWrapper<HandlerType> {
            return wrapper.handler
        }
        return nil
    }

    static func setHandler(_ handler: HandlerType?, for object: Any, key: UnsafeRawPointer!) {
        objc_setAssociatedObject(object, key, ClosureWrapper(handler), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
