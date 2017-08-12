//
//  GeohashTests.swift
//  GeohashTests
//
//  Created by Yuki Nagai on 2017/08/12.
//  Copyright © 2017 Yuki Nagai. All rights reserved.
//

import XCTest
import CoreLocation
@testable import Geohash

final class GeohashTests: XCTestCase {
    func testGeohashQueries() {
        XCTAssertEqual(Geohash.geohashQueries(center: CLLocation(latitude: 35.68944, longitude: 139.69167), radius: 10), ["xn77"..."xn78", "xn76"..."xn77"])
    }
    
    func testEncodeGeohash() {
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: -90, longitude: -180)), "0000000000")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 90, longitude: 180)), "zzzzzzzzzz")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: -90, longitude: 180)), "pbpbpbpbpb")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 90, longitude: -180)), "bpbpbpbpbp")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 37.7853074, longitude: -122.4054274)), "9q8yywe56g")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 38.98719, longitude: -77.250783)), "dqcjf17sy6")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 29.3760648, longitude: 47.9818853)), "tj4p5gerfz")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 78.216667, longitude: 15.55)), "umghcygjj7")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: -54.933333, longitude: -67.616667)), "4qpzmren1k")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: -54, longitude: -67)), "4w2kg3s54y")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: -90, longitude: -180), precision: 6), "000000")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 90, longitude: 180), precision: 20), "zzzzzzzzzzzzzzzzzzzz")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: -90, longitude: 180), precision: 1), "p")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 90, longitude: -180), precision: 5), "bpbpb")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 37.7853074, longitude: -122.4054274), precision: 8), "9q8yywe5")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 38.98719, longitude: -77.250783), precision: 18), "dqcjf17sy6cppp8vfn")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 29.3760648, longitude: 47.9818853), precision: 12), "tj4p5gerfzqu")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: 78.216667, longitude: 15.55), precision: 1), "u")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: -54.933333, longitude: -67.616667), precision: 7), "4qpzmre")
        XCTAssertEqual(Geohash.encodeGeohash(location: CLLocation(latitude: -54, longitude: -67), precision: 9), "4w2kg3s54")
    }
    
    func testBoundingBoxBits() {
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 35, longitude: 0), size: 1000), 28)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 35.645, longitude: 0), size: 1000), 27)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 36, longitude: 0), size: 1000), 27)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), size: 1000), 28)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: -180), size: 1000), 28)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 180), size: 1000), 28)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), size: 8000), 22)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 45, longitude: 0), size: 1000), 27)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 75, longitude: 0), size: 1000), 25)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 75, longitude: 0), size: 2000), 23)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 90, longitude: 0), size: 1000), 1)
        XCTAssertEqual(Geohash.boundingBoxBits(coordinate: CLLocationCoordinate2D(latitude: 90, longitude: 0), size: 2000), 1)
    }
    
    func testDegreesToRadians() {
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 0), 0, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 45), 0.7854, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 90), 1.5708, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 135), 2.3562, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 180), 3.1416, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 225), 3.9270, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 270), 4.7124, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 315), 5.4978, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: 360), 6.2832, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: -45), -0.7854, accuracy: 0.0001)
        XCTAssertEqualWithAccuracy(Geohash.degreesToRadians(degrees: -90), -1.5708, accuracy: 0.0001)
    }
    
    func testGeohashQuery() {
        XCTAssertEqual(Geohash.geohashQuery(geohash: "64m9yn96mx", bits: 6), "60"..."6h")
        XCTAssertEqual(Geohash.geohashQuery(geohash: "64m9yn96mx", bits: 1), "0"..."h")
        XCTAssertEqual(Geohash.geohashQuery(geohash: "64m9yn96mx", bits: 10), "64"..."65")
        XCTAssertEqual(Geohash.geohashQuery(geohash: "6409yn96mx", bits: 11), "640"..."64h")
        XCTAssertEqual(Geohash.geohashQuery(geohash: "64m9yn96mx", bits: 11), "64h"..."64~")
        XCTAssertEqual(Geohash.geohashQuery(geohash: "6", bits: 10), "6"..."6~")
        XCTAssertEqual(Geohash.geohashQuery(geohash: "64z178", bits: 12), "64s"..."64~")
        XCTAssertEqual(Geohash.geohashQuery(geohash: "64z178", bits: 15), "64z"..."64~")
    }
}
