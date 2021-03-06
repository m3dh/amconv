import UIKit

class SharedUIHelper {
    private static var statusBar: UIView?

    static func getStatusBar() -> UIView {
        if SharedUIHelper.statusBar == nil {
            guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { fatalError("Unable to fetch status bar") }
            SharedUIHelper.statusBar = statusBar
        }

        return SharedUIHelper.statusBar!
    }
}

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

class AmButton: UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(colorImage, for: forState)
    }
}

class AmShadowButton: UIView {
    var button: AmButton?

    func getRealButton(_ radius: CGFloat) -> AmButton {
        if self.button == nil {
            let button = AmButton()

            button.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(button)
            button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            button.layer.cornerRadius = radius
            button.clipsToBounds = true
            button.adjustsImageWhenHighlighted = true

            self.layer.cornerRadius = radius
            self.layer.shadowColor = ConverterMainViewController.longNameButtonFontColor.cgColor
            self.layer.shadowRadius = 0.7
            self.layer.shadowOffset = CGSize(width: 0.3, height: 0.5)
            self.layer.shadowOpacity = 0.5
            self.clipsToBounds = false

            self.button = button
        }

        return self.button!
    }
}

class AmCardView: UIView {
    var subview: UIView?

    func getSubview(_ radius: CGFloat) -> UIView {
        if self.subview == nil {
            let subview = UIView()

            subview.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(subview)
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
            subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            subview.layer.cornerRadius = radius
            subview.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.shadowColor = UIColor.darkGray.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 1, height: 1)
            self.layer.shadowOpacity = 0.7
            self.clipsToBounds = false
            self.subview = subview

            return self.subview!
        } else {
            return self.subview!
        }
    }
}
