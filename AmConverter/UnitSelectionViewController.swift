import UIKit

class UnitSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    class SubTableTags {
        static let unitTypeTableTag = 0
        static let unitItemFromTableTag = 1
        static let unitItemToTableTag = 2
    }

    @IBOutlet weak var rootView: UIView!

    static let tableViewCellId = "unitSelectionViewCellId"
    var selectionSource: [UnitTypeSelection]!
    var converterController: ConverterMainViewController!
    var currentUnitTypeSourceIndex: Int = 0
    var unitTypeSelectionTable: UITableView!
    var unitItemFromSelectionTable: UITableView!
    var unitItemToSelectionTable: UITableView!

    class UnitTypeSelection {
        var selected: Bool = false
        var unitType: UnitTypes
        var unitItemFrom: [UnitItemSelection]
        var unitItemTo: [UnitItemSelection] // Only finish selection when to is clicked.

        init(_ unitType: UnitTypes, _ unitItemFrom: [UnitItemSelection], _ unitItemTo: [UnitItemSelection]) {
            self.unitType = unitType
            self.unitItemFrom = unitItemFrom
            self.unitItemTo = unitItemTo

            if self.unitItemFrom.first(where: { s in s.selected }) == nil {

            }

            if self.unitItemTo.first(where: { s in s.selected }) == nil {

            }
        }
    }

    class UnitItemSelection {
        var selected: Bool = false
        let unitItem: UnitItems

        init(_ unitItem: UnitItems) {
            self.unitItem = unitItem
        }
    }

    class UnitTypeSelectionCell: UITableViewCell {
        static let selectedBackgroundColor = UIColor(red: 139.0 / 255, green: 196.0 / 255, blue: 233.0 / 255, alpha: 1)

        var initialized = false

        var unitNameLabel: UILabel!

        func load(_ type: UnitTypeSelection) {
            if !self.initialized {
                self.initialized = true
                self.unitNameLabel = UILabel()
                self.unitNameLabel.font = UIFont(name: ConverterMainViewController.fontName, size: 14)
                self.contentView.addSubview(self.unitNameLabel)
                self.unitNameLabel.translatesAutoresizingMaskIntoConstraints = false
                self.unitNameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 5).isActive = true
                self.unitNameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 7).isActive = true
                self.unitNameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -7).isActive = true
                self.unitNameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -5).isActive = true
            }

            self.unitNameLabel.text = UnitConversionHelper.getUnitTypeDisplayName(type.unitType)

            if type.selected {
                self.backgroundColor = UnitTypeSelectionCell.selectedBackgroundColor
                self.unitNameLabel.textColor = .white
            } else {
                self.backgroundColor = ConverterMainViewController.longNameButtonBackColor
                self.unitNameLabel.textColor = ConverterMainViewController.longNameButtonFontColor
            }
        }
    }

    class UnitItemSelectionCell: UITableViewCell {
        var initialized = false

        var unitItemShortNameLabel: UILabel!
        var unitItemLongNameLabel: UILabel!

        func load(_ item: UnitItemSelection) {
            if !self.initialized {
                self.initialized = true
                self.unitItemShortNameLabel = UILabel()
                self.unitItemLongNameLabel = UILabel()

                self.contentView.addSubview(self.unitItemShortNameLabel)
                self.unitItemShortNameLabel.translatesAutoresizingMaskIntoConstraints = false
                self.unitItemShortNameLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 2).isActive = true
                self.unitItemShortNameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 2).isActive = true
                self.unitItemShortNameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -2).isActive = true
                self.unitItemShortNameLabel.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.55).isActive = true
                self.unitItemShortNameLabel.textAlignment = .center
                self.unitItemShortNameLabel.font = UIFont(name: QueryLogViewCell.unitFontName, size: 14)
                self.unitItemShortNameLabel.backgroundColor = .clear

                self.contentView.addSubview(self.unitItemLongNameLabel)
                self.unitItemLongNameLabel.translatesAutoresizingMaskIntoConstraints = false
                self.unitItemLongNameLabel.topAnchor.constraint(equalTo: self.unitItemShortNameLabel.bottomAnchor, constant: 3).isActive = true
                self.unitItemLongNameLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2).isActive = true
                self.unitItemLongNameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 0).isActive = true
                self.unitItemLongNameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: 0).isActive = true
                self.unitItemLongNameLabel.textAlignment = .center
                self.unitItemLongNameLabel.font = UIFont(name: ConverterMainViewController.fontName, size: 10)
                self.unitItemLongNameLabel.textColor = .lightGray
            }

            self.unitItemShortNameLabel.text = UnitConversionHelper.getUnitItemShortName(item.unitItem)
            self.unitItemLongNameLabel.text = UnitConversionHelper.getUnitItemDisplayName(item.unitItem)

            if item.selected {
                self.contentView.backgroundColor = .yellow
            } else {
                self.contentView.backgroundColor = .white
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initSourceTable()

        // initialize the (hidden) dismiss button.
        let dismissButton = UIButton()
        self.rootView.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.topAnchor.constraint(equalTo: self.rootView.topAnchor).isActive = true
        dismissButton.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor).isActive = true
        dismissButton.rightAnchor.constraint(equalTo: self.rootView.rightAnchor).isActive = true
        dismissButton.widthAnchor.constraint(equalTo: self.rootView.widthAnchor, multiplier: 1.0 - SideMenuHelper.menuWidthPercent).isActive = true
        dismissButton.addTarget(self, action: #selector(self.dismissToMain), for: .touchUpInside)

        // initialize all the 3 tables
        let cellHeight: CGFloat = 45
        let unitTypeWidthPercent: CGFloat = 0.30

        let unitTypeSelectionView = UIView()
        self.rootView.addSubview(unitTypeSelectionView)
        unitTypeSelectionView.translatesAutoresizingMaskIntoConstraints = false
        unitTypeSelectionView.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: 0).isActive = true
        unitTypeSelectionView.leftAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: 0).isActive = true
        unitTypeSelectionView.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor, constant: 0).isActive = true
        unitTypeSelectionView.widthAnchor.constraint(equalTo: self.rootView.widthAnchor, multiplier: unitTypeWidthPercent * SideMenuHelper.menuWidthPercent, constant: -2).isActive = true

        unitTypeSelectionView.backgroundColor = .lightGray

        // unitTypeSelectionView.layer.shadowRadius = 0.8
        // unitTypeSelectionView.layer.shadowOpacity = 0.5
        self.unitTypeSelectionTable = UITableView()
        self.unitTypeSelectionTable.tag = UnitSelectionViewController.SubTableTags.unitTypeTableTag
        self.unitTypeSelectionTable.register(UnitTypeSelectionCell.self, forCellReuseIdentifier: UnitSelectionViewController.tableViewCellId)
        unitTypeSelectionView.addSubview(self.unitTypeSelectionTable)
        self.unitTypeSelectionTable.dataSource = self
        self.unitTypeSelectionTable.delegate = self
        self.unitTypeSelectionTable.rowHeight = cellHeight
        self.unitTypeSelectionTable.backgroundView = nil
        self.unitTypeSelectionTable.separatorStyle = .none
        self.unitTypeSelectionTable.dragInteractionEnabled = false
        self.unitTypeSelectionTable.translatesAutoresizingMaskIntoConstraints = false
        self.unitTypeSelectionTable.leftAnchor.constraint(equalTo: unitTypeSelectionView.leftAnchor, constant: 1).isActive = true
        self.unitTypeSelectionTable.topAnchor.constraint(equalTo: unitTypeSelectionView.topAnchor, constant: 55).isActive = true
        self.unitTypeSelectionTable.heightAnchor.constraint(equalToConstant: cellHeight * CGFloat(self.selectionSource.count)).isActive = true
        self.unitTypeSelectionTable.widthAnchor.constraint(equalTo: unitTypeSelectionView.widthAnchor).isActive = true
        self.unitTypeSelectionTable.bounces = false
        self.unitTypeSelectionTable.alwaysBounceVertical = false
        self.unitTypeSelectionTable.bouncesZoom = false
        self.unitTypeSelectionTable.backgroundColor = .blue

        self.unitItemFromSelectionTable = UITableView()
        self.unitItemFromSelectionTable.tag = UnitSelectionViewController.SubTableTags.unitItemFromTableTag
        self.rootView.addSubview(self.unitItemFromSelectionTable)
        self.unitItemFromSelectionTable.register(UnitItemSelectionCell.self, forCellReuseIdentifier: UnitSelectionViewController.tableViewCellId)
        self.unitItemFromSelectionTable.dataSource = self
        self.unitItemFromSelectionTable.delegate = self
        self.unitItemFromSelectionTable.rowHeight = cellHeight
        self.unitItemFromSelectionTable.backgroundView = nil
        self.unitItemFromSelectionTable.separatorStyle = .none
        self.unitItemFromSelectionTable.dragInteractionEnabled = false
        self.unitItemFromSelectionTable.translatesAutoresizingMaskIntoConstraints = false
        self.unitItemFromSelectionTable.leftAnchor.constraint(equalTo: unitTypeSelectionView.rightAnchor, constant: 2).isActive = true
        self.unitItemFromSelectionTable.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: 10).isActive = true
        self.unitItemFromSelectionTable.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor).isActive = true
        self.unitItemFromSelectionTable.widthAnchor.constraint(equalTo: self.rootView.widthAnchor, multiplier: (1 - unitTypeWidthPercent) / 2 * SideMenuHelper.menuWidthPercent, constant: -2).isActive = true
        self.unitItemFromSelectionTable.backgroundColor = .clear
    }

    func initSourceTable() {
        self.selectionSource = []
        let types = UnitConversionHelper.getAllUnitTypes()
        for (i, type) in types.enumerated() {
            let units = UnitConversionHelper.getUnitItemsByType(type)
            var unitsFrom = [UnitItemSelection]()
            var unitsTo = [UnitItemSelection]()
            for unit in units {
                let fromUnit = UnitItemSelection(unit)
                if unit == self.converterController.upperUnitBiConverter.unitItem {
                    fromUnit.selected = true
                }

                let toUnit = UnitItemSelection(unit)
                if unit == self.converterController.lowerUnitBiConverter.unitItem {
                    toUnit.selected = true
                }

                unitsFrom.append(fromUnit)
                unitsTo.append(toUnit)
            }

            let item = UnitTypeSelection(type, unitsFrom, unitsTo)
            if type == self.converterController.lowerUnitBiConverter.unitType {
                item.selected = true
                self.currentUnitTypeSourceIndex = i
            }

            self.selectionSource.append(item)
        }
    }

    @objc func dismissToMain() {
        self.dismiss(animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == UnitSelectionViewController.SubTableTags.unitTypeTableTag {
            var reloading = [IndexPath]()
            for (i, s) in self.selectionSource.enumerated() {
                if i == indexPath.item {
                    s.selected = true
                    self.currentUnitTypeSourceIndex = i
                    reloading.append(IndexPath(item: i, section: 0))
                } else {
                    s.selected = false
                    reloading.append(IndexPath(item: i, section: 0))
                }
            }

            tableView.reloadRows(at: reloading, with: .none)
            self.unitItemFromSelectionTable.reloadData()
        } else if tableView.tag == UnitSelectionViewController.SubTableTags.unitItemFromTableTag {

        } else { // unitItemToTableTag
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == UnitSelectionViewController.SubTableTags.unitTypeTableTag {
            return self.selectionSource.count
        } else if tableView.tag == UnitSelectionViewController.SubTableTags.unitItemFromTableTag {
            return self.selectionSource[self.currentUnitTypeSourceIndex].unitItemFrom.count
        } else { // unitItemToTableTag
            return self.selectionSource[self.currentUnitTypeSourceIndex].unitItemTo.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == UnitSelectionViewController.SubTableTags.unitTypeTableTag {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UnitSelectionViewController.tableViewCellId) as? UnitTypeSelectionCell else {
                return UITableViewCell()
            }

            cell.load(self.selectionSource[indexPath.item])
            return cell
        } else if tableView.tag == UnitSelectionViewController.SubTableTags.unitItemFromTableTag {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UnitSelectionViewController.tableViewCellId) as? UnitItemSelectionCell else {
                return UITableViewCell()
            }

            cell.load(self.selectionSource[self.currentUnitTypeSourceIndex].unitItemFrom[indexPath.item])
            return cell
        } else { // unitItemToTableTag

        }

        return UITableViewCell()
    }
}
