import UIKit

/* Project ToDo List:
 *  - Create the customized number pad.
 *  - Create the input boxes, and unit selections (slided windows)

 *  - Create number validator (show error on the other side)
 *  - Create ICON force touch short cuts.
 *  - Create short cuts below & history banner
 */

class ConverterMainViewController: UIViewController {
    enum InputMode {
        case left
        case right
    }

    static let numpadMaximumHeight: CGFloat = 240
    static let keptDigitNumbers = 5
    static let fontName: String = "KohinoorDevanagari-Medium"

    @IBOutlet weak var rootView: UIView!

    var leftInputTextView: UITextField!
    var leftShortNameLabel: UILabel!
    var leftLongNameButton: UIButton!
    var leftUnitConv: UnitBiConverter!
    var leftInputStr: String!

    var rightInputTextView: UITextField!
    var rightShortNameLabel: UILabel!
    var rightLongNameButton: UIButton!
    var rightUnitConv: UnitBiConverter!
    var rightInputStr: String!

    var predefinedCoversionSets: ShortcutSets!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: this shall be loaded from storage
        self.predefinedCoversionSets = ShortcutSets.usToInternational
        let prevLeftConv = UnitItems.fahrenheit
        let prevRightConv = UnitItems.celsius
        let prevLeftVal = Decimal(0)

        self.rootView.backgroundColor = UIColor.gray
        self.createMainViewSections(self.rootView)

        self.applyConverter(UnitConversionHelper.getUnitConverterByItem(prevLeftConv), .left)
        self.applyConverter(UnitConversionHelper.getUnitConverterByItem(prevRightConv), .right)

        self.applyInputNum(prevLeftVal, .left)
        self.getCalcResult(.left)
    }

    func applyInputNum(_ num: Decimal, _ inMode: InputMode) {
        var realNum = num
        if num.isNormal {
            realNum = ConverterMainViewController.getRoundedNumber(num)
        }

        if inMode == .left {
            if realNum.isFinite {
                self.leftInputStr = realNum.description
                self.leftInputTextView.text = self.leftInputStr
            } else {
                self.leftInputStr = ""
                self.leftInputTextView.text = "∞"
            }
        } else {
            if realNum.isFinite {
                self.rightInputStr = realNum.description
                self.rightInputTextView.text = self.rightInputStr
            } else {
                self.rightInputStr = ""
                self.rightInputTextView.text = "∞"
            }
        }
    }

    func applyNumpadInput(_ tag: Int, _ inMode: InputMode) {
        var originStr = self.leftInputStr!
        if inMode == .right {
            originStr = self.rightInputStr!
        }


        print("OG : \(originStr)")

        // Digits
        if tag >= 0 && tag <= 9 {
            if originStr == "0" || originStr == "" {
                originStr = String(tag)
            } else {
                originStr = (originStr + String(tag))
            }
        } else if tag == 11 {
            if !originStr.contains(".") {
                originStr = originStr + "."
            } else {
                // TODO: raise an error
            }
        } else if tag == 10 {
            if originStr.contains("-") {
                let afterRemoval = originStr.index(originStr.startIndex, offsetBy: 1)
                let newStr = originStr[afterRemoval...]
                originStr = String(newStr)
            } else {
                originStr = "-" + originStr
            }
        } else if tag == 13 {
            originStr = "0"
        }

        let field = self.getFistResponder()
        field.text = originStr
        if inMode == .right {
            self.rightInputStr = originStr
        } else {
            self.leftInputStr = originStr
        }
    }

    func applyConverter(_ converter: UnitBiConverter, _ inMode: InputMode) {
        if inMode == .left {
            self.leftUnitConv = converter
            self.leftShortNameLabel.text = UnitConversionHelper.getUnitItemShortName(self.leftUnitConv.unitItem)
            self.leftLongNameButton.setTitle(UnitConversionHelper.getUnitItemDisplayName(self.leftUnitConv.unitItem), for: .normal)
        } else {
            self.rightUnitConv = converter
            self.rightShortNameLabel.text = UnitConversionHelper.getUnitItemShortName(self.rightUnitConv.unitItem)
            self.rightLongNameButton.setTitle(UnitConversionHelper.getUnitItemDisplayName(self.rightUnitConv.unitItem), for: .normal)
        }
    }

    static func getRoundedNumber(_ num: Decimal) -> Decimal {
        let stringNumber = num.description
        if stringNumber.contains(".") {
            let dotIndex = stringNumber.distance(from: stringNumber.startIndex, to: stringNumber.index(of: ".")!)
            let roundIndex = dotIndex + ConverterMainViewController.keptDigitNumbers + 1
            if roundIndex < stringNumber.count {
                let ptr = UnsafeMutablePointer<Decimal>.allocate(capacity: 1)
                ptr[0] = num
                let uPtr = UnsafePointer<Decimal>.init(ptr)
                NSDecimalRound(ptr, uPtr, ConverterMainViewController.keptDigitNumbers, NSDecimalNumber.RoundingMode.bankers)
                let result = (ptr.pointee as NSDecimalNumber)
                return result.decimalValue
            }

        }
        return num
    }

    func getInputMode() -> InputMode {
        if self.leftInputTextView.isFirstResponder {
            return .left
        } else if self.rightInputTextView.isFirstResponder {
            return .right
        } else {
            fatalError("Unexpected input mode!")
        }
    }

    func getFistResponder() -> UITextField {
        if self.getInputMode() == .left {
            return self.leftInputTextView
        } else {
            return self.rightInputTextView
        }
    }

    func getCalcResult(_ from: InputMode) {
        if from == .left {
            var leftVal = self.leftInputStr!
            if leftVal == "" || leftVal == "-" {
                leftVal = "0"
            }

            leftVal = leftVal.trimmingCharacters(in:  CharacterSet.init(charactersIn: "."))
            let leftDecimal = Decimal(string: leftVal)!
            let stdVal = self.leftUnitConv.toStdValue(leftDecimal)
            print("LEFT STD: \(stdVal.description)")
            let rightDecimal = self.rightUnitConv.fromStdValue(stdVal)
            self.applyInputNum(rightDecimal, .right)
        } else {
            var rightVal = self.rightInputStr!
            if rightVal == "" || rightVal == "-" {
                rightVal = "0"
            }

            let rightDecimal = Decimal(string: rightVal)!
            let leftDecimal = self.leftUnitConv.fromStdValue(self.rightUnitConv.toStdValue(rightDecimal))
            self.applyInputNum(leftDecimal, .left)
        }
    }

    func createMainViewSections(_ rootView: UIView) {
        /* 37% ~ 17% ~ 46% */
        let queryLogView = UIView()
        queryLogView.backgroundColor = UIColor.yellow
        rootView.addSubview(queryLogView)
        queryLogView.translatesAutoresizingMaskIntoConstraints = false
        queryLogView.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        queryLogView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        queryLogView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        queryLogView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: 0.37).isActive = true

        let inputOutputView = UIView()
        inputOutputView.backgroundColor = UIColor.red
        rootView.addSubview(inputOutputView)
        inputOutputView.translatesAutoresizingMaskIntoConstraints = false
        inputOutputView.topAnchor.constraint(equalTo: queryLogView.bottomAnchor).isActive = true
        inputOutputView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        inputOutputView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        inputOutputView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: 0.17).isActive = true
        self.createInputOutputSubviews(inputOutputView)

        let shortcutsView = UIView()
        shortcutsView.backgroundColor = UIColor.gray
        rootView.addSubview(shortcutsView)
        shortcutsView.translatesAutoresizingMaskIntoConstraints = false
        shortcutsView.topAnchor.constraint(equalTo: inputOutputView.bottomAnchor).isActive = true
        shortcutsView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        shortcutsView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        shortcutsView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: 0.46).isActive = true
        self.createShortcutSubviews(shortcutsView)
    }

    func createShortcutSubviews(_ shortcutsView: UIView) {
        let buttonHeightFullRatio :CGFloat = 0.16

        let shortcuts = ShortcutHelper.getDefinedShortcuts(self.predefinedCoversionSets)
        let rootStackView = UIStackView()
        shortcutsView.addSubview(rootStackView)
        rootStackView.axis = .horizontal
        rootStackView.spacing = 2
        rootStackView.distribution = .fillEqually
        rootStackView.alignment = .top
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.leftAnchor.constraint(equalTo: shortcutsView.leftAnchor, constant: 4).isActive = true
        rootStackView.topAnchor.constraint(equalTo: shortcutsView.topAnchor, constant: 20).isActive = true
        rootStackView.rightAnchor.constraint(equalTo: shortcutsView.rightAnchor, constant: -4).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: shortcutsView.bottomAnchor, constant: -3).isActive = true

        let stackViews = [UIStackView(), UIStackView(), UIStackView(), UIStackView()]
        for (stackIndex, stackView) in stackViews.enumerated() {
            rootStackView.addArrangedSubview(stackView)
            stackView.axis = .vertical
            stackView.spacing = 2
            for (scIndex, shortcut) in shortcuts.enumerated() {
                if scIndex % stackViews.count == stackIndex {
                    let scButton = UIButton()
                    stackView.addArrangedSubview(scButton)
                    scButton.setTitle("\(shortcut.displayName)", for: .normal)
                    scButton.titleLabel!.font = UIFont(name: ConverterMainViewController.fontName, size: 15)
                    scButton.backgroundColor = .black
                    scButton.heightAnchor.constraint(equalTo: rootStackView.heightAnchor, multiplier: buttonHeightFullRatio).isActive = true
                    scButton.tag = scIndex
                    scButton.addTarget(self, action: #selector(shortcutButtonTouchUpInside(_:)), for: UIControlEvents.touchUpInside)
                }
            }
        }
    }

    func createInputOutputSubviews(_ inputOutputView: UIView) {
        let textViewWidthRatio: CGFloat = 0.465
        let textViewHeightRatio: CGFloat = 0.60
        let shortUnitNameLabelHeight: CGFloat = 16 // Fiting Helvetica, size 10

        // left hand side
        let leftContainerView = UIView()
        leftContainerView.backgroundColor = UIColor.lightGray
        inputOutputView.addSubview(leftContainerView)
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        leftContainerView.topAnchor.constraint(equalTo: inputOutputView.topAnchor, constant: 2).isActive = true
        leftContainerView.leftAnchor.constraint(equalTo: inputOutputView.leftAnchor, constant: 2).isActive = true
        leftContainerView.widthAnchor.constraint(equalTo: inputOutputView.widthAnchor, multiplier: textViewWidthRatio).isActive = true
        leftContainerView.heightAnchor.constraint(equalTo: inputOutputView.heightAnchor, multiplier: textViewHeightRatio).isActive = true

        let leftInputTextView = AmTextField()
        leftInputTextView.tintColor = .clear
        leftInputTextView.font = UIFont(name: ConverterMainViewController.fontName, size: 20)
        leftInputTextView.backgroundColor = UIColor.white
        leftContainerView.addSubview(leftInputTextView)
        leftInputTextView.translatesAutoresizingMaskIntoConstraints = false
        leftInputTextView.leftAnchor.constraint(equalTo: leftContainerView.leftAnchor, constant: 2).isActive = true
        leftInputTextView.rightAnchor.constraint(equalTo: leftContainerView.rightAnchor, constant: -2).isActive = true
        leftInputTextView.topAnchor.constraint(equalTo: leftContainerView.topAnchor).isActive = true
        leftInputTextView.heightAnchor.constraint(equalTo: leftContainerView.heightAnchor, multiplier: 1, constant: -shortUnitNameLabelHeight).isActive = true

        let leftShortNameField = UILabel()
        leftContainerView.addSubview(leftShortNameField)
        leftShortNameField.translatesAutoresizingMaskIntoConstraints = false
        leftShortNameField.text = ""
        leftShortNameField.textAlignment = .right
        leftShortNameField.font = UIFont(name: ConverterMainViewController.fontName, size: 11)
        leftShortNameField.textColor = .green
        leftShortNameField.backgroundColor = .white
        leftShortNameField.topAnchor.constraint(equalTo: leftInputTextView.bottomAnchor).isActive = true
        leftShortNameField.rightAnchor.constraint(equalTo: leftContainerView.rightAnchor, constant: -5).isActive = true
        leftShortNameField.bottomAnchor.constraint(equalTo: leftContainerView.bottomAnchor, constant: -2).isActive = true

        let leftLongNameButton = UIButton()
        leftLongNameButton.setTitle("", for: .normal)
        leftLongNameButton.titleLabel!.font = UIFont(name: ConverterMainViewController.fontName, size: 13)
        leftLongNameButton.translatesAutoresizingMaskIntoConstraints = false
        leftLongNameButton.backgroundColor = .blue
        inputOutputView.addSubview(leftLongNameButton)
        leftLongNameButton.leftAnchor.constraint(equalTo: inputOutputView.leftAnchor, constant: 2).isActive = true
        leftLongNameButton.widthAnchor.constraint(equalTo: leftContainerView.widthAnchor, multiplier: 1).isActive = true
        leftLongNameButton.topAnchor.constraint(equalTo: leftContainerView.bottomAnchor, constant: 2).isActive = true
        leftLongNameButton.bottomAnchor.constraint(equalTo: inputOutputView.bottomAnchor, constant: -2).isActive = true

        // right hand side
        let rightContainerView = UIView()
        rightContainerView.backgroundColor = UIColor.lightGray
        inputOutputView.addSubview(rightContainerView)
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        rightContainerView.topAnchor.constraint(equalTo: inputOutputView.topAnchor, constant: 2).isActive = true
        rightContainerView.rightAnchor.constraint(equalTo: inputOutputView.rightAnchor, constant: -2).isActive = true
        rightContainerView.widthAnchor.constraint(equalTo: inputOutputView.widthAnchor, multiplier: textViewWidthRatio).isActive = true
        rightContainerView.heightAnchor.constraint(equalTo: inputOutputView.heightAnchor, multiplier: textViewHeightRatio).isActive = true

        let rightInputTextView = AmTextField()
        rightInputTextView.tintColor = .clear
        rightInputTextView.font = UIFont(name: ConverterMainViewController.fontName, size: 20)
        rightInputTextView.backgroundColor = UIColor.white
        rightContainerView.addSubview(rightInputTextView)
        rightInputTextView.translatesAutoresizingMaskIntoConstraints = false
        rightInputTextView.leftAnchor.constraint(equalTo: rightContainerView.leftAnchor, constant: 2).isActive = true
        rightInputTextView.rightAnchor.constraint(equalTo: rightContainerView.rightAnchor, constant: -2).isActive = true
        rightInputTextView.topAnchor.constraint(equalTo: rightContainerView.topAnchor).isActive = true
        rightInputTextView.heightAnchor.constraint(equalTo: leftContainerView.heightAnchor, multiplier: 1, constant: -shortUnitNameLabelHeight).isActive = true

        let rightShortNameField = UILabel()
        rightContainerView.addSubview(rightShortNameField)
        rightShortNameField.translatesAutoresizingMaskIntoConstraints = false
        rightShortNameField.text = ""
        rightShortNameField.textAlignment = .right
        rightShortNameField.font = UIFont(name: ConverterMainViewController.fontName, size: 11)
        rightShortNameField.textColor = .green
        rightShortNameField.backgroundColor = .white
        rightShortNameField.topAnchor.constraint(equalTo: rightInputTextView.bottomAnchor).isActive = true
        rightShortNameField.rightAnchor.constraint(equalTo: rightContainerView.rightAnchor, constant: -5).isActive = true
        rightShortNameField.bottomAnchor.constraint(equalTo: rightContainerView.bottomAnchor, constant: -2).isActive = true

        let rightLongNameButton = UIButton()
        rightLongNameButton.setTitle("", for: .normal)
        rightLongNameButton.titleLabel!.font = UIFont(name: ConverterMainViewController.fontName, size: 13)
        rightLongNameButton.translatesAutoresizingMaskIntoConstraints = false
        rightLongNameButton.backgroundColor = .blue
        inputOutputView.addSubview(rightLongNameButton)
        rightLongNameButton.rightAnchor.constraint(equalTo: inputOutputView.rightAnchor, constant: -2).isActive = true
        rightLongNameButton.widthAnchor.constraint(equalTo: rightContainerView.widthAnchor, multiplier: 1).isActive = true
        rightLongNameButton.topAnchor.constraint(equalTo: rightContainerView.bottomAnchor, constant: 2).isActive = true
        rightLongNameButton.bottomAnchor.constraint(equalTo: inputOutputView.bottomAnchor, constant: -2).isActive = true

        // the equal sign
        let equalLabel = UILabel()
        equalLabel.textAlignment = .center
        equalLabel.text = "="
        inputOutputView.addSubview(equalLabel)
        equalLabel.translatesAutoresizingMaskIntoConstraints = false
        equalLabel.topAnchor.constraint(equalTo: inputOutputView.topAnchor).isActive = true
        equalLabel.bottomAnchor.constraint(equalTo: inputOutputView.bottomAnchor).isActive = true
        equalLabel.leftAnchor.constraint(equalTo: leftContainerView.rightAnchor, constant: 2).isActive = true
        equalLabel.rightAnchor.constraint(equalTo: rightContainerView.leftAnchor, constant: -2).isActive = true
        equalLabel.font = UIFont(name: ConverterMainViewController.fontName, size: 18)

        let numpadView = self.createNumpadView()
        leftInputTextView.inputView = numpadView
        rightInputTextView.inputView = numpadView

        self.leftInputTextView = leftInputTextView
        self.leftLongNameButton = leftLongNameButton
        self.leftShortNameLabel = leftShortNameField

        self.rightInputTextView = rightInputTextView
        self.rightLongNameButton = rightLongNameButton
        self.rightShortNameLabel = rightShortNameField
    }

    func createNumpadView() -> UIView {
        let numpadRootView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: ConverterMainViewController.numpadMaximumHeight))
        let numpadButtons = self.createNumpadButtons()
        self.fillNumpadStackView(numpadRootView, numpadButtons)
        return numpadRootView
    }

    func createNumpadButtons() -> [UIButton] {
        let num0Button = UIButton()
        num0Button.setTitle("0", for: .normal)
        num0Button.backgroundColor = .red
        num0Button.tag = 0

        let num1Button = UIButton()
        num1Button.setTitle("1", for: .normal)
        num1Button.backgroundColor = .red
        num1Button.tag = 1

        let num2Button = UIButton()
        num2Button.setTitle("2", for: .normal)
        num2Button.backgroundColor = .red
        num2Button.tag = 2

        let num3Button = UIButton()
        num3Button.setTitle("3", for: .normal)
        num3Button.backgroundColor = .red
        num3Button.tag = 3

        let num4Button = UIButton()
        num4Button.setTitle("4", for: .normal)
        num4Button.backgroundColor = .red
        num4Button.tag = 4

        let num5Button = UIButton()
        num5Button.setTitle("5", for: .normal)
        num5Button.backgroundColor = .red
        num5Button.tag = 5

        let num6Button = UIButton()
        num6Button.setTitle("6", for: .normal)
        num6Button.backgroundColor = .red
        num6Button.tag = 6

        let num7Button = UIButton()
        num7Button.setTitle("7", for: .normal)
        num7Button.backgroundColor = .red
        num7Button.tag = 7

        let num8Button = UIButton()
        num8Button.setTitle("8", for: .normal)
        num8Button.backgroundColor = .red
        num8Button.tag = 8

        let num9Button = UIButton()
        num9Button.setTitle("9", for: .normal)
        num9Button.backgroundColor = .red
        num9Button.tag = 9
        
        let dismissKeyboard = UIButton()
        dismissKeyboard.setTitle("+/-", for: .normal)
        dismissKeyboard.backgroundColor = .blue
        dismissKeyboard.tag = 10

        let numDotButton = UIButton()
        numDotButton.setTitle(".", for: .normal)
        numDotButton.backgroundColor = .blue
        numDotButton.tag = 11

        let backspaceButton = UIButton()
        backspaceButton.setTitle("⎋", for: .normal)
        backspaceButton.backgroundColor = .blue
        backspaceButton.tag = 12

        let clearButton = UIButton()
        clearButton.setTitle("C", for: .normal)
        clearButton.backgroundColor = .blue
        clearButton.tag = 13

        let copyButton = UIButton()
        copyButton.setTitle("✄", for: .normal)
        copyButton.backgroundColor = .blue
        copyButton.tag = 14

        let enterButton = UIButton()
        enterButton.setTitle("⏎", for: .normal)
        enterButton.backgroundColor = .black
        enterButton.tag = 15

        let ret = [
            num1Button,
            num4Button,
            num7Button,
            dismissKeyboard,

            num2Button,
            num5Button,
            num8Button,
            num0Button,

            num3Button,
            num6Button,
            num9Button,
            numDotButton,

            backspaceButton,
            clearButton,
            copyButton,
            enterButton
        ]

        for button in ret {
            button.titleLabel!.font = UIFont(name: ConverterMainViewController.fontName, size: 20)
            button.addTarget(self, action: #selector(numpadButtonTouchUpInside), for: UIControlEvents.touchUpInside)
        }

        return ret
    }

    func fillNumpadStackView(_ numpadView: UIView, _ buttons: [UIButton]) {
        let numpadStackView = UIStackView()
        numpadStackView.axis = .horizontal
        numpadStackView.spacing = 5
        numpadStackView.distribution = .fillEqually
        numpadView.addSubview(numpadStackView)
        numpadStackView.translatesAutoresizingMaskIntoConstraints = false
        numpadStackView.topAnchor.constraint(equalTo: numpadView.topAnchor, constant: 5).isActive = true
        numpadStackView.bottomAnchor.constraint(equalTo: numpadView.bottomAnchor, constant: -5).isActive = true
        numpadStackView.leftAnchor.constraint(equalTo: numpadView.leftAnchor, constant: 5).isActive = true
        numpadStackView.rightAnchor.constraint(equalTo: numpadView.rightAnchor, constant: -5).isActive = true

        for colIdx in 0...3 {
            let columnView = UIStackView()
            columnView.axis = .vertical
            columnView.spacing = 5
            columnView.distribution = .fillEqually
            numpadStackView.addArrangedSubview(columnView)
            for rowIdx in 0...3 {
                let buttonIndex = colIdx * 4 + rowIdx
                if buttons.count > buttonIndex {
                    let button = buttons[buttonIndex]
                    columnView.addArrangedSubview(button)
                }
            }
        }
    }

    @objc func shortcutButtonTouchUpInside(_ sender: UIButton) {
        let shortcut = ShortcutHelper.getDefinedShortcut(self.predefinedCoversionSets, sender.tag)
        self.applyConverter(UnitConversionHelper.getUnitConverterByItem(shortcut.leftItem), .left)
        self.applyConverter(UnitConversionHelper.getUnitConverterByItem(shortcut.rightItem), .right)
        self.getCalcResult(.left)
    }

    @objc func numpadButtonTouchUpInside(_ sender: UIButton) {
        let inputMode = self.getInputMode()
        if sender.tag >= 0 && sender.tag <= 11 {
            self.applyNumpadInput(sender.tag, inputMode)
        } else if sender.tag == 13 {
            self.applyNumpadInput(sender.tag, inputMode)
        } else if sender.tag == 12 {
            let responder = self.getFistResponder()
            responder.resignFirstResponder()
        } else if sender.tag == 15 {
            self.getCalcResult(inputMode)
        }
    }
}

