import XCTest
@testable import AmConverter

class AmConverterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRoundUpDecimals() {
        let decimal0 = Decimal(string: "-1234")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal0, 5).description, "-1234")

        let decimal1 = Decimal(string: "1234.56")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal1, 5).description, "1234.56")

        let decimal2 = Decimal(string: "-1234.56")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal2, 5).description, "-1234.56")


        let decimal11 = Decimal(string: "1234.567")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal11, 5).description, "1234.57")

        let decimal21 = Decimal(string: "-1234.567")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal21, 5).description, "-1234.57")


        let decimal12 = Decimal(string: "1234.567")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal12, 6).description, "1234.57")

        let decimal22 = Decimal(string: "-1234.567")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal22, 6).description, "-1234.57")


        let decimal13 = Decimal(string: "234.567")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal13, 6).description, "234.567")

        let decimal23 = Decimal(string: "-234.567")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal23, 6).description, "-234.567")



        let decimal14 = Decimal(string: "234.567899")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal14, 8).description, "234.5679")

        let decimal24 = Decimal(string: "-234.567899")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal24, 8).description, "-234.5679")
    }
}
