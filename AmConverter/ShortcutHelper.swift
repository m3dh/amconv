import Foundation

enum ShortcutSets {
    case usToInternational
}

class ShortcutItem {
    var shortcutSet: ShortcutSets
    var displayName: String
    var leftItem: UnitItems
    var rightItem: UnitItems

    init(
        _ set: ShortcutSets,
        _ name: String,
        _ left: UnitItems,
        _ right: UnitItems) {
        self.shortcutSet = set
        self.displayName = name
        self.leftItem = left
        self.rightItem = right
    }
}

class ShortcutHelper {
    private static let definedShortcuts: [ShortcutItem] = [
        // U.S. units to international
        ShortcutItem(ShortcutSets.usToInternational, "mpg", UnitItems.usMilesPerGallon, UnitItems.litersPer100Kilometres),
        ShortcutItem(ShortcutSets.usToInternational, "°F", UnitItems.fahrenheit, UnitItems.celsius)
    ]

    static func getDefinedShortcut(_ sets: ShortcutSets, _ index: Int) -> ShortcutItem {
        var idx = 0
        for shortcut in ShortcutHelper.definedShortcuts {
            if shortcut.shortcutSet == sets {
                if idx == index {
                    return shortcut
                }

                idx += 1
            }
        }

        fatalError("Unable to find shortcut indexes \(index)")
    }

    static func getDefinedShortcuts(_ sets: ShortcutSets) -> [ShortcutItem] {
        var ret: [ShortcutItem] = []
        for shortcut in ShortcutHelper.definedShortcuts {
            if shortcut.shortcutSet == sets {
                ret.append(shortcut)
            }
        }

        return ret
    }
}
