import UIKit

class AmTextView: UITextView {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false
        } else if action == #selector(select(_:)) {
            return false
        } else if action == #selector(selectAll(_:)) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }
}


class AmTextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            return false
        } else if action == #selector(select(_:)) {
            return false
        } else if action == #selector(selectAll(_:)) {
            return false
        }

        return super.canPerformAction(action, withSender: sender)
    }
}
