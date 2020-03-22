import XCTest
@testable import ASE

extension CGFloat {
    var round: CGFloat {
        let digit: CGFloat = 1000000
        return CGFloat(self*digit).rounded()/digit
    }
}

final class ASETests: XCTestCase {
    func testRead() {
        do {
            let url = try Fixture().fileURL(forResource: "Material Palette", ofType: "ase")
            let ase = try ASE(from: url)
            XCTAssertEqual(ase.colorList.allKeys.count, 256)

            let ffffff = ase["ffffff"]
            XCTAssertNotNil(ffffff)
            XCTAssertEqual(ffffff!.redComponent, 1.0)
            XCTAssertEqual(ffffff!.greenComponent, 1.0)
            XCTAssertEqual(ffffff!.blueComponent, 1.0)
            XCTAssertEqual(ffffff!.alphaComponent, 1.0)

            let white = ase["000000"]
            XCTAssertNotNil(white)
            XCTAssertEqual(white!.redComponent, 0)
            XCTAssertEqual(white!.greenComponent, 0)
            XCTAssertEqual(white!.blueComponent, 0)
            XCTAssertEqual(white!.alphaComponent, 1.0)

            let red500 = ase["Red 500 - Primary"]
            XCTAssertNotNil(red500)
            XCTAssertEqual(red500!.redComponent.round, 0.956863)
            XCTAssertEqual(red500!.greenComponent.round, 0.262745)
            XCTAssertEqual(red500!.blueComponent.round, 0.211765)
            XCTAssertEqual(red500!.alphaComponent, 1.0)
        } catch {
            XCTFail("Caught error: \(error)")
        }
    }

    func testWrite() {
        do {
            let url = try Fixture().fileURL(forResource: "Material Palette", ofType: "ase")
            var ase = try ASE(from: url)

            let ffffff = ase["ffffff"]
            XCTAssertNotNil(ffffff)

            ase["ffffff"] = nil
            XCTAssertNil(ase["ffffff"])
        } catch {
            XCTFail("Caught error: \(error)")
        }
    }
}
