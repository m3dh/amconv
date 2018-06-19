import UIKit

/* Project ToDo List:
 *  - Create the customized number pad.
 *  - Create the input boxes, and unit selections (slided windows)

 *  - Create number validator (show error on the other side)
 *  - Create ICON force touch short cuts.
 *  - Create short cuts below & history banner
 */

class ConverterMainViewController: UIViewController {
    class InputTextFieldDelegate: NSObject, UITextFieldDelegate {
        func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.textColor = ConverterMainViewController.inputFieldActivateFontColor
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            textField.textColor = ConverterMainViewController.inputFieldInactiveFontColor
        }
    }

    enum InputMode {
        case upper
        case lower
    }

    static let rootSubViewDistance: CGFloat = 5

    static let keptDigitNumbers = 5
    static let fontName: String = "KohinoorBangla-Regular" // "KohinoorDevanagari-Light"
    static let introFontName: String = "AmericanTypewriter"

    static let containerBackgroundColor: UIColor = UIColor(red: 241.0 / 255, green: 244.0 / 255, blue: 244.0 / 255, alpha: 1)
    static let basicBackgroundColor: UIColor = UIColor(red: 251.0 / 255, green: 251.0 / 255, blue: 251.0 / 255, alpha: 1)
    static let secondBackgroundColor: UIColor = UIColor(red: 235.0 / 255, green: 235.0 / 255, blue: 235.0 / 255, alpha: 1)
    static let xBarBackgroundColor: UIColor = UIColor(red: 50.0 / 255, green: 86.0 / 255, blue: 137.0 / 255, alpha: 1)

    static let shortNameFontColor: UIColor = UIColor(red: 194.0 / 255, green: 202.0 / 255, blue: 209.0 / 255, alpha: 1)
    static let inputFieldActivateFontColor: UIColor = UIColor(red: 119.0 / 255, green: 232.0 / 255, blue: 157.0 / 255, alpha: 1)
    static let inputFieldInactiveFontColor: UIColor = UIColor(red: 195.0 / 255, green: 201.0 / 255, blue: 210.0 / 255, alpha: 1)

    static let longNameButtonBackColor: UIColor = UIColor(red: 221.0 / 255, green: 245.0 / 255, blue: 254.0 / 255, alpha: 1)
    static let longNameButtonFontColor: UIColor = UIColor(red: 66.0 / 255, green: 88.0 / 255, blue: 112.0 / 255, alpha: 1)

    static let mainStreamFontColor: UIColor = UIColor(red: 31.0 / 255, green: 50.0 / 255, blue: 80.0 / 255, alpha: 1)

    static let keyboardOnTouchColor: UIColor = UIColor(red: 246.0 / 255, green: 220.0 / 255, blue: 126.0 / 255, alpha: 1)

    @IBOutlet weak var rootView: UIView!

    var upperInputTextField: UITextField!
    var upperShortNameLabel: UILabel!
    var upperLongNameButton: AmShadowButton!
    var upperUnitBiConverter: UnitBiConverter!
    var upperInputTempString: String!

    var lowerInputTextField: UITextField!
    var lowerShortNameLabel: UILabel!
    var lowerLongNameButton: AmShadowButton!
    var lowerUnitBiConverter: UnitBiConverter!
    var lowerInputTempString: String!

    var leftColorBarView: UIView!

    var predefinedCoversionSets: ShortcutSets!

    var inputViewFontSize = 34
    var longNameButtonHeight = 26

    var inputTextFieldDelegate = InputTextFieldDelegate()
    var queryLogViewDataSource = QueryLogViewDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        if UIScreen.main.bounds.height <= 568 {
            // is iPhone SE
            self.inputViewFontSize = 24
        }

        // TODO: this shall be loaded from storage
        self.predefinedCoversionSets = ShortcutSets.usToInternational
        let previousUpperUnit = UnitItems.fahrenheit
        let previousLowerUnit = UnitItems.celsius
        let previousUpperValue = Decimal(0)

        self.rootView.backgroundColor = UIColor.gray
        self.createMainViewSections(self.rootView, UIScreen.main.bounds.height - UIApplication.shared.statusBarFrame.height)

        self.applyConverter(UnitConversionHelper.getUnitConverterByItem(previousUpperUnit), .upper)
        self.applyConverter(UnitConversionHelper.getUnitConverterByItem(previousLowerUnit), .lower)

        self.applyInputNum(previousUpperValue, .upper)
        self.getCalcResult(.upper)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }

    func applyInputNum(_ num: Decimal, _ inMode: InputMode) {
        var realNum = num
        if num.isNormal {
            realNum = ConverterMainViewController.getRoundedNumber(num)
        }

        if inMode == .upper {
            if realNum.isFinite {
                self.upperInputTempString = realNum.description
                self.upperInputTextField.text = self.upperInputTempString
            } else {
                self.upperInputTempString = ""
                self.upperInputTextField.text = "∞"
            }
        } else {
            if realNum.isFinite {
                self.lowerInputTempString = realNum.description
                self.lowerInputTextField.text = self.lowerInputTempString
            } else {
                self.lowerInputTempString = ""
                self.lowerInputTextField.text = "∞"
            }
        }
    }

    func applyNumpadInput(_ tag: Int, _ inMode: InputMode) {
        var originStr = self.upperInputTempString!
        if inMode == .lower {
            originStr = self.lowerInputTempString!
        }

        // Digits
        if tag >= 0 && tag <= 9 {
            if originStr == "0" || originStr == "" {
                originStr = String(tag)
            } else if originStr == "-0" {
                originStr = "-" + String(tag)
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
                var newStr = originStr[afterRemoval...]
                if newStr.count == 0 {
                    newStr = "0"
                }

                originStr = String(newStr)
            } else {
                if originStr.count == 0 {
                    originStr = "0"
                }
                originStr = "-" + originStr
            }
        } else if tag == 13 {
            originStr = "0"
        }

        let field = self.getFistResponder()
        field.text = originStr
        if inMode == .lower {
            self.lowerInputTempString = originStr
        } else {
            self.upperInputTempString = originStr
        }
    }

    func applyConverter(_ converter: UnitBiConverter, _ inMode: InputMode) {
        if inMode == .upper {
            self.upperUnitBiConverter = converter
            self.upperShortNameLabel.text = UnitConversionHelper.getUnitItemShortName(self.upperUnitBiConverter.unitItem)
            self.upperLongNameButton.button!.setTitle(" " + UnitConversionHelper.getUnitItemDisplayName(self.upperUnitBiConverter.unitItem) + " ", for: .normal)
        } else {
            self.lowerUnitBiConverter = converter
            self.lowerShortNameLabel.text = UnitConversionHelper.getUnitItemShortName(self.lowerUnitBiConverter.unitItem)
            self.lowerLongNameButton.button!.setTitle(" " + UnitConversionHelper.getUnitItemDisplayName(self.lowerUnitBiConverter.unitItem) + " ", for: .normal)
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
        if self.upperInputTextField.isFirstResponder {
            return .upper
        } else if self.lowerInputTextField.isFirstResponder {
            return .lower
        } else {
            fatalError("Unexpected input mode!")
        }
    }

    func getFistResponder() -> UITextField {
        if self.getInputMode() == .upper {
            return self.upperInputTextField
        } else {
            return self.lowerInputTextField
        }
    }

    func getCalcResult(_ from: InputMode) {
        if from == .upper {
            var upperStr = self.upperInputTempString!
            if upperStr == "" || upperStr == "-" {
                upperStr = "0"
            }

            upperStr = upperStr.trimmingCharacters(in:  CharacterSet.init(charactersIn: "."))
            let upperDecimal = Decimal(string: upperStr)!
            let stdVal = self.upperUnitBiConverter.toStdValue(upperDecimal)
            let lowerDecimal = self.lowerUnitBiConverter.fromStdValue(stdVal)
            self.applyInputNum(lowerDecimal, .lower)
            self.queryLogViewDataSource.appendLogItem(QueryLogItem(upperStr, self.lowerInputTempString!, self.upperUnitBiConverter.unitItem, self.lowerUnitBiConverter.unitItem))
        } else {
            var lowerStr = self.lowerInputTempString!
            if lowerStr == "" || lowerStr == "-" {
                lowerStr = "0"
            }

            let lowerDecimal = Decimal(string: lowerStr)!
            let upperDecimal = self.upperUnitBiConverter.fromStdValue(self.lowerUnitBiConverter.toStdValue(lowerDecimal))
            self.applyInputNum(upperDecimal, .upper)
            self.queryLogViewDataSource.appendLogItem(QueryLogItem(lowerStr, self.upperInputTempString!, self.lowerUnitBiConverter.unitItem, self.upperUnitBiConverter.unitItem))
        }
    }

    func createMainViewSections(_ rootView: UIView, _ fullViewHeight: CGFloat) {
        let xBarViewHeight: CGFloat = 0.06
        let logViewHeight: CGFloat = 0.18
        let inOutViewHeight: CGFloat = 0.28

        rootView.backgroundColor = ConverterMainViewController.secondBackgroundColor

        let xBarView = UIView()
        rootView.addSubview(xBarView)
        xBarView.backgroundColor = ConverterMainViewController.xBarBackgroundColor
        xBarView.translatesAutoresizingMaskIntoConstraints = false
        xBarView.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        xBarView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        xBarView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        xBarView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: xBarViewHeight).isActive = true
        let xBarTitle = UILabel()
        xBarView.addSubview(xBarTitle)
        xBarTitle.translatesAutoresizingMaskIntoConstraints = false
        xBarTitle.font = UIFont(name: ConverterMainViewController.fontName, size: 18)
        xBarTitle.textAlignment = .center
        xBarTitle.text = "Yet Another Unit Converter"
        xBarTitle.textColor = .white
        xBarTitle.topAnchor.constraint(equalTo: xBarView.topAnchor, constant: 8).isActive = true
        xBarTitle.leftAnchor.constraint(equalTo: xBarView.leftAnchor).isActive = true
        xBarTitle.rightAnchor.constraint(equalTo: xBarView.rightAnchor).isActive = true

        // extend xbar to 1/3 behind the input output view
        let xBarExtendView = UIView()
        rootView.addSubview(xBarExtendView)
        xBarExtendView.backgroundColor = ConverterMainViewController.xBarBackgroundColor
        xBarExtendView.translatesAutoresizingMaskIntoConstraints = false
        xBarExtendView.topAnchor.constraint(equalTo: xBarView.bottomAnchor).isActive = true
        xBarExtendView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        xBarExtendView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        xBarExtendView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: logViewHeight + inOutViewHeight / 3).isActive = true
        rootView.sendSubview(toBack: xBarExtendView)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        let queryLogView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        queryLogView.backgroundColor = .clear
        rootView.addSubview(queryLogView)
        queryLogView.translatesAutoresizingMaskIntoConstraints = false
        queryLogView.topAnchor.constraint(equalTo: xBarView.bottomAnchor).isActive = true
        queryLogView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        queryLogView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        queryLogView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: logViewHeight).isActive = true
        queryLogView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: QueryLogViewDataSource.CollectionCellId)
        queryLogView.dataSource = self.queryLogViewDataSource
        queryLogView.delegate = self.queryLogViewDataSource
        self.queryLogViewDataSource.collectionView = queryLogView

        let inputOutputView = AmCardView()
        inputOutputView.getSubview(5).backgroundColor = ConverterMainViewController.basicBackgroundColor
        rootView.addSubview(inputOutputView)
        inputOutputView.translatesAutoresizingMaskIntoConstraints = false
        inputOutputView.topAnchor.constraint(equalTo: queryLogView.bottomAnchor).isActive = true
        inputOutputView.leftAnchor.constraint(equalTo: rootView.leftAnchor, constant: 5).isActive = true
        inputOutputView.rightAnchor.constraint(equalTo: rootView.rightAnchor, constant: -5).isActive = true
        inputOutputView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: inOutViewHeight).isActive = true

        let shortcutsView = UIView()
        shortcutsView.backgroundColor = ConverterMainViewController.secondBackgroundColor
        rootView.addSubview(shortcutsView)
        shortcutsView.translatesAutoresizingMaskIntoConstraints = false
        shortcutsView.topAnchor.constraint(equalTo: inputOutputView.bottomAnchor).isActive = true
        shortcutsView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        shortcutsView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        shortcutsView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: CGFloat(1) - logViewHeight - inOutViewHeight - xBarViewHeight).isActive = true

        rootView.bringSubview(toFront: inputOutputView)

        let keyboardHeight = fullViewHeight * (CGFloat(1) - logViewHeight - inOutViewHeight - xBarViewHeight) - 12 // backoff by 12
        self.createInputOutputSubviews2(inputOutputView.getSubview(5), keyboardHeight)
        self.createShortcutSubviews(shortcutsView)
    }

    func createShortcutSubviews(_ shortcutsView: UIView) {
        let buttonHeightFullRatio: CGFloat = 0.13
        let shortcutsCardView = AmCardView()
        shortcutsCardView.translatesAutoresizingMaskIntoConstraints = false
        shortcutsView.addSubview(shortcutsCardView)
        shortcutsCardView.topAnchor.constraint(equalTo: shortcutsView.topAnchor, constant: 10).isActive = true
        shortcutsCardView.leftAnchor.constraint(equalTo: shortcutsView.leftAnchor, constant: 5).isActive = true
        shortcutsCardView.rightAnchor.constraint(equalTo: shortcutsView.rightAnchor, constant: -5).isActive = true
        shortcutsCardView.bottomAnchor.constraint(equalTo: shortcutsView.bottomAnchor, constant: -10).isActive = true

        let shortcutsCardSubView = shortcutsCardView.getSubview(5)
        let shortcutsIntroLabel = UILabel()
        shortcutsIntroLabel.textAlignment = .center
        shortcutsIntroLabel.text = IntroLabelTitles.shortcutsIntroLabelText
        shortcutsIntroLabel.font = UIFont(name: ConverterMainViewController.introFontName, size: 7)
        shortcutsIntroLabel.textColor = ConverterMainViewController.inputFieldInactiveFontColor
        shortcutsCardView.addSubview(shortcutsIntroLabel)
        shortcutsIntroLabel.translatesAutoresizingMaskIntoConstraints = false
        shortcutsIntroLabel.leftAnchor.constraint(equalTo: shortcutsCardView.leftAnchor, constant: 0).isActive = true
        shortcutsIntroLabel.rightAnchor.constraint(equalTo: shortcutsCardView.rightAnchor, constant: 0).isActive = true
        shortcutsIntroLabel.topAnchor.constraint(equalTo: shortcutsCardView.topAnchor, constant: 0).isActive = true
        shortcutsIntroLabel.heightAnchor.constraint(equalToConstant: 9).isActive = true

        let shortcuts = ShortcutHelper.getDefinedShortcuts(self.predefinedCoversionSets)
        let rootStackView = UIStackView()

        shortcutsCardSubView.addSubview(rootStackView)
        shortcutsCardSubView.backgroundColor = ConverterMainViewController.basicBackgroundColor
        rootStackView.axis = .horizontal
        rootStackView.spacing = 4
        rootStackView.distribution = .fillEqually
        rootStackView.alignment = .top
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.leftAnchor.constraint(equalTo: shortcutsCardSubView.leftAnchor, constant: 5).isActive = true
        rootStackView.topAnchor.constraint(equalTo: shortcutsIntroLabel.bottomAnchor, constant: 0).isActive = true
        rootStackView.rightAnchor.constraint(equalTo: shortcutsCardSubView.rightAnchor, constant: -5).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: shortcutsCardSubView.bottomAnchor, constant: -5).isActive = true

        let stackViews = [UIStackView(), UIStackView(), UIStackView(), UIStackView()]
        for (stackIndex, stackView) in stackViews.enumerated() {
            rootStackView.addArrangedSubview(stackView)
            stackView.axis = .vertical
            stackView.spacing = 4
            for (scIndex, shortcut) in shortcuts.enumerated() {
                if scIndex % stackViews.count == stackIndex {
                    let scButtonView = AmShadowButton()

                    let scButton = scButtonView.getRealButton(1)
                    scButton.setTitle("\(shortcut.displayName)", for: .normal)
                    scButton.titleLabel!.font = UIFont(name: ConverterMainViewController.fontName, size: 15)
                    scButton.setBackgroundColor(color: ConverterMainViewController.longNameButtonBackColor, forState: .normal)
                    scButton.setTitleColor(ConverterMainViewController.longNameButtonFontColor, for: .normal)
                    scButton.tag = scIndex
                    scButton.addTarget(self, action: #selector(shortcutButtonTouchUpInside(_:)), for: UIControlEvents.touchUpInside)
                    stackView.addArrangedSubview(scButtonView)
                    scButtonView.heightAnchor.constraint(equalTo: rootStackView.heightAnchor, multiplier: buttonHeightFullRatio).isActive = true
                }
            }
        }
    }

    func createInputOutputSubviews2(_ inputOutputView: UIView, _ keyboardHeight: CGFloat) {
        // mode: up & bottom mode
        let equalSignHeightRatio: CGFloat = 0.10
        let equalSignRightDistance: CGFloat = 55

        let upperContainerView = UIView()
        let lowerContainerView = UIView()
        let equalSignView = UILabel()
        equalSignView.textAlignment = .center
        equalSignView.text = "="
        equalSignView.font = UIFont(name: ConverterMainViewController.fontName, size: 28)

        let leftColorView = UIView()
        inputOutputView.addSubview(leftColorView)
        leftColorView.translatesAutoresizingMaskIntoConstraints = false
        leftColorView.widthAnchor.constraint(equalToConstant: 4).isActive = true
        leftColorView.leftAnchor.constraint(equalTo: inputOutputView.leftAnchor, constant: 0).isActive = true
        leftColorView.topAnchor.constraint(equalTo: inputOutputView.topAnchor, constant: 0).isActive = true
        leftColorView.bottomAnchor.constraint(equalTo: inputOutputView.bottomAnchor, constant: 0).isActive = true
        leftColorView.backgroundColor = ConverterMainViewController.inputFieldActivateFontColor // TODO: shall use unit color

        // add container views
        inputOutputView.addSubview(upperContainerView)
        upperContainerView.translatesAutoresizingMaskIntoConstraints = false
        upperContainerView.topAnchor.constraint(equalTo: inputOutputView.topAnchor).isActive = true
        upperContainerView.leftAnchor.constraint(equalTo: leftColorView.rightAnchor).isActive = true
        upperContainerView.rightAnchor.constraint(equalTo: inputOutputView.rightAnchor).isActive = true
        upperContainerView.heightAnchor.constraint(equalTo: inputOutputView.heightAnchor, multiplier: (CGFloat(1) - equalSignHeightRatio) / 2).isActive = true

        inputOutputView.addSubview(lowerContainerView)
        lowerContainerView.translatesAutoresizingMaskIntoConstraints = false
        lowerContainerView.bottomAnchor.constraint(equalTo: inputOutputView.bottomAnchor).isActive = true
        lowerContainerView.leftAnchor.constraint(equalTo: leftColorView.rightAnchor).isActive = true
        lowerContainerView.rightAnchor.constraint(equalTo: inputOutputView.rightAnchor).isActive = true
        lowerContainerView.heightAnchor.constraint(equalTo: inputOutputView.heightAnchor, multiplier: (CGFloat(1) - equalSignHeightRatio) / 2).isActive = true

        inputOutputView.addSubview(equalSignView)
        equalSignView.translatesAutoresizingMaskIntoConstraints = false
        equalSignView.topAnchor.constraint(equalTo: upperContainerView.bottomAnchor).isActive = true
        equalSignView.bottomAnchor.constraint(equalTo: lowerContainerView.topAnchor).isActive = true
        equalSignView.rightAnchor.constraint(equalTo: inputOutputView.rightAnchor, constant: -equalSignRightDistance).isActive = true
        equalSignView.backgroundColor = ConverterMainViewController.basicBackgroundColor

        // add light gray splitter
        let leftSplitterHolder = UIView()
        inputOutputView.addSubview(leftSplitterHolder)
        leftSplitterHolder.translatesAutoresizingMaskIntoConstraints = false
        leftSplitterHolder.heightAnchor.constraint(equalTo: equalSignView.heightAnchor, multiplier: 0.5).isActive = true
        leftSplitterHolder.topAnchor.constraint(equalTo: upperContainerView.bottomAnchor, constant: 0).isActive = true
        leftSplitterHolder.leftAnchor.constraint(equalTo:  leftColorView.rightAnchor, constant: 0).isActive = true
        leftSplitterHolder.rightAnchor.constraint(equalTo: equalSignView.leftAnchor, constant: 0).isActive = true
        leftSplitterHolder.backgroundColor = .clear

        let leftSplitterView = UIView()
        inputOutputView.addSubview(leftSplitterView)
        leftSplitterView.translatesAutoresizingMaskIntoConstraints = false
        leftSplitterView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        leftSplitterView.leftAnchor.constraint(equalTo: leftColorView.rightAnchor, constant: 20).isActive = true
        leftSplitterView.rightAnchor.constraint(equalTo: equalSignView.leftAnchor, constant: -20).isActive = true
        leftSplitterView.topAnchor.constraint(equalTo: leftSplitterHolder.bottomAnchor, constant: 0).isActive = true
        leftSplitterView.backgroundColor = UIColor(white: 0.1, alpha: 0.1)

        // add container items
        self.upperInputTextField = AmTextField()
        self.upperLongNameButton = AmShadowButton()
        self.upperShortNameLabel = UILabel()
        self.createInputOutputContainerSubviews(upperContainerView, self.upperInputTextField, self.upperLongNameButton, self.upperShortNameLabel, true)

        self.lowerInputTextField = AmTextField()
        self.lowerLongNameButton = AmShadowButton()
        self.lowerShortNameLabel = UILabel()
        self.createInputOutputContainerSubviews(lowerContainerView, self.lowerInputTextField, self.lowerLongNameButton, self.lowerShortNameLabel, false)

        let numpadView = self.createNumpadView(keyboardHeight)
        self.lowerInputTextField.inputView = numpadView
        self.upperInputTextField.inputView = numpadView

        self.leftColorBarView = leftColorView
    }

    func createInputOutputContainerSubviews(_ containerView: UIView, _ inputTextField: UITextField, _ longNameButton: AmShadowButton, _ shortNameLabel: UILabel, _ isUpper: Bool) {
        containerView.backgroundColor = ConverterMainViewController.basicBackgroundColor

        containerView.addSubview(inputTextField)
        containerView.addSubview(shortNameLabel)

        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        longNameButton.translatesAutoresizingMaskIntoConstraints = false
        shortNameLabel.translatesAutoresizingMaskIntoConstraints = false

        let longNameButton = longNameButton.getRealButton(1)
        longNameButton.setTitle("", for: .normal)
        longNameButton.setTitleColor(ConverterMainViewController.longNameButtonFontColor, for: .normal)
        longNameButton.titleLabel!.font = UIFont(name: ConverterMainViewController.fontName, size: 13)
        longNameButton.setBackgroundColor(color: ConverterMainViewController.longNameButtonBackColor, forState: .normal)

        containerView.addSubview(longNameButton)
        longNameButton.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true
        longNameButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5).isActive = true
        longNameButton.heightAnchor.constraint(equalToConstant: CGFloat(self.longNameButtonHeight)).isActive = true
        longNameButton.layer.cornerRadius = 1
        longNameButton.layer.shadowColor = ConverterMainViewController.longNameButtonFontColor.cgColor
        longNameButton.layer.shadowRadius = 0.7
        longNameButton.layer.shadowOffset = CGSize(width: 0.3, height: 0.5)
        longNameButton.layer.shadowOpacity = 0.5
        longNameButton.clipsToBounds = false

        shortNameLabel.translatesAutoresizingMaskIntoConstraints = false
        shortNameLabel.text = ""
        shortNameLabel.textAlignment = .right
        shortNameLabel.font = UIFont(name: ConverterMainViewController.fontName, size: 13)
        shortNameLabel.textColor = ConverterMainViewController.shortNameFontColor
        shortNameLabel.backgroundColor = ConverterMainViewController.basicBackgroundColor
        shortNameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -5).isActive = true
        shortNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -1).isActive = true

        inputTextField.text = ""
        inputTextField.textAlignment = .right
        inputTextField.font = UIFont(name: ConverterMainViewController.fontName, size: CGFloat(self.inputViewFontSize))
        inputTextField.adjustsFontSizeToFitWidth = true
        inputTextField.minimumFontSize = 24
        inputTextField.backgroundColor = ConverterMainViewController.basicBackgroundColor
        inputTextField.textColor = ConverterMainViewController.inputFieldInactiveFontColor
        inputTextField.tintColor = .clear
        inputTextField.topAnchor.constraint(equalTo: longNameButton.bottomAnchor, constant: -10).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -20).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: shortNameLabel.topAnchor, constant: 10).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 5).isActive = true

        inputTextField.delegate = self.inputTextFieldDelegate

        if isUpper {
            let converterIntroLabel = UILabel()
            converterIntroLabel.textAlignment = .center
            converterIntroLabel.text = IntroLabelTitles.converterIntroLabelText
            converterIntroLabel.font = UIFont(name: ConverterMainViewController.introFontName, size: 7)
            converterIntroLabel.textColor = ConverterMainViewController.inputFieldInactiveFontColor
            containerView.addSubview(converterIntroLabel)
            converterIntroLabel.translatesAutoresizingMaskIntoConstraints = false
            converterIntroLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0).isActive = true
            converterIntroLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0).isActive = true
            converterIntroLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
            converterIntroLabel.heightAnchor.constraint(equalToConstant: 8).isActive = true
        }
    }

    func createNumpadView(_ height: CGFloat) -> UIView {
        let numpadRootView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: height))
        let numpadContainerView = UIView()
        numpadContainerView.translatesAutoresizingMaskIntoConstraints = false
        numpadRootView.addSubview(numpadContainerView)
        numpadContainerView.topAnchor.constraint(equalTo: numpadRootView.topAnchor, constant: 0).isActive = true
        numpadContainerView.bottomAnchor.constraint(equalTo: numpadRootView.bottomAnchor, constant: 0).isActive = true
        numpadContainerView.leftAnchor.constraint(equalTo: numpadRootView.leftAnchor, constant: 0).isActive = true
        numpadContainerView.rightAnchor.constraint(equalTo: numpadRootView.rightAnchor, constant: 0).isActive = true
        let numpadButtons = self.createNumpadButtons()
        self.fillNumpadStackView(numpadContainerView, numpadButtons)
        numpadContainerView.backgroundColor = ConverterMainViewController.secondBackgroundColor

        numpadContainerView.layer.masksToBounds = false
        numpadContainerView.layer.shadowColor = UIColor.gray.cgColor
        numpadContainerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        numpadContainerView.layer.shadowRadius = 4
        numpadContainerView.layer.shadowOpacity = 0.5

        return numpadRootView
    }

    func createNumpadButtons() -> [AmButton] {
        let num0Button = AmButton()
        num0Button.setTitle("0", for: .normal)
        num0Button.tag = 0

        let num1Button = AmButton()
        num1Button.setTitle("1", for: .normal)
        num1Button.tag = 1

        let num2Button = AmButton()
        num2Button.setTitle("2", for: .normal)
        num2Button.tag = 2

        let num3Button = AmButton()
        num3Button.setTitle("3", for: .normal)
        num3Button.tag = 3

        let num4Button = AmButton()
        num4Button.setTitle("4", for: .normal)
        num4Button.tag = 4

        let num5Button = AmButton()
        num5Button.setTitle("5", for: .normal)
        num5Button.tag = 5

        let num6Button = AmButton()
        num6Button.setTitle("6", for: .normal)
        num6Button.tag = 6

        let num7Button = AmButton()
        num7Button.setTitle("7", for: .normal)
        num7Button.tag = 7

        let num8Button = AmButton()
        num8Button.setTitle("8", for: .normal)
        num8Button.tag = 8

        let num9Button = AmButton()
        num9Button.setTitle("9", for: .normal)
        num9Button.tag = 9
        
        let dismissKeyboard = AmButton()
        dismissKeyboard.setTitle("+/-", for: .normal)
        dismissKeyboard.tag = 10

        let numDotButton = AmButton()
        numDotButton.setTitle(".", for: .normal)
        numDotButton.tag = 11

        let backspaceButton = AmButton()
        backspaceButton.setTitle("⎋", for: .normal)
        backspaceButton.tag = 12

        let clearButton = AmButton()
        clearButton.setTitle("C", for: .normal)
        clearButton.tag = 13

        let copyButton = AmButton()
        copyButton.setTitle("✄", for: .normal)
        copyButton.tag = 14

        let enterButton = AmButton()
        enterButton.setTitle("⏎", for: .normal)
        enterButton.setBackgroundColor(color: ConverterMainViewController.inputFieldActivateFontColor, forState: .normal)
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
            button.titleLabel!.font = UIFont(name: ConverterMainViewController.fontName, size: 24)
            button.addTarget(self, action: #selector(numpadButtonTouchUpInside), for: UIControlEvents.touchUpInside)
        }

        return ret
    }

    func fillNumpadStackView(_ numpadView: UIView, _ buttons: [AmButton]) {
        let numpadStackView = UIStackView()
        numpadStackView.axis = .horizontal
        numpadStackView.spacing = 0
        numpadStackView.distribution = .fillEqually
        numpadView.addSubview(numpadStackView)
        numpadStackView.translatesAutoresizingMaskIntoConstraints = false
        numpadStackView.topAnchor.constraint(equalTo: numpadView.topAnchor, constant: 5).isActive = true
        numpadStackView.bottomAnchor.constraint(equalTo: numpadView.bottomAnchor, constant: -5).isActive = true
        numpadStackView.leftAnchor.constraint(equalTo: numpadView.leftAnchor, constant: 5).isActive = true
        numpadStackView.rightAnchor.constraint(equalTo: numpadView.rightAnchor, constant: -5).isActive = true
        numpadView.bringSubview(toFront: numpadStackView)

        for colIdx in 0...3 {
            let columnView = UIStackView()
            columnView.axis = .vertical
            columnView.spacing = 0
            columnView.distribution = .fillEqually
            numpadStackView.addArrangedSubview(columnView)
            for rowIdx in 0...3 {
                let buttonIndex = colIdx * 4 + rowIdx
                if buttons.count > buttonIndex {
                    let button = buttons[buttonIndex]
                    if button.tag != 15 {
                        button.setBackgroundColor(color: ConverterMainViewController.basicBackgroundColor, forState: .normal)
                    } else {
                        button.layer.cornerRadius = 1
                        button.layer.shadowColor = UIColor.gray.cgColor
                        button.layer.shadowRadius = 1
                        button.layer.shadowOffset = CGSize(width: 0.7, height: 0.7)
                        button.layer.shadowOpacity = 0.5
                        button.clipsToBounds = false
                    }

                    button.setBackgroundColor(color: ConverterMainViewController.keyboardOnTouchColor, forState: .selected)
                    button.setBackgroundColor(color: ConverterMainViewController.keyboardOnTouchColor, forState: .highlighted)
                    button.setTitleColor(ConverterMainViewController.mainStreamFontColor, for: .normal)
                    columnView.addArrangedSubview(button)
                }
            }
        }
    }

    @objc func shortcutButtonTouchUpInside(_ sender: UIButton) {
        if let shadowButton = sender as? AmButton {
            shadowButton.setBackgroundColor(color: ConverterMainViewController.keyboardOnTouchColor, forState: .normal)
        }

        let shortcut = ShortcutHelper.getDefinedShortcut(self.predefinedCoversionSets, sender.tag)
        self.applyConverter(UnitConversionHelper.getUnitConverterByItem(shortcut.leftItem), .upper)
        self.applyConverter(UnitConversionHelper.getUnitConverterByItem(shortcut.rightItem), .lower)
        self.getCalcResult(.upper)
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

