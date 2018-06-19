import UIKit

class QueryLogItem {
    var from: String
    var to: String
    var fromUnit: UnitItems
    var toUnit: UnitItems

    init(_ from: String, _ to: String, _ fromUnit: UnitItems, _ toUnit: UnitItems) {
        self.from = from
        self.to = to
        self.fromUnit = fromUnit
        self.toUnit = toUnit
    }
}

class QueryLogViewDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let CollectionCellId = "queryLogViewDataCellId"
    static let cellWidthRatio = CGFloat(1.0 / 3.75)
    static let queryDigitColor = UIColor(red: 123.0 / 255, green: 124.0 / 255, blue: 124.0 / 255, alpha: 1)

    var collectionView: UICollectionView!

    var dataSourceCollection: [QueryLogItem] = []

    func appendLogItem(_ logItem: QueryLogItem) {
        var found = false
        for sourceItem in self.dataSourceCollection {
            if sourceItem.from == logItem.from && sourceItem.to == logItem.to && sourceItem.fromUnit == logItem.fromUnit && sourceItem.toUnit == logItem.toUnit {
                found = true
            }
        }

        if !found {
            let indexPath = IndexPath(item: 0, section: 0)
            self.dataSourceCollection.insert(logItem, at: 0)
            self.collectionView.insertItems(at: [indexPath])
            self.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)

            if self.dataSourceCollection.count > 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // reload second item to remove the hint label
                    self.collectionView.reloadItems(at: [IndexPath(item: 1, section: 0)])
                }

                if self.dataSourceCollection.count > 10 {
                    let removeIndex = self.dataSourceCollection.count - 1
                    self.dataSourceCollection.remove(at: removeIndex)
                    self.collectionView.deleteItems(at: [IndexPath(item: removeIndex, section: 0)])
                }
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSourceCollection.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QueryLogViewDataSource.CollectionCellId, for: indexPath)
        let logItem = self.dataSourceCollection[indexPath.item]

        let logItemView = AmCardView()
        cell.contentView.backgroundColor = .clear
        cell.contentView.addSubview(logItemView)
        logItemView.translatesAutoresizingMaskIntoConstraints = false
        logItemView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5).isActive = true
        logItemView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10).isActive = true
        logItemView.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 5).isActive = true
        logItemView.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: 0).isActive = true

        let logItemContentView = logItemView.getSubview(5)
        logItemContentView.backgroundColor = ConverterMainViewController.basicBackgroundColor
        logItemView.layer.shadowColor = UIColor.darkGray.cgColor
        self.fillHistoryCardContent(logItemContentView, logItem)
        if indexPath.item == 0 {
            let historyIntroLabel = UILabel()
            historyIntroLabel.textAlignment = .center
            historyIntroLabel.text = IntroLabelTitles.historyIntroLabelText
            historyIntroLabel.font = UIFont(name: ConverterMainViewController.introFontName, size: 7)
            historyIntroLabel.textColor = ConverterMainViewController.inputFieldInactiveFontColor
            logItemContentView.addSubview(historyIntroLabel)
            historyIntroLabel.translatesAutoresizingMaskIntoConstraints = false
            historyIntroLabel.leftAnchor.constraint(equalTo: logItemContentView.leftAnchor, constant: 0).isActive = true
            historyIntroLabel.rightAnchor.constraint(equalTo: logItemContentView.rightAnchor, constant: 0).isActive = true
            historyIntroLabel.topAnchor.constraint(equalTo: logItemContentView.topAnchor, constant: 0).isActive = true
            historyIntroLabel.heightAnchor.constraint(equalToConstant: 8).isActive = true
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width * QueryLogViewDataSource.cellWidthRatio, height: collectionView.bounds.height)
    }

    func fillHistoryCardContent(_ contentView: UIView, _ logItem: QueryLogItem) {
        let upperContainer = UIView()
        let lowerContainer = UIView()

        contentView.addSubview(upperContainer)
        upperContainer.translatesAutoresizingMaskIntoConstraints = false
        upperContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        upperContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
        upperContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
        upperContainer.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.48, constant: 0).isActive = true

        contentView.addSubview(lowerContainer)
        lowerContainer.translatesAutoresizingMaskIntoConstraints = false
        lowerContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0).isActive = true
        lowerContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
        lowerContainer.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
        lowerContainer.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.48, constant: 0).isActive = true

        let splitterView = UIView()
        contentView.addSubview(splitterView)
        splitterView.translatesAutoresizingMaskIntoConstraints = false
        splitterView.topAnchor.constraint(equalTo: upperContainer.bottomAnchor, constant: 0).isActive = true
        splitterView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.01).isActive = true
        splitterView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
        splitterView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.42).isActive = true
        splitterView.backgroundColor = .clear

        let splitterLine = UIView()
        contentView.addSubview(splitterLine)
        splitterLine.backgroundColor = UIColor(white: 0.1, alpha: 0.1)
        splitterLine.translatesAutoresizingMaskIntoConstraints = false
        splitterLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        splitterLine.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        splitterLine.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
        splitterLine.topAnchor.constraint(equalTo: splitterView.bottomAnchor).isActive = true

        let equalSign = UILabel()
        equalSign.textAlignment = .center
        equalSign.textColor = .black
        equalSign.text = "="
        equalSign.font = UIFont(name: ConverterMainViewController.introFontName, size: 14)
        equalSign.backgroundColor = ConverterMainViewController.basicBackgroundColor
        contentView.addSubview(equalSign)
        equalSign.translatesAutoresizingMaskIntoConstraints = false
        equalSign.leftAnchor.constraint(equalTo: splitterView.rightAnchor, constant: 0).isActive = true
        equalSign.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.16).isActive = true
        equalSign.topAnchor.constraint(equalTo: upperContainer.bottomAnchor, constant: 0).isActive = true
        equalSign.bottomAnchor.constraint(equalTo: lowerContainer.topAnchor, constant: 0).isActive = true

        let upperShortNameLabel = UILabel()
        let lowerShortNameLabel = UILabel()

        let upperUnitName = UnitConversionHelper.getUnitItemShortName(logItem.fromUnit)
        upperShortNameLabel.text = upperUnitName
        upperShortNameLabel.textColor = .black
        upperShortNameLabel.textAlignment = .center
        upperShortNameLabel.font = UIFont(name: ConverterMainViewController.introFontName, size: 10)

        let lowerUnitName = UnitConversionHelper.getUnitItemShortName(logItem.toUnit)
        lowerShortNameLabel.text = lowerUnitName
        lowerShortNameLabel.textColor = .black
        lowerShortNameLabel.textAlignment = .center
        lowerShortNameLabel.font = UIFont(name: ConverterMainViewController.introFontName, size: 10)

        let upperDigitLabel = UILabel()
        upperDigitLabel.text = logItem.from
        upperDigitLabel.font = UIFont(name: ConverterMainViewController.fontName, size: 18)
        upperDigitLabel.textColor = QueryLogViewDataSource.queryDigitColor
        upperDigitLabel.textAlignment = .center
        upperDigitLabel.adjustsFontSizeToFitWidth = true
        upperDigitLabel.minimumScaleFactor = 8.0 / 16.0;
        upperContainer.addSubview(upperDigitLabel)
        upperDigitLabel.translatesAutoresizingMaskIntoConstraints = false
        upperDigitLabel.topAnchor.constraint(equalTo: upperContainer.topAnchor, constant: 13).isActive = true
        upperDigitLabel.leftAnchor.constraint(equalTo: upperContainer.leftAnchor, constant: 0).isActive = true
        upperDigitLabel.rightAnchor.constraint(equalTo: upperContainer.rightAnchor, constant: 0).isActive = true
        upperDigitLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true

        upperContainer.addSubview(upperShortNameLabel)
        upperShortNameLabel.translatesAutoresizingMaskIntoConstraints = false
        upperShortNameLabel.leftAnchor.constraint(equalTo: upperContainer.leftAnchor, constant: 25).isActive = true
        upperShortNameLabel.rightAnchor.constraint(equalTo: upperContainer.rightAnchor, constant: -25).isActive = true
        upperShortNameLabel.topAnchor.constraint(equalTo: upperDigitLabel.bottomAnchor, constant: 2).isActive = true
        upperShortNameLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true

        let lowerDigitLabel = UILabel()
        lowerDigitLabel.text = logItem.to
        lowerDigitLabel.font = UIFont(name: ConverterMainViewController.fontName, size: 18)
        lowerDigitLabel.textColor = QueryLogViewDataSource.queryDigitColor
        lowerDigitLabel.textAlignment = .center
        lowerDigitLabel.adjustsFontSizeToFitWidth = true
        lowerDigitLabel.minimumScaleFactor = 8.0 / 16.0;
        lowerContainer.addSubview(lowerDigitLabel)
        lowerDigitLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerDigitLabel.topAnchor.constraint(equalTo: lowerContainer.topAnchor, constant: 12).isActive = true
        lowerDigitLabel.leftAnchor.constraint(equalTo: lowerContainer.leftAnchor, constant: 0).isActive = true
        lowerDigitLabel.rightAnchor.constraint(equalTo: lowerContainer.rightAnchor, constant: 0).isActive = true
        lowerDigitLabel.heightAnchor.constraint(equalToConstant: 14).isActive = true

        lowerContainer.addSubview(lowerShortNameLabel)
        lowerShortNameLabel.translatesAutoresizingMaskIntoConstraints = false
        lowerShortNameLabel.leftAnchor.constraint(equalTo: lowerContainer.leftAnchor, constant: 25).isActive = true
        lowerShortNameLabel.rightAnchor.constraint(equalTo: lowerContainer.rightAnchor, constant: -25).isActive = true
        lowerShortNameLabel.topAnchor.constraint(equalTo: lowerDigitLabel.bottomAnchor, constant: 2).isActive = true
        lowerShortNameLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
    }
}
