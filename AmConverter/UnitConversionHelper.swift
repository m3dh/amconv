import Foundation

enum UnitTypes {
    case area
    case fuelConsumption
    case length
    case temperature
    case velocity
    case volume
    case mass
}

enum UnitItems: Int, Codable {
    /* Mass, Std: kilogram */
    case gram
    case tonne
    case usTon
    case kilogram
    case pound // lb: 0.4535924 kg
    case ounceMass // oz: 0.02834949254 kg

    /* Area, Std: square centimeters */
    case squareMeter
    case squareCentimeter
    case squareFoot
    case squareYard
    case squareInch
    case squareKilometer
    case hectare
    case mu
    case acre

    /* Fuel Consumption, Std: liter/100kilometers */
    case usMilesPerGallon
    case kilometresPerLiter
    case litersPer100Kilometers

    /* Length, Std: millimeter */
    case centimeter
    case kilometer
    case meter
    case mile
    case foot
    case yard
    case inch

    /* Temperature, Std: celsius */
    case celsius
    case fahrenheit
    case kelvin

    /* Velocity: Std: m/s */
    case kph
    case mph
    case knot
    case meterPerSecond

    /* Volume, Std: gal */
    case cubicCentimeter
    case cubitFoot
    case cubitInch
    case pint
    case fluidOunce
    case quart
    case gallon
    case impGallon
    case liter
    case milliliter
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
    private static var converters: [UnitBiConverter] = [
        /* Area */
        UnitBiConverter(UnitTypes.area, UnitItems.squareMeter, {d in d * 0.0001}, {d in d / 0.0001}),
        UnitBiConverter(UnitTypes.area, UnitItems.squareCentimeter, {d in d}, {d in d}),
        UnitBiConverter(UnitTypes.area, UnitItems.squareFoot, {d in d * 0.00107639}, {d in d / 0.00107639}),
        UnitBiConverter(UnitTypes.area, UnitItems.squareYard, {d in d * 0.000119599}, {d in d / 0.000119599}),
        UnitBiConverter(UnitTypes.area, UnitItems.squareInch, {d in d * 0.15500031}, {d in d / 0.15500031}),
        UnitBiConverter(UnitTypes.area, UnitItems.squareKilometer, {d in d * 0.0000000001}, {d in d / 0.0000000001}),
        UnitBiConverter(UnitTypes.area, UnitItems.hectare, {d in d * 0.00000001}, {d in d / 0.00000001}),
        UnitBiConverter(UnitTypes.area, UnitItems.mu, {d in d * 0.00000015}, {d in d / 0.00000015}),
        UnitBiConverter(UnitTypes.area, UnitItems.acre, {d in d / 40468564.224}, {d in d * 40468564.224}),

        /* Fuel consumption */
        UnitBiConverter(UnitTypes.fuelConsumption, UnitItems.kilometresPerLiter, {d in 100 / d}, {d in 100 / d}),
        UnitBiConverter(UnitTypes.fuelConsumption, UnitItems.litersPer100Kilometers, {d in d}, {d in d}),
        UnitBiConverter(UnitTypes.fuelConsumption, UnitItems.usMilesPerGallon, {d in 378.5411784 / (1.609344 * d)}, {d in 378.5411784 / (1.609344 * d)}),

        /* Temperature */
        UnitBiConverter(UnitTypes.temperature, UnitItems.celsius, {d in d}, {d in d}),
        UnitBiConverter(UnitTypes.temperature, UnitItems.fahrenheit, {d in d * 1.8 + 32}, {d in (d - 32) / 1.8}),
        UnitBiConverter(UnitTypes.temperature, UnitItems.kelvin, {d in d + 273.15}, {d in d - 273.15}),

        /* Length */
        UnitBiConverter(UnitTypes.length, UnitItems.kilometer, {d in d / 1000000}, {d in d * 1000000}),
        UnitBiConverter(UnitTypes.length, UnitItems.centimeter, {d in d / 10}, {d in d * 10}),
        UnitBiConverter(UnitTypes.length, UnitItems.foot, {d in d / 304.8}, {d in d * 304.8}),
        UnitBiConverter(UnitTypes.length, UnitItems.inch, {d in d / 25.4}, {d in d * 25.4}),
        UnitBiConverter(UnitTypes.length, UnitItems.meter, {d in d / 1000}, {d in d * 1000}),
        UnitBiConverter(UnitTypes.length, UnitItems.mile, {d in d / 1609340}, {d in d * 1609340}),
        UnitBiConverter(UnitTypes.length, UnitItems.yard, {d in d / 914.4}, {d in d * 914.4}),

        /* velocity */
        UnitBiConverter(UnitTypes.velocity, UnitItems.meterPerSecond, {d in d}, {d in d}),
        UnitBiConverter(UnitTypes.velocity, UnitItems.mph, {d in d * 2.23693629}, {d in d / 2.23693629}),
        UnitBiConverter(UnitTypes.velocity, UnitItems.kph, {d in d * 3.6}, {d in d / 3.6}),
        UnitBiConverter(UnitTypes.velocity, UnitItems.knot, {d in d * 1.94384449}, {d in d / 1.94384449}),

        /* volume */
        UnitBiConverter(UnitTypes.volume, UnitItems.cubicCentimeter, {d in d / 0.0002641721}, {d in d * 0.0002641721}),
        UnitBiConverter(UnitTypes.volume, UnitItems.cubitFoot, {d in d / 7.480519}, {d in d * 7.480519}),
        UnitBiConverter(UnitTypes.volume, UnitItems.cubitInch, {d in d / 0.004329004}, {d in d * 0.004329004}),
        UnitBiConverter(UnitTypes.volume, UnitItems.pint, {d in d / 0.125}, {d in d * 0.125}),
        UnitBiConverter(UnitTypes.volume, UnitItems.fluidOunce, {d in d / 0.0078125}, {d in d * 0.0078125}),
        UnitBiConverter(UnitTypes.volume, UnitItems.quart, {d in d / 0.25}, {d in d * 0.25}),
        UnitBiConverter(UnitTypes.volume, UnitItems.gallon, {d in d}, {d in d}),
        UnitBiConverter(UnitTypes.volume, UnitItems.impGallon, {d in d / 1.200950}, {d in d * 1.200950}),
        UnitBiConverter(UnitTypes.volume, UnitItems.liter, {d in d / 0.2641721}, {d in d * 0.2641721}),
        UnitBiConverter(UnitTypes.volume, UnitItems.milliliter, {d in d / 0.0002641721}, {d in d * 0.0002641721}),

        /* mass */
        UnitBiConverter(UnitTypes.mass, UnitItems.gram, {d in d * 1000}, {d in d / 1000}),
        UnitBiConverter(UnitTypes.mass, UnitItems.tonne, {d in d / 1000}, {d in d * 1000}),
        UnitBiConverter(UnitTypes.mass, UnitItems.usTon, {d in d / 907.18474}, {d in d * 907.18474}),
        UnitBiConverter(UnitTypes.mass, UnitItems.kilogram, {d in d}, {d in d}),
        UnitBiConverter(UnitTypes.mass, UnitItems.pound, {d in d / 0.45359237}, {d in d * 0.45359237}),
        UnitBiConverter(UnitTypes.mass, UnitItems.ounceMass, {d in d / 0.028349523125}, {d in d * 0.028349523125}),
    ]

    private static let universalUnitTypeNames: [UnitTypes:String] = [
        UnitTypes.area: "area",
        UnitTypes.fuelConsumption: "gas mileage",
        UnitTypes.length: "length",
        UnitTypes.temperature: "temperature",
        UnitTypes.velocity: "velocity",
        UnitTypes.volume: "volume",
        UnitTypes.mass: "mass",
    ]

    private static let universalUnitNames: [UnitItems:(String, String)] = [
        UnitItems.gram: ("g", "gram"),
        UnitItems.tonne: ("t", "tonne"),
        UnitItems.usTon: ("ton", "ton (U.S. ton)"),
        UnitItems.kilogram: ("kg", "kilogram"),
        UnitItems.pound: ("lb", "pound"),
        UnitItems.ounceMass: ("oz", "ounce"),

        UnitItems.squareMeter: ("m²", "square meter"),
        UnitItems.squareCentimeter: ("cm²", "square centimeter"),
        UnitItems.squareFoot: ("ft²", "square foot"),
        UnitItems.squareYard: ("yd²", "square yard"),
        UnitItems.squareInch: ("in²", "square inch"),
        UnitItems.squareKilometer: ("km²", "square kilometer"),
        UnitItems.hectare: ("ha", "hectare"),
        UnitItems.mu: ("mu", "mu (Chinese area unit)"),
        UnitItems.acre: ("ac", "acre"),

        UnitItems.usMilesPerGallon: ("US mpg", "miles per U.S. gallon"),
        UnitItems.kilometresPerLiter: ("km/l", "kilometres per liter"),
        UnitItems.litersPer100Kilometers: ("l/100Km", "liters per 100 kilometers"),

        UnitItems.centimeter: ("cm", "centimeter"),
        UnitItems.kilometer: ("km", "kilometer"),
        UnitItems.meter: ("m", "meter"),
        UnitItems.mile: ("mi", "mile"),
        UnitItems.yard: ("yd", "yard"),
        UnitItems.foot: ("ft", "foot"),
        UnitItems.inch: ("in", "inch"),

        UnitItems.celsius: ("°C", "degrees celsius"),
        UnitItems.fahrenheit: ("°F", "degrees fahrenheit"),
        UnitItems.kelvin: ("°K", "degrees kelvin"),

        UnitItems.mph: ("mph", "miles per hour"),
        UnitItems.kph: ("kph", "kilometers per hour"),
        UnitItems.knot: ("kn", "knot"),
        UnitItems.meterPerSecond: ("m/s", "meters per second"),

        UnitItems.cubicCentimeter: ("cm³", "cubic centimeter (cc)"),
        UnitItems.cubitFoot: ("ft³", "cubic foot"),
        UnitItems.cubitInch: ("in³", "cubic inch"),
        UnitItems.pint: ("pt", "pint"),
        UnitItems.fluidOunce: ("fl oz", "fluid ounce"),
        UnitItems.quart: ("qt", "quart"),
        UnitItems.gallon: ("gal", "gallon (U.S.)"),
        UnitItems.impGallon: ("imp. gal", "imperial gallon"),
        UnitItems.liter: ("l", "liter"),
        UnitItems.milliliter: ("ml", "milli-liter"),
    ]

    static func initialize() {
        UnitConversionHelper.converters.sort(by: { l,r in
            if l.unitType == r.unitType {
                return UnitConversionHelper.getUnitItemDisplayName(l.unitItem) < UnitConversionHelper.getUnitItemDisplayName(r.unitItem)
            } else {
                return UnitConversionHelper.getUnitTypeDisplayName(l.unitType) < UnitConversionHelper.getUnitTypeDisplayName(r.unitType)
            }
        })
    }

    static func getUnitTypeDisplayName(_ unitType: UnitTypes) -> String {
        return UnitConversionHelper.universalUnitTypeNames[unitType]!
    }

    static func getUnitItemDisplayName(_ unitItem: UnitItems) -> String {
        return (UnitConversionHelper.universalUnitNames[unitItem]!).1
    }

    static func getUnitItemShortName(_ unitItem: UnitItems) -> String {
        return (UnitConversionHelper.universalUnitNames[unitItem]!).0
    }

    static func getUnitItemsByType(_ unitType: UnitTypes) -> [UnitItems] {
        var ret: [UnitItems] = []
        for converter in UnitConversionHelper.converters {
            if converter.unitType == unitType {
                ret.append(converter.unitItem)
            }
        }

        return ret
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
        var ret: [UnitTypes] = []
        for converter in UnitConversionHelper.converters {
            if !ret.contains(converter.unitType) {
                ret.append(converter.unitType)
            }
        }

        return ret
    }
}
