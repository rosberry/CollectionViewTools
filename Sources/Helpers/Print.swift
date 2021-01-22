//
//  Copyright © 2018 Rosberry. All rights reserved.
//

import Foundation

internal func printWarning(_ message: String) {
    print("⚠️ [COLLECTION VIEW TOOLS] [WARNING] \(message)")
}

internal func printError(_ message: String) {
    print("❌ [COLLECTION VIEW TOOLS] [ERROR] \(message)")
}

internal func printContextWarning(_ message: String) {
    printWarning("\(message)\nBe sure to use methods for update section items and cell items context variables correctly")
}
