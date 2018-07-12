import UIKit

class ShortcutsHelper {
    class InnerConversionType {
        var from: UnitItems
        var to: UnitItems

        init(_ from: UnitItems, _ to: UnitItems) {
            self.from = from
            self.to = to
        }
    }

    static let shortcutsCount = 4
    static var existConversions: [InnerConversionType] = []
    static var initialized = false
    static var hasChanged = false
    static var handledShortcut: InnerConversionType? = nil

    enum ShortcutUserInfoKey: String {
        case fromUnit
        case toUnit
    }

    enum ShortcutItemActionType: String {
        case convert
    }

    static func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) {
        let (from, to) = readConversion(shortcutItem)
        handledShortcut = InnerConversionType(from, to)
    }

    static func appendShortcutItem(_ application: UIApplication?, _ from: UnitItems, _ to: UnitItems) {
        // Try initialize for exists shortcuts.
        let unApplication: UIApplication = application ?? UIApplication.shared
        ShortcutsHelper.initialize(unApplication)

        // Load into application list.
        if let match = existConversions.first(where: {t in t.from == from || t.to == to}) {
            hasChanged = true
            match.from = from
            match.to = to
        } else {
            hasChanged = true
            existConversions.insert(ShortcutsHelper.InnerConversionType(from, to), at: 0)
            if existConversions.count > shortcutsCount {
                existConversions.removeLast()
            }
        }
    }

    static func getHandledShortcutItem() -> (UnitItems, UnitItems)? {
        if let handled = handledShortcut {
            handledShortcut = nil // Clean handled shortcut!
            return (handled.from, handled.to)
        } else {
            return nil
        }
    }

    static func saveData(_ application: UIApplication?) {
        if hasChanged {
            let unApplication: UIApplication = application ?? UIApplication.shared
            unApplication.shortcutItems = existConversions.map({c in
                let userInfo = [
                    ShortcutUserInfoKey.fromUnit.rawValue: c.from.rawValue,
                    ShortcutUserInfoKey.toUnit.rawValue: c.to.rawValue
                ]

                let title = "\(UnitConversionHelper.getUnitItemShortName(c.from)) → \(UnitConversionHelper.getUnitItemShortName(c.to))"

                return UIMutableApplicationShortcutItem(
                    type: Bundle.main.bundleIdentifier! + ".\(ShortcutItemActionType.convert.rawValue)",
                    localizedTitle: title,
                    localizedSubtitle: nil,
                    icon: UIApplicationShortcutIcon(type: .play),
                    userInfo: userInfo)
            })

            hasChanged = false
        }
    }

    private static func readConversion(_ shortcut: UIApplicationShortcutItem) -> (UnitItems, UnitItems) {
        let from = UnitItems.init(rawValue: shortcut.userInfo![ShortcutUserInfoKey.fromUnit.rawValue] as! Int)!
        let to = UnitItems.init(rawValue: shortcut.userInfo![ShortcutUserInfoKey.toUnit.rawValue] as! Int)!
        return (from, to)
    }

    private static func initialize(_ application: UIApplication) {
        if !initialized {
            initialized = true
            if let shortcuts = application.shortcutItems {
                for shortcut in shortcuts {
                    let type = shortcut.type.components(separatedBy: ".").last
                    if type == ShortcutItemActionType.convert.rawValue {
                        let (from, to) = readConversion(shortcut)
                        existConversions.append(ShortcutsHelper.InnerConversionType(from, to))
                    }
                }
            }
        }
    }
}
