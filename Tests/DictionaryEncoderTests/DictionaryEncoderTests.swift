//
//  DictionaryEncoderTests.swift
//
//  Created by Adam Fowler on 2019/06/11.
//

import Foundation
import XCTest
@testable import DictionaryEncoder

class DictionaryEncoderTests: XCTestCase {

    func assertEqual(_ e1: Any, _ e2: Any) {
        print("\(type(of:e1)) == \(type(of:e2))")
        if let number1 = e1 as? NSNumber, let number2 = e2 as? NSNumber {
            XCTAssertEqual(number1, number2)
        } else if let string1 = e1 as? NSString, let string2 = e2 as? NSString {
            XCTAssertEqual(string1, string2)
        } else if let data1 = e1 as? Data, let data2 = e2 as? Data {
            XCTAssertEqual(data1.base64EncodedString(), data2.base64EncodedString())
        } else if let date1 = e1 as? NSDate, let date2 = e2 as? NSDate {
            XCTAssertEqual(date1, date2)
        } else if let d1 = e1 as? [String:Any], let d2 = e2 as? [String:Any] {
            assertDictionaryEqual(d1, d2)
        } else if let a1 = e1 as? [Any], let a2 = e2 as? [Any] {
            assertArrayEqual(a1, a2)
        } else if let desc1 = e1 as? CustomStringConvertible, let desc2 = e2 as? CustomStringConvertible {
            XCTAssertEqual(desc1.description, desc2.description)
        }
    }

    func assertArrayEqual(_ a1: [Any], _ a2: [Any]) {
        XCTAssertEqual(a1.count, a2.count)
        for i in 0..<a1.count {
            assertEqual(a1[i], a2[i])
        }
    }

    func assertDictionaryEqual(_ d1: [String:Any], _ d2: [String:Any]) {
        XCTAssertEqual(d1.count, d2.count)

        for e1 in d1 {
            if let e2 = d2[e1.key] {
                assertEqual(e1.value, e2)
            } else {
                XCTFail("Missing key \(e1.key)")
            }
        }
    }

    /// helper test function to use throughout all the decode/encode tests
    func testDecodeEncode<T : Codable>(type: T.Type, dictionary: [String:Any], decoder: DictionaryDecoder = DictionaryDecoder(), encoder: DictionaryEncoder = DictionaryEncoder()) {
        do {
            let instance = try decoder.decode(T.self, from: dictionary)
            let newDictionary = try encoder.encode(instance)

            // check dictionaries are the same
            assertEqual(dictionary, newDictionary)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testSimpleStructureDecodeEncode() {
        struct Test : Codable {
            let a : Int
            let b : String
        }
        let dictionary: [String:Any] = ["a":4, "b":"Hello"]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }
    
    func testBaseTypesDecodeEncode() {
        struct Test : Codable {
            let bool : Bool
            let int : Int
            let int8 : Int8
            let int16 : Int16
            let int32 : Int32
            let int64 : Int64
            let uint : UInt
            let uint8 : UInt8
            let uint16 : UInt16
            let uint32 : UInt32
            let uint64 : UInt64
            let float : Float
            let double : Double
        }
        let dictionary: [String:Any] = ["bool":true, "int":0, "int8":1, "int16":2, "int32":-3, "int64":4, "uint":10, "uint8":11, "uint16":12, "uint32":13, "uint64":14, "float":1.25, "double":0.23]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }

    func testContainingStructureDecodeEncode() {
        struct Test2 : Codable {
            let a : Int
            let b : String
        }
        struct Test : Codable {
            let t : Test2
        }
        let dictionary: [String:Any] = ["t": ["a":4, "b":"Hello"]]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }

    func testEnumDecodeEncode() {
        struct Test : Codable {
            enum TestEnum : String, Codable {
                case first = "First"
                case second = "Second"
            }
            let a : TestEnum
        }
        let dictionary: [String:Any] = ["a":"First"]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }
    
    func testArrayDecodeEncode() {
        struct Test : Codable {
            let a : [Int]
        }
        let dictionary: [String:Any] = ["a":[1,2,3,4,5]]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }
    
    func testArrayOfStructuresDecodeEncode() {
        struct Test2 : Codable {
            let b : String
        }
        struct Test : Codable {
            let a : [Test2]
        }
        let dictionary: [String:Any] = ["a":[["b":"hello"], ["b":"goodbye"]]]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }

    func testDictionaryDecodeEncode() {
        struct Test : Codable {
            let a : [String:Int]
        }
        let dictionary: [String:Any] = ["a":["key":45]]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }
    
    func testEnumDictionaryDecodeEncode() {
        struct Test : Codable {
            enum TestEnum : String, Codable {
                case first = "First"
                case second = "Second"
            }
            let a : [TestEnum:Int]
        }
        // at the moment dictionaries with enums return an array.
        let dictionary: [String:Any] = ["a":["First",45]]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }
    
    func testDateDecodeEncode() {
        struct Test : Codable {
            let date : Date
        }
        let dictionary: [String:Any] = ["date":29872384673]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        let decoder = DictionaryDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let encoder = DictionaryEncoder()
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let dictionary2: [String:Any] = ["date":"2001-07-21T14:31:45.100Z"]
        testDecodeEncode(type: Test.self, dictionary: dictionary2, decoder: decoder, encoder: encoder)
    }
    
    func testDataDecodeEncode() {
        struct Test : Codable {
            let data : Data
        }
        let dictionary: [String:Any] = ["data":"Hello, world".data(using:.utf8)!]
        testDecodeEncode(type: Test.self, dictionary: dictionary)

        let decoder = DictionaryDecoder()
        decoder.dataDecodingStrategy = .base64
        let encoder = DictionaryEncoder()
        encoder.dataEncodingStrategy = .base64
        
        let dictionary2: [String:Any] = ["data":"Hello, world".data(using:.utf8)!.base64EncodedString()]
        testDecodeEncode(type: Test.self, dictionary: dictionary2, decoder: decoder, encoder: encoder)
    }
    
    func testUrlDecodeEncode() {
        struct Test : Codable {
            let url : URL
        }
        let dictionary: [String:Any] = ["url":"www.google.com"]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }
    
    func testDecodeErrors<T : Codable>(type: T.Type, dictionary: [String:Any], decoder: DictionaryDecoder = DictionaryDecoder()) {
        do {
            _ = try DictionaryDecoder().decode(T.self, from: dictionary)
            XCTFail("Decoder did not throw an error when it should have")
        } catch {
            
        }
    }
    
    func testFloatOverflowDecodeErrors() {
        struct Test : Codable {
            let float : Float
        }
        let dictionary: [String:Any] = ["float":Double.infinity]
        testDecodeErrors(type: Test.self, dictionary: dictionary)
    }
    
    func testMissingKeyDecodeErrors() {
        struct Test : Codable {
            let a : Int
            let b : Int
        }
        let dictionary: [String:Any] = ["b":1]
        testDecodeErrors(type: Test.self, dictionary: dictionary)
    }
    
    func testInvalidValueDecodeErrors() {
        struct Test : Codable {
            let a : Int
        }
        let dictionary: [String:Any] = ["b":"test"]
        testDecodeErrors(type: Test.self, dictionary: dictionary)
    }
    
    func testNestedContainer() {
        struct Test : Codable {
            let firstname : String
            let surname : String
            let age : Int
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                age = try container.decode(Int.self, forKey: .age)
                let fullname = try container.nestedContainer(keyedBy: AdditionalKeys.self, forKey: .name)
                firstname = try fullname.decode(String.self, forKey: .firstname)
                surname = try fullname.decode(String.self, forKey: .surname)
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(age, forKey: .age)
                var fullname = container.nestedContainer(keyedBy: AdditionalKeys.self, forKey: .name)
                try fullname.encode(firstname, forKey: .firstname)
                try fullname.encode(surname, forKey: .surname)
            }
            
            private enum CodingKeys : String, CodingKey {
                case name = "name"
                case age = "age"
            }
            
            private enum AdditionalKeys : String, CodingKey {
                case firstname = "firstname"
                case surname = "surname"
            }
        }
        
        let dictionary: [String:Any] = ["age":25, "name":["firstname":"John", "surname":"Smith"]]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }
    
    func testSupercoder() {
        class Base : Codable {
            let a : Int
        }
        class Test : Base {
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                b = try container.decode(String.self, forKey: .b)
                let superDecoder = try container.superDecoder(forKey: .super)
                try super.init(from: superDecoder)
            }
            
            override func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(b, forKey: .b)
                let superEncoder = container.superEncoder(forKey: .super)
                try super.encode(to: superEncoder)
            }
            let b : String

            private enum CodingKeys : String, CodingKey {
                case b = "B"
                case `super` = "Super"
            }
        }

        let dictionary: [String:Any] = ["B":"Test", "Super":["a":648]]
        testDecodeEncode(type: Test.self, dictionary: dictionary)
    }
    
    static var allTests : [(String, (DictionaryEncoderTests) -> () throws -> Void)] {
        return [
            ("testSimpleStructureDecodeEncode", testSimpleStructureDecodeEncode),
            ("testBaseTypesDecodeEncode", testBaseTypesDecodeEncode),
            ("testContainingStructureDecodeEncode", testContainingStructureDecodeEncode),
            ("testEnumDecodeEncode", testEnumDecodeEncode),
            ("testArrayDecodeEncode", testArrayDecodeEncode),
            ("testArrayOfStructuresDecodeEncode", testArrayOfStructuresDecodeEncode),
            ("testDictionaryDecodeEncode", testDictionaryDecodeEncode),
            ("testEnumDictionaryDecodeEncode", testEnumDictionaryDecodeEncode),
            ("testDateDecodeEncode", testDateDecodeEncode),
            ("testDataDecodeEncode", testDataDecodeEncode),
            ("testUrlDecodeEncode", testUrlDecodeEncode),
            ("testFloatOverflowDecodeErrors", testFloatOverflowDecodeErrors),
            ("testInvalidValueDecodeErrors", testInvalidValueDecodeErrors),
            ("testMissingKeyDecodeErrors", testMissingKeyDecodeErrors),
            ("testNestedContainer", testNestedContainer),
            ("testSupercoder", testSupercoder)
        ]
    }
}
