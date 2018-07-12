import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return false }
        statusBar.backgroundColor = ConverterMainViewController.xBarBackgroundColor

        if let shortcutItem = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            ShortcutsHelper.handleShortcutItem(shortcutItem)
            return false
        }

        if let shortcutItems = application.shortcutItems, shortcutItems.isEmpty {
            // install initial versions of our dynamic shortcuts.
            ShortcutsHelper.appendShortcutItem(application, UnitItems.gallon, UnitItems.liter)
            ShortcutsHelper.appendShortcutItem(application, UnitItems.ounceMass, UnitItems.pound)
        }

        return true
    }

    func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void) {
        ShortcutsHelper.handleShortcutItem(shortcutItem)
        if let controller = window?.rootViewController as? ConverterMainViewController {
            if let shortcutPair = ShortcutsHelper.getHandledShortcutItem() {
                let (from, to) = shortcutPair
                controller.applyFromShortcut(from, to)
            }
        }

        completionHandler(true)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveData(application)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        saveData(application)
    }

    func saveData(_ application: UIApplication) {
        NSLog("Saving data")
        ShortcutsHelper.saveData(application)
        ConverterMainViewController.queryLogViewDataSource.saveData()
    }
}
