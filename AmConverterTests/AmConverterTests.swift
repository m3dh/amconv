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
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal0).description, "-1234")

        let decimal1 = Decimal(string: "-1234.34")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal1).description, "-1234.34")

        let decimal2 = Decimal(string: "-1234.345678")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal2).description, "-1234.34568")

        let decimal3 = Decimal(string: "-1234.345543")!
        XCTAssertEqual(ConverterMainViewController.getRoundedNumber(decimal3).description, "-1234.34554")
    }
}
