import SIEVE
import XCTest

final class SIEVETests: XCTestCase {
    func testExample() {
        var cache = Cache<String, String>(capacity: 3)
        
        XCTAssertEqual(cache.count, 0)
        XCTAssertTrue(cache.isEmpty)
        
        cache["a"] = "a"
        cache["b"] = "b"
        XCTAssertEqual(cache.removeValue(forKey: "b"), "b")
        cache["c"] = "c"
        XCTAssertNil(cache.updateValue("x", forKey: "d"))
        XCTAssertNotNil(cache.updateValue("d", forKey: "d"))
        blackHole(cache["a"])
        cache["e"] = "e"
        
        XCTAssertEqual(cache.count, 3)
        XCTAssertFalse(cache.isEmpty)
        
        XCTAssertTrue(cache.contains("a"))
        XCTAssertFalse(cache.contains("b"))
        
        XCTAssertEqual(cache["a"], "a")
        XCTAssertEqual(cache["d"], "d")
        XCTAssertEqual(cache["e"], "e")
        
        XCTAssertNil(cache["b"])
        XCTAssertNil(cache["c"])
    }
}

@inline(never)
fileprivate func blackHole<T>(_ value: T) {}
