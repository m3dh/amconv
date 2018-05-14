import UIKit

/* Project ToDo List:
 *  - Create the customized number pad.
 *  - Create the input boxes, and unit selections (slided windows)
 *  - Create ICON force touch short cuts.
 *  - Create short cuts below & history banner
 */

class ConverterMainViewController: UIViewController {
    static let numpadMaximumHeight: CGFloat = 240

    @IBOutlet weak var rootView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootView.backgroundColor = UIColor.gray
        self.createMainViewSections(self.rootView)
    }

    func createMainViewSections(_ rootView: UIView) {
        /* 40% ~ 10% ~ 50% */
        let queryLogView = UIView()
        queryLogView.backgroundColor = UIColor.yellow
        rootView.addSubview(queryLogView)
        queryLogView.translatesAutoresizingMaskIntoConstraints = false
        queryLogView.topAnchor.constraint(equalTo: rootView.topAnchor).isActive = true
        queryLogView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        queryLogView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        queryLogView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: 0.4).isActive = true

        let inputOutputView = UIView()
        inputOutputView.backgroundColor = UIColor.red
        rootView.addSubview(inputOutputView)
        inputOutputView.translatesAutoresizingMaskIntoConstraints = false
        inputOutputView.topAnchor.constraint(equalTo: queryLogView.bottomAnchor).isActive = true
        inputOutputView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        inputOutputView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        inputOutputView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: 0.15).isActive = true
        self.createInputOutputSubviews(inputOutputView)

        let shortcutsView = UIView()
        shortcutsView.backgroundColor = UIColor.white
        rootView.addSubview(shortcutsView)
        shortcutsView.translatesAutoresizingMaskIntoConstraints = false
        shortcutsView.topAnchor.constraint(equalTo: inputOutputView.bottomAnchor).isActive = true
        shortcutsView.leftAnchor.constraint(equalTo: rootView.leftAnchor).isActive = true
        shortcutsView.rightAnchor.constraint(equalTo: rootView.rightAnchor).isActive = true
        shortcutsView.heightAnchor.constraint(equalTo: rootView.heightAnchor, multiplier: 0.45).isActive = true

        // TEST
        self.fillNumpadFirstLevelView(shortcutsView)
    }

    func createInputOutputSubviews(_ inputOutputView: UIView) {
        let inputTextView = UITextView()
        inputTextView.backgroundColor = UIColor.lightGray
        inputOutputView.addSubview(inputTextView)
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
        inputTextView.topAnchor.constraint(equalTo: inputOutputView.topAnchor, constant: 5).isActive = true
        inputTextView.leftAnchor.constraint(equalTo: inputOutputView.leftAnchor, constant: 5).isActive = true
        inputTextView.rightAnchor.constraint(equalTo: inputOutputView.rightAnchor, constant: -5).isActive = true
        inputTextView.bottomAnchor.constraint(equalTo: inputOutputView.bottomAnchor, constant: -5).isActive = true

        let numpadView = self.createNumpadView()
        inputTextView.inputView = numpadView
    }

    func createNumpadView() -> UIView {
        let numpadRootView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: ConverterMainViewController.numpadMaximumHeight))

        return numpadRootView
    }

    func fillNumpadFirstLevelView(_ numpadView: UIView) {
        let column1View = UIView()
        numpadView.addSubview(column1View)
        column1View.backgroundColor = UIColor.red
        column1View.translatesAutoresizingMaskIntoConstraints = false
        column1View.topAnchor.constraint(equalTo: numpadView.topAnchor).isActive = true
        column1View.leftAnchor.constraint(equalTo: numpadView.leftAnchor).isActive = true
        column1View.widthAnchor.constraint(equalTo: numpadView.widthAnchor, multiplier: 0.25).isActive = true
        column1View.heightAnchor.constraint(equalTo: numpadView.heightAnchor).isActive = true

        let column2View = UIView()
        numpadView.addSubview(column2View)
        column2View.backgroundColor = UIColor.orange
        column2View.translatesAutoresizingMaskIntoConstraints = false
        column2View.topAnchor.constraint(equalTo: numpadView.topAnchor).isActive = true
        column2View.leftAnchor.constraint(equalTo: column1View.rightAnchor).isActive = true
        column2View.widthAnchor.constraint(equalTo: numpadView.widthAnchor, multiplier: 0.25).isActive = true
        column2View.heightAnchor.constraint(equalTo: numpadView.heightAnchor).isActive = true

        let column3View = UIView()
        numpadView.addSubview(column3View)
        column3View.backgroundColor = UIColor.yellow
        column3View.translatesAutoresizingMaskIntoConstraints = false
        column3View.topAnchor.constraint(equalTo: numpadView.topAnchor).isActive = true
        column3View.leftAnchor.constraint(equalTo: column2View.rightAnchor).isActive = true
        column3View.widthAnchor.constraint(equalTo: numpadView.widthAnchor, multiplier: 0.25).isActive = true
        column3View.heightAnchor.constraint(equalTo: numpadView.heightAnchor).isActive = true

        let column4View = UIStackView()
        column4View.axis = .vertical
        let button1 = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        column4View.addArrangedSubview(button1)
        button1.backgroundColor = UIColor.black
        button1.setTitle("Title!!!!", for: .normal)
        button1.setTitleColor(UIColor.white, for: .normal)

        numpadView.addSubview(column4View)
        column4View.backgroundColor = UIColor.green
        column4View.translatesAutoresizingMaskIntoConstraints = false
        column4View.topAnchor.constraint(equalTo: numpadView.topAnchor).isActive = true
        column4View.leftAnchor.constraint(equalTo: column3View.rightAnchor).isActive = true
        column4View.widthAnchor.constraint(equalTo: numpadView.widthAnchor, multiplier: 0.25).isActive = true
        column4View.heightAnchor.constraint(equalTo: numpadView.heightAnchor).isActive = true
    }

    func fillNumpadSecondLevelView(_ numpadColumnView: UIView) {

    }
}

