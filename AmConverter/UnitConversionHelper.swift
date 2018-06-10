import Foundation

enum UnitTypes {
    case fuelConsumption
    case length
    case temperature
}

enum UnitItems {
    /* Fuel Consumption, Std: liter/100kilometres */
    case usMilesPerGallon
    case kilometresPerLiter
    case litersPer100Kilometres

    /* Length, Std: millimetre */
    case metre
    case mile

    /* Temperature, Std: celsius */
    case celsius
    case fahrenheit
}

class UnitBiConverter {
    var unitItem: UnitItems
    var unitType: UnitTypes

    var fromStdValue: (Decimal) -> Decimal
    var toStdValue: (Decimal) -> Decimal

    init(
        _ unitType: UnitTypes,
        _ unitItem: UnitItems,
        _ fromStd: @escaping (Decimal) -> Decimal,
        _ toStd: @escaping (Decimal) -> Decimal) {
        self.unitItem = unitItem
        self.unitType = unitType
        self.fromStdValue = fromStd
        self.toStdValue = toStd
    }
}

class UnitConversionHelper {
    /* https://www.calculateme.com */
    private static let converters: [UnitBiConverter] = [
        /* Fuel consumption */
        UnitBiConverter(UnitTypes.fuelConsumption, UnitItems.usMilesPerGallon, {d in 378.5411784 / (1.609344 * d)}, {d in 378.5411784 / (1.609344 * d)}),
        UnitBiConverter(UnitTypes.fuelConsumption, UnitItems.kilometresPerLiter, {d in 100 / d}, {d in 100 / d}),
        UnitBiConverter(UnitTypes.fuelConsumption, UnitItems.litersPer100Kilometres, {d in d}, {d in d}),

        /* Length */
        UnitBiConverter(UnitTypes.length, UnitItems.mile, {d in d / 1609340}, {d in d * 1609340}),
        UnitBiConverter(UnitTypes.length, UnitItems.metre, {d in d / 1000000}, {d in d * 1000000}),

        /* Temperature */
        UnitBiConverter(UnitTypes.temperature, UnitItems.celsius, {d in d}, {d in d}),
        UnitBiConverter(UnitTypes.temperature, UnitItems.fahrenheit, {d in d * 1.8 + 32}, {d in (d - 32) / 1.8}),
    ]

    private static let universalUnitNames: [UnitItems:(String, String)] = [
        UnitItems.usMilesPerGallon: ("US mpg", "miles per U.S. gallon"),
        UnitItems.kilometresPerLiter: ("km/l", "kilometres per liter"),
        UnitItems.litersPer100Kilometres: ("l/100Km", "liters per 100 kilometres"),

        UnitItems.mile: ("mi", "mile"),
        UnitItems.metre: ("m", "mitre"),

        UnitItems.celsius: ("°C", "degrees celsius"),
        UnitItems.fahrenheit: ("°F", "degrees fahrenheit"),

    ]

    static func getUnitTypeDisplayName(_ unitType: UnitTypes) -> String {
        return String(describing: unitType)
    }

    static func getUnitItemDisplayName(_ unitItem: UnitItems) -> String {
        return (UnitConversionHelper.universalUnitNames[unitItem]!).1
    }

    static func getUnitItemShortName(_ unitItem: UnitItems) -> String {
        return (UnitConversionHelper.universalUnitNames[unitItem]!).0
    }

    static func getUnitConvertersByType(_ unitType: UnitTypes) -> [UnitBiConverter] {
        var ret: [UnitBiConverter] = []
        for converter in UnitConversionHelper.converters {
            if converter.unitType == unitType {
                ret.append(converter)
            }
        }

        return ret
    }

    static func getUnitConverterByItem(_ unitItem: UnitItems) -> UnitBiConverter {
        for converter in UnitConversionHelper.converters {
            if converter.unitItem == unitItem {
                return converter
            }
        }

        fatalError("UnitItem \(unitItem) is not expected")
    }

    static func getAllUnitTypes() -> [UnitTypes] {
        return [
            UnitTypes.fuelConsumption,
            UnitTypes.length,
            UnitTypes.temperature
        ]
    }
}
