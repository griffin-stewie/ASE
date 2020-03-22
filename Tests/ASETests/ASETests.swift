import XCTest
@testable import ASE

extension CGFloat {
    var round: CGFloat {
        let digit: CGFloat = 1000000
        return CGFloat(self*digit).rounded()/digit
    }
}

final class ASETests: XCTestCase {
    func testLoad() {
        do {
            let url = try Fixture().fileURL(forResource: "Material Palette", ofType: "ase")
            let colorlist = ASEParser().parse(url: url)
            XCTAssertNotNil(colorlist)
            XCTAssertEqual(colorlist!.allKeys.count, 256)

            let ffffff = colorlist!.color(withKey: "ffffff")
            XCTAssertNotNil(ffffff)
            XCTAssertEqual(ffffff!.redComponent, 1.0)
            XCTAssertEqual(ffffff!.greenComponent, 1.0)
            XCTAssertEqual(ffffff!.blueComponent, 1.0)
            XCTAssertEqual(ffffff!.alphaComponent, 1.0)

            let white = colorlist!.color(withKey: "000000")
            XCTAssertNotNil(white)
            XCTAssertEqual(white!.redComponent, 0)
            XCTAssertEqual(white!.greenComponent, 0)
            XCTAssertEqual(white!.blueComponent, 0)
            XCTAssertEqual(white!.alphaComponent, 1.0)

            let red500 = colorlist!.color(withKey: "Red 500 - Primary")
            XCTAssertNotNil(red500)
            XCTAssertEqual(red500!.redComponent.round, 0.956863)
            XCTAssertEqual(red500!.greenComponent.round, 0.262745)
            XCTAssertEqual(red500!.blueComponent.round, 0.211765)
            XCTAssertEqual(red500!.alphaComponent, 1.0)

        } catch {
            XCTFail("Caught error: \(error)")
        }
    }
}
