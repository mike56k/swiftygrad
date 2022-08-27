import XCTest
@testable import swiftygrad

final class swiftygradTests: XCTestCase {
    
    func testBasic() throws {
        let a = Value(2)
        let b = Value(-3)
        let c = Value(10)
        let e = a * b
        let d = e + c
        let f = Value(-2)
        let L = d * f
        L.backward()
        
        XCTAssertEqual(L.data, -8)
        XCTAssertEqual(f.grad, 4)
        XCTAssertEqual(e.grad, -2)
        XCTAssertEqual(d.grad, -2)
        XCTAssertEqual(c.grad, -2)
        XCTAssertEqual(b.grad, -4)
        XCTAssertEqual(a.grad, 6)
    }
    
}
