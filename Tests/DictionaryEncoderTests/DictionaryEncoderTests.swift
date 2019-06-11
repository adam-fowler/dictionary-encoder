//
//  DictionaryEncoderTests.swift
//
//  Created by Adam Fowler on 2019/06/11.
//

import Foundation
import XCTest
@testable import DictionaryEncoder

class DictionaryDecoderTests: XCTestCase {
    
    func assertEqual(_ e1: Any, _ e2: Any) {
        if let number1 = e1 as? NSNumber, let number2 = e2 as? NSNumber {
            XCTAssertEqual(number1, number2)
        } else if let string1 = e1 as? NSString, let string2 = e2 as? NSString {
            XCTAssertEqual(string1, string2)
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
    func testDecodeEncode<T : Codable>(type: T.Type, dictionary: [String:Any]) {
        do {
            let instance = try DictionaryDecoder().decode(T.self, from: dictionary)
            let newDictionary = try DictionaryEncoder().encode(instance)

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
    

    static var allTests : [(String, (DictionaryDecoderTests) -> () throws -> Void)] {
        return [
            ("testSimpleStructureDecodeEncode", testSimpleStructureDecodeEncode),
            ("testContainingStructureDecodeEncode", testContainingStructureDecodeEncode)
        ]
    }
}
