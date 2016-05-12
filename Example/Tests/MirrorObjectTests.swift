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
        let data = NSString(string: "data").dataUsingEncoding(NSUTF8StringEncoding)!
        let obj1 = MockObject(id: "1", name: "Jack", count: 3, float: 1.1, size: CGSizeMake(1, 2), data: data, createdAt: 123456789)
        let obj2 = MockObject(id: "1", name: "Jack", count: 3, float: 1.1, size: CGSizeMake(1, 2), data: data, createdAt: 123456789)
        
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
        
        obj2.dynamicSize = CGSizeMake(10.1, 12.1)
        obj2.size = CGSizeMake(10.1, 12.1)
        XCTAssertEqual(obj1.dynamicSize, CGSizeMake(10.1, 12.1))
        XCTAssertEqual(obj1.size, CGSizeMake(1, 2))
        
        obj2.dynamicData = NSString(string: "data2").dataUsingEncoding(NSUTF8StringEncoding)!
        obj2.data = NSString(string: "data2").dataUsingEncoding(NSUTF8StringEncoding)!
        XCTAssertEqual(obj1.dynamicData, obj2.data)
        XCTAssertEqual(obj1.data, data)
        
        obj2.dynamicCreatedAt = 234567890
        obj2.createdAt = 234567890
        XCTAssertEqual(obj1.dynamicCreatedAt, 234567890)
        XCTAssertEqual(obj1.createdAt, 123456789)
    }
    
    func testMirrorInit() {
        let data = NSString(string: "data").dataUsingEncoding(NSUTF8StringEncoding)!
        let data2 = NSString(string: "data2").dataUsingEncoding(NSUTF8StringEncoding)!
        let obj1 = MockObject(id: "1", name: "Jack", count: 3, float: 1.1, size: CGSizeMake(1, 2), data: data, createdAt: 123456789)
        let obj2 = MockObject(id: "1", name: "Jack2", count: 4, float: 1.2, size: CGSizeMake(3, 4), data: data2, createdAt: 123456790)
        
        XCTAssertEqual(obj1.dynamicName, "Jack")
        XCTAssertEqual(obj1.name, "Jack")
        XCTAssertEqual(obj1.dynamicCount, 3)
        XCTAssertEqual(obj1.count, 3)
        XCTAssertEqual(obj1.dynamicFloat, 1.1)
        XCTAssertEqual(obj1.float, 1.1)
        XCTAssertEqual(obj1.dynamicSize, CGSizeMake(1, 2))
        XCTAssertEqual(obj1.size, CGSizeMake(1, 2))
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
        XCTAssertEqual(obj1.dynamicSize, CGSizeMake(3, 4))
        XCTAssertEqual(obj1.size, CGSizeMake(1, 2))
        XCTAssertEqual(obj1.dynamicData, data2)
        XCTAssertEqual(obj1.data, data)
        XCTAssertEqual(obj1.dynamicCreatedAt, 123456790)
        XCTAssertEqual(obj1.createdAt, 123456789)
    }
    
    
    func testPerformanceCreateObjects() {
        var objects: [MockObject] = []
        self.measureBlock() {
            for i in 1...1000 {
                objects.append(MockObject(
                    id: "\(i)",
                    name: "name:\(i)",
                    count: i,
                    float: CGFloat(i),
                    size: CGSizeMake(CGFloat(i), CGFloat(i)),
                    data: ("\(i)" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
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
                size: CGSizeMake(CGFloat(i), CGFloat(i)),
                data: ("\(i)" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
                createdAt: Int64(i))
            )
        }

        self.measureBlock() {
            for i in 0..<(objects.count/10) {
                objects[i].dynamicName = "Foo"
                objects[i].dynamicCount = 5
                objects[i].dynamicFloat = 2.3
                objects[i].dynamicSize = CGSizeMake(10.1, 12.1)
                objects[i].dynamicData = NSString(string: "data2").dataUsingEncoding(NSUTF8StringEncoding)!
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
    
}

class MockObject: NSObject, MirrorObject {
    var id: String

    dynamic var dynamicName: String
    dynamic var dynamicCount: Int
    dynamic var dynamicFloat: CGFloat
    dynamic var dynamicSize: CGSize
    dynamic var dynamicData: NSData
    dynamic var dynamicCreatedAt: Int64 // ms
    
    var name: String
    var count: Int
    var float: CGFloat
    var size: CGSize
    var data: NSData
    var createdAt: Int64 // ms
    
    init(id: String, name: String, count: Int, float: CGFloat, size: CGSize, data: NSData, createdAt: Int64) {
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