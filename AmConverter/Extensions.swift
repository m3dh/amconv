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

class AmCardView: UIView {
    var subview: UIView?

    func getSubview(_ radius: CGFloat) -> UIView {
        if self.subview == nil {
            let subview = UIView()

            subview.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(subview)
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            let leftConstraint = subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0)
            leftConstraint.isActive = true
            subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            subview.layer.cornerRadius = radius
            subview.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.shadowColor = UIColor.gray.cgColor
            self.layer.shadowRadius = 4
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.layer.shadowOpacity = 0.5
            self.clipsToBounds = false
            self.subview = subview

            return self.subview!
        } else {
            return self.subview!
        }
    }
}
