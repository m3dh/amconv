import UIKit

class UnitSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    enum SelectionWorkMode {
        case typeToUnit
        case unitOnly
    }

    class TableSectionItem {
        var opened: Bool
        var unitType: UnitTypes
        var unitItems: [UnitItems]

        init(_ unitType: UnitTypes, _ unitItems: [UnitItems]) {
            self.unitType = unitType
            self.unitItems = unitItems
            self.opened = false
        }
    }

    class UnitSelectorTableViewCell: UITableViewCell {
        var initialized = false
        var expandLabel: UILabel!
        var realButton: AmButton!
        var realButtonWidth: NSLayoutConstraint!

        func initialize() {
            if !self.initialized {
                self.initialized = true
                self.selectionStyle = .none
                self.backgroundColor = UnitSelectionViewController.selectionBackgroundColor

                self.expandLabel = UILabel()
                self.expandLabel.font = UIFont(name: ConverterMainViewController.fontName, size: 18)
                self.expandLabel.textColor = .white
                self.expandLabel.translatesAutoresizingMaskIntoConstraints = false
                self.contentView.addSubview(expandLabel)
                self.expandLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5).isActive = true
                self.expandLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
                self.expandLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true
                self.expandLabel.widthAnchor.constraint(equalToConstant: 15).isActive = true

                let shadowButton = AmShadowButton()
                self.realButton = shadowButton.getRealButton(1.3)
                shadowButton.layer.shadowColor = UIColor.lightGray.cgColor
                self.contentView.addSubview(shadowButton)
                shadowButton.translatesAutoresizingMaskIntoConstraints = false
                shadowButton.leftAnchor.constraint(equalTo: self.expandLabel.rightAnchor, constant: 0).isActive = true
                shadowButton.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4).isActive = true
                shadowButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4).isActive = true
                self.realButton.titleLabel!.font = UIFont(name: ConverterMainViewController.fontName, size: 18)
                self.realButton.isUserInteractionEnabled = false

                self.realButtonWidth = self.realButton.widthAnchor.constraint(equalToConstant: 10)
                self.realButtonWidth.isActive = true
            }
        }
    }

    static let tableViewCellId = "unitSelectionViewCellId"

    static let selectionBackgroundColor = UIColor(red: 67.0 / 255, green: 65.0 / 255, blue: 80.0 / 255, alpha: 1)
    static let unitTypeButtonColor = UIColor(red: 242.0 / 255, green: 79.0 / 255, blue: 94.0 / 255, alpha: 1)

    var sideSlideDirection: SideMenuSlideDirection! = nil
    var selectionWorkMode: SelectionWorkMode = SelectionWorkMode.unitOnly

    var selectionTable: UITableView!
    var selectionSource: [TableSectionItem]! // could be only one item if there's no sections

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create dismiss button & selection table
        let dismissButton = UIButton()
        self.view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        self.selectionTable = UITableView()
        self.view.addSubview(self.selectionTable)
        self.selectionTable.translatesAutoresizingMaskIntoConstraints = false

        self.selectionTable.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -1).isActive = true
        self.selectionTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        dismissButton.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        dismissButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        if self.sideSlideDirection == .Right {
            dismissButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            dismissButton.widthAnchor.constraint(equalToConstant: (1.0 - SideMenuHelper.menuWidthPercent) * self.view.bounds.width).isActive = true
            self.selectionTable.rightAnchor.constraint(equalTo: dismissButton.leftAnchor, constant: 0).isActive = true
            self.selectionTable.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        } else {
            dismissButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            dismissButton.widthAnchor.constraint(equalToConstant: (1.0 - SideMenuHelper.menuWidthPercent) * self.view.bounds.width).isActive = true
            self.selectionTable.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
            self.selectionTable.leftAnchor.constraint(equalTo: dismissButton.rightAnchor, constant: 0).isActive = true
        }

        dismissButton.addTarget(self, action: #selector(self.dismissToMain), for: .touchUpInside)

        self.initTable()
        self.selectionTable.reloadData()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }

    func initTable() {
        self.selectionTable.register(UnitSelectorTableViewCell.self, forCellReuseIdentifier: UnitSelectionViewController.tableViewCellId)
        self.selectionTable.backgroundView = nil
        self.selectionTable.backgroundColor = .white
        self.selectionTable.separatorStyle = .none

        self.selectionTable.dataSource = self
        self.selectionTable.delegate = self

        if self.selectionWorkMode == .typeToUnit {
            self.selectionSource = []
            let types = UnitConversionHelper.getAllUnitTypes()
            for type in types {
                let units = UnitConversionHelper.getUnitItemsByType(type)
                self.selectionSource.append(TableSectionItem(type, units))
            }
        }
    }

    @objc func dismissToMain() {
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.row == 0 {
            return 0
        } else {
            return 1
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.selectionSource.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        } else {
            return 36
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            let sec = self.selectionSource[indexPath.section]
            if sec.opened {
                sec.opened = false
                let indexSet = IndexSet(integer: indexPath.section)
                tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
            } else {
                sec.opened = true
                let indexSet = IndexSet(integer: indexPath.section)
                tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
            }
        } else {
            let selected = self.selectionSource[indexPath.section].unitItems[indexPath.row - 1]

            // for a strange reason (gc?) if we don't have this line the flow will stuck here...
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.none)
            self.dismiss(animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sec = self.selectionSource[section]
        if sec.opened {
            return self.selectionSource[section].unitItems.count + 1 /* including the section header */
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UnitSelectionViewController.tableViewCellId) as? UnitSelectorTableViewCell else { return UITableViewCell() }
        cell.initialize()
        if self.selectionWorkMode == .typeToUnit {
            let section = self.selectionSource[indexPath.section]
            if indexPath.row == 0 {
                let typeName = UnitConversionHelper.getUnitTypeDisplayName(section.unitType)
                cell.realButton.setTitle(typeName, for: .normal)
                cell.realButton.setTitleColor(.white, for: .normal)
                cell.realButton.setBackgroundColor(color: UnitSelectionViewController.unitTypeButtonColor, forState: .normal)

                if section.opened {
                    cell.expandLabel.text = "-"
                } else {
                    cell.expandLabel.text = "+"
                }

                let fitSize = cell.realButton.sizeThatFits(CGSize(width: CGFloat.infinity, height: CGFloat(30)))
                var fitWidth = fitSize.width
                if fitWidth < 60 {
                    fitWidth = 60
                }
                cell.realButtonWidth.constant = fitWidth + 10
                return cell
            } else {
                let unitName = UnitConversionHelper.getUnitItemDisplayName(section.unitItems[indexPath.row - 1])
                cell.expandLabel.text = ""
                cell.realButton.setTitleColor(ConverterMainViewController.longNameButtonFontColor, for: .normal)
                cell.realButton.setTitle(unitName, for: .normal)
                cell.realButton.setBackgroundColor(color: ConverterMainViewController.longNameButtonBackColor, forState: .normal)

                let fitSize = cell.realButton.sizeThatFits(CGSize(width: CGFloat.infinity, height: CGFloat(30)))
                var fitWidth = fitSize.width
                if fitWidth < 70 {
                    fitWidth = 70
                }
                cell.realButtonWidth.constant = fitWidth + 10
                return cell
            }
        } else { // work mode : unit only
            return cell
        }
    }
}
