import UIKit
import XCTest
import MirrorObject

class MirrorObjectTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testMirror() {
        let data = "data".data(using: String.Encoding.utf8)!
        let obj1 = MockObject(id: "1", name: "Jack", count: 3, float: 1.1, size: CGSize(width: 1, height: 2), data: data, createdAt: 123456789)
        let obj2 = MockObject(id: "1", name: "Jack", count: 3, float: 1.1, size: CGSize(width: 1, height: 2), data: data, createdAt: 123456789)
        
        obj2.dynamicName = "Foo"
        obj2.name = "Foo"
        XCTAssertEqual(obj1.dynamicName, "Foo")
        XCTAssertEqual(obj1.name, "Jack")
        
        obj2.dynamicCount = 5
        obj2.count = 5
        XCTAssertEqual(obj1.dynamicCount, 5)
        XCTAssertEqual(obj1.count, 3)
        
        obj2.dynamicFloat = 2.3
        obj2.float = 2.3
        XCTAssertEqual(obj1.dynamicFloat, 2.3)
        XCTAssertEqual(obj1.float, 1.1)
        
        obj2.dynamicSize = CGSize(width: 10.1, height: 12.1)
        obj2.size = CGSize(width: 10.1, height: 12.1)
        XCTAssertEqual(obj1.dynamicSize, CGSize(width: 10.1, height: 12.1))
        XCTAssertEqual(obj1.size, CGSize(width: 1, height: 2))
        
        obj2.dynamicData = "data2".data(using: String.Encoding.utf8)!
        obj2.data = "data2".data(using: String.Encoding.utf8)!
        XCTAssertEqual(obj1.dynamicData, obj2.data)
        XCTAssertEqual(obj1.data, data)
        
        obj2.dynamicCreatedAt = 234567890
        obj2.createdAt = 234567890
        XCTAssertEqual(obj1.dynamicCreatedAt, 234567890)
        XCTAssertEqual(obj1.createdAt, 123456789)
    }
    
    func testMirrorInit() {
        let data = "data".data(using: String.Encoding.utf8)!
        let data2 = "data2".data(using: String.Encoding.utf8)!
        let obj1 = MockObject(id: "1", name: "Jack", count: 3, float: 1.1, size: CGSize(width: 1, height: 2), data: data, createdAt: 123456789)
        let obj2 = MockObject(id: "1", name: "Jack2", count: 4, float: 1.2, size: CGSize(width: 3, height: 4), data: data2, createdAt: 123456790)
        
        XCTAssertEqual(obj1.dynamicName, "Jack")
        XCTAssertEqual(obj1.name, "Jack")
        XCTAssertEqual(obj1.dynamicCount, 3)
        XCTAssertEqual(obj1.count, 3)
        XCTAssertEqual(obj1.dynamicFloat, 1.1)
        XCTAssertEqual(obj1.float, 1.1)
        XCTAssertEqual(obj1.dynamicSize, CGSize(width: 1, height: 2))
        XCTAssertEqual(obj1.size, CGSize(width: 1, height: 2))
        XCTAssertEqual(obj1.dynamicData, data)
        XCTAssertEqual(obj1.data, data)
        XCTAssertEqual(obj1.dynamicCreatedAt, 123456789)
        XCTAssertEqual(obj1.createdAt, 123456789)
        
        obj2.mirror("dynamicName")
        obj2.mirror("dynamicCount")
        obj2.mirror("dynamicFloat")
        obj2.mirror("dynamicSize")
        obj2.mirror("dynamicData")
        obj2.mirror("dynamicCreatedAt")
        XCTAssertEqual(obj1.dynamicName, "Jack2")
        XCTAssertEqual(obj1.name, "Jack")
        XCTAssertEqual(obj1.dynamicCount, 4)
        XCTAssertEqual(obj1.count, 3)
        XCTAssertEqual(obj1.dynamicFloat, 1.2)
        XCTAssertEqual(obj1.float, 1.1)
        XCTAssertEqual(obj1.dynamicSize, CGSize(width: 3, height: 4))
        XCTAssertEqual(obj1.size, CGSize(width: 1, height: 2))
        XCTAssertEqual(obj1.dynamicData, data2)
        XCTAssertEqual(obj1.data, data)
        XCTAssertEqual(obj1.dynamicCreatedAt, 123456790)
        XCTAssertEqual(obj1.createdAt, 123456789)
    }
    
    func testPerformanceCreateObjects() {
        var objects: [MockObject] = []
        self.measure() {
            for i in 1...1000 {
                objects.append(MockObject(
                    id: "\(i)",
                    name: "name:\(i)",
                    count: i,
                    float: CGFloat(i),
                    size: CGSize(width: CGFloat(i), height: CGFloat(i)),
                    data: ("\(i)" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                    createdAt: Int64(i))
                )
            }
        }
    }
    
    func testPerformanceMirror() {
        var objects: [MockObject] = []
        for i in 1...1000 {
            objects.append(MockObject(
                id: "\(i/2)",
                name: "name:\(i)",
                count: i,
                float: CGFloat(i),
                size: CGSize(width: CGFloat(i), height: CGFloat(i)),
                data: ("\(i)" as NSString).data(using: String.Encoding.utf8.rawValue)!,
                createdAt: Int64(i))
            )
        }

        self.measure() {
            for i in 0..<(objects.count/10) {
                objects[i].dynamicName = "Foo"
                objects[i].dynamicCount = 5
                objects[i].dynamicFloat = 2.3
                objects[i].dynamicSize = CGSize(width: 10.1, height: 12.1)
                objects[i].dynamicData = "data2".data(using: String.Encoding.utf8)!
                objects[i].dynamicCreatedAt = 234567890
            }
        }
    }
    
    func testNestedObject() {
        let parent1 = ParentMockObject(id: "1", child: ChildMockObject(type: "normal", value: 100, createdAt: 12345))
        let parent2 = ParentMockObject(id: "1", child: ChildMockObject(type: "normal", value: 100, createdAt: 12345))
        
        parent2.dynamicChild.value = 90
        
        XCTAssertEqual(parent1.dynamicChild.value, 90)
        
    }
    
    func testExcludProperties() {
        let data = "data".data(using: String.Encoding.utf8)!
        let obj1 = MockObject(id: "1", name: "Jack", count: 3, float: 1.1, size: CGSize(width: 1, height: 2), data: data, createdAt: 123456789)
        let obj2 = MockObject(id: "1", name: "Jack", count: 3, float: 1.1, size: CGSize(width: 1, height: 2), data: data, createdAt: 123456789)
        
        obj2.excP1 = 20
        obj2.excP2 = "change"
        XCTAssertEqual(obj1.excP1, 10)
        XCTAssertEqual(obj1.excP2, "p2")
    }
    
    func testMirrorDisable() {
        let data = "data".data(using: String.Encoding.utf8)!
        let obj1 = MockObject(id: "dummy", name: "Jack", count: 3, float: 1.1, size: CGSize(width: 1, height: 2), data: data, createdAt: 123456789)
        let obj2 = MockObject(id: "dummy", name: "Jack", count: 3, float: 1.1, size: CGSize(width: 1, height: 2), data: data, createdAt: 123456789)
        
        obj2.dynamicName = "Foo"
        XCTAssertEqual(obj1.dynamicName, "Jack")
    }
}

class MockObject: NSObject, MirrorObject {
    var id: String

    dynamic var dynamicName: String
    dynamic var dynamicCount: Int
    dynamic var dynamicFloat: CGFloat
    dynamic var dynamicSize: CGSize
    dynamic var dynamicData: Data
    dynamic var dynamicCreatedAt: Int64 // ms
    
    dynamic var excP1: Int = 10
    dynamic var excP2: String = "p2"
    
    dynamic var doCrash: String {
        assertionFailure("shouldn't access here")
        return ""
    }

    var name: String
    var count: Int
    var float: CGFloat
    var size: CGSize
    var data: Data
    var createdAt: Int64 // ms
    
    init(id: String, name: String, count: Int, float: CGFloat, size: CGSize, data: Data, createdAt: Int64) {
        self.id = id
        self.dynamicName = name
        self.dynamicCount = count
        self.dynamicFloat = float
        self.dynamicSize = size
        self.dynamicData = data
        self.dynamicCreatedAt = createdAt
        
        self.name = name
        self.count = count
        self.float = float
        self.size = size
        self.data = data
        self.createdAt = createdAt
        
        super.init()
        self.startMirroring()
    }
    
    deinit {
        self.stopMirroring()
    }
    
    func identifier() -> String {
        return id
    }
    
    func excludeProperties() -> [String] {
        return ["excP2", "excP1"]
    }

    func isMirrorDisabled() -> Bool {
        return id == "dummy"
    }
}


class ParentMockObject: NSObject, MirrorObject {
    var id : String
    dynamic var dynamicChild: ChildMockObject
    
    init(id: String, child: ChildMockObject) {
        self.id = id
        self.dynamicChild = child
        
        super.init()
        self.startMirroring()
    }
    
    deinit {
        self.stopMirroring()
    }
    
    func identifier() -> String {
        return id
    }
}

class ChildMockObject: NSObject, MirrorObject {
    dynamic var type: String
    dynamic var value: Int
    var createdAt: Int64
    init(type: String, value: Int, createdAt: Int64) {
        self.type      = type
        self.value     = value
        self.createdAt = createdAt

        super.init()
    }
}
