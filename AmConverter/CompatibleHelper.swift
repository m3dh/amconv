import UIKit

class CompatibleHelper {
    static func checkIfIsPhone5Dimension() -> Bool {
        return UIScreen.main.bounds.height <= 568
    }
}
