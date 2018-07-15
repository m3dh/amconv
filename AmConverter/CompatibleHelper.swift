import UIKit

class CompatibleHelper {
    static func checkIfIsPhone5sDimension() -> Bool {
        return UIScreen.main.bounds.height <= 568
    }
}
