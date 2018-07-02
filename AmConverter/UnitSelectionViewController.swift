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

    var converterController: ConverterMainViewController!
    var selectionTable: UITableView!
    var selectionSource: [TableSectionItem]! // could be only one item if there's no sections

    override func viewDidLoad() {
        super.viewDidLoad()

        let selectionHeaderHeight: CGFloat = 75
        let selectionHeaderTitleHeight: CGFloat = 30

        let selectionHeaderView = UIView()
        self.view.addSubview(selectionHeaderView)
        selectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        selectionHeaderView.heightAnchor.constraint(equalToConstant: selectionHeaderHeight).isActive = true
        selectionHeaderView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        selectionHeaderView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        selectionHeaderView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: SideMenuHelper.menuWidthPercent).isActive = true
        selectionHeaderView.backgroundColor = UnitSelectionViewController.selectionBackgroundColor

        let selectionHeaderLabel = UILabel()
        selectionHeaderView.addSubview(selectionHeaderLabel)
        selectionHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        selectionHeaderLabel.topAnchor.constraint(equalTo: selectionHeaderView.topAnchor, constant: 35).isActive = true
        selectionHeaderLabel.leftAnchor.constraint(equalTo: selectionHeaderView.leftAnchor, constant: 0).isActive = true
        selectionHeaderLabel.rightAnchor.constraint(equalTo: selectionHeaderView.rightAnchor).isActive = true
        selectionHeaderLabel.heightAnchor.constraint(equalToConstant: selectionHeaderTitleHeight).isActive = true
        selectionHeaderLabel.textAlignment = .center
        selectionHeaderLabel.font = UIFont(name: ConverterMainViewController.fontName, size: 24)
        selectionHeaderLabel.textColor = .white

        if self.selectionWorkMode == .typeToUnit {
            selectionHeaderLabel.text = "Select Upper Unit"
        } else {
            selectionHeaderLabel.text = "Select Lower Unit"
        }

        // Create dismiss button & selection table
        let dismissButton = UIButton()
        self.view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false

        self.selectionTable = UITableView()
        self.view.addSubview(self.selectionTable)
        self.selectionTable.translatesAutoresizingMaskIntoConstraints = false

        self.selectionTable.topAnchor.constraint(equalTo: selectionHeaderView.bottomAnchor).isActive = true
        self.selectionTable.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        dismissButton.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        dismissButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        dismissButton.widthAnchor.constraint(equalToConstant: (1.0 - SideMenuHelper.menuWidthPercent) * self.view.bounds.width).isActive = true
        self.selectionTable.rightAnchor.constraint(equalTo: dismissButton.leftAnchor, constant: 0).isActive = true
        self.selectionTable.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true

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
        self.selectionTable.dragInteractionEnabled = false
        self.selectionTable.dataSource = self
        self.selectionTable.delegate = self

        if self.selectionWorkMode == .typeToUnit {
            self.selectionSource = []
            let types = UnitConversionHelper.getAllUnitTypes()
            for type in types {
                let units = UnitConversionHelper.getUnitItemsByType(type)
                let item = TableSectionItem(type, units)
                if type == self.converterController.lowerUnitBiConverter.unitType {
                    item.opened = true
                }
                self.selectionSource.append(item)
            }
        } else {
            self.selectionSource = []
            let type = self.converterController.upperUnitBiConverter.unitType

            let item = TableSectionItem(type, UnitConversionHelper.getUnitItemsByType(type))
            item.opened = true
            self.selectionSource.append(item)
        }
    }

    @objc func dismissToMain() {
        self.dismiss(animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.selectionSource.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 40
        } else {
            // for unit only mode, all the rows are just units
            return 36
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            if self.selectionSource.count == 1 {
                return
            }

            let sec = self.selectionSource[indexPath.section]
            if sec.opened {
                sec.opened = false
                let indexSet = IndexSet(integer: indexPath.section)
                tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
            } else {
                var reloadSec = -1
                for (idx, section) in self.selectionSource.enumerated() {
                    if section.opened {
                        section.opened = false
                        reloadSec = idx
                    }
                }

                sec.opened = true
                var indexSet: IndexSet
                if reloadSec >= 0 && reloadSec != indexPath.section {
                    indexSet = IndexSet([reloadSec, indexPath.section])
                } else {
                    indexSet = IndexSet(integer: indexPath.section)
                }

                tableView.reloadSections(indexSet, with: UITableViewRowAnimation.none)
            }
        } else {
            let selected = self.selectionSource[indexPath.section].unitItems[indexPath.row - 1]
            if self.selectionWorkMode == .typeToUnit {
                self.converterController.applyConverter(UnitConversionHelper.getUnitConverterByItem(selected), .upper)

                if self.converterController.lowerUnitBiConverter.unitType != self.selectionSource[indexPath.section].unitType {
                    // find the first different target unit
                    let firstTarget = self.selectionSource[indexPath.section].unitItems.first(where: {$0 != selected})!
                    self.converterController.applyConverter(UnitConversionHelper.getUnitConverterByItem(firstTarget), .lower)
                }
                self.converterController.getCalcResult(.upper, true)
            } else {
                self.converterController.applyConverter(UnitConversionHelper.getUnitConverterByItem(selected), .lower)
                self.converterController.getCalcResult(.upper, true)
            }

            // for a strange reason (gc?) if we don't have this line the flow will stuck here...
            tableView.reloadSections(IndexSet(integer: indexPath.section), with: UITableViewRowAnimation.none)
            self.converterController.resetShortcutButtonColor()
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
            if fitWidth < 40 {
                fitWidth = 40
            }
            cell.realButtonWidth.constant = fitWidth + 20
            return cell
        }
    }
}
