//
//  Copyright © 2017 Rosberry. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        #if DIFF
        window?.rootViewController = UINavigationController(rootViewController: DiffViewController())
        #elseif FACTORIES
        window?.rootViewController = UINavigationController(rootViewController: FactoriesViewController())
        #else
        window?.rootViewController = UINavigationController(rootViewController: MainViewController())
        #endif
        window?.makeKeyAndVisible()
        return true
    }
}
