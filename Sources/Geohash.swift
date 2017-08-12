//
//  Geohash.swift
//  Geohash
//
//  Created by Yuki Nagai on 2017/08/12.
//  Copyright © 2017 Yuki Nagai. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - Public
/**
 Calculates a set of queries to fully contain a given circle. A query is a [start, end] pair
 where any geohash is guaranteed to be lexiographically larger then start and smaller than end.
 
 - parameter center: The center of the circle.
 - parameter radius: The radius of the circle in kilo meters.
 - returns: An array of geohashes containing a [start, end] pair.
 */
public func geohashQueries(center: CLLocation, radius: CLLocationDistance) -> [ClosedRange<String>] {
    let radius = radius * 1000
    let queryBits = max(1, boundingBoxBits(coordinate: center.coordinate, size: radius))
    let geohashPrecision = Int(ceil(Double(queryBits) / Double(Constants.bitsPerChar)))
    let coordinates = boundingBoxCoordinates(center: center.coordinate, radius: radius)
    let queries = coordinates.map { geohashQuery(geohash: encodeGeohash(location: $0, precision: geohashPrecision), bits: queryBits) }
    // remove duplicates
    do {
        var result = [ClosedRange<String>]()
        for query in queries {
            if result.contains(query) {
                continue
            }
            result.append(query)
        }
        return result
    }
}

/**
 Generates a geohash of the specified precision/string length from the  [latitude, longitude] pair, specified as an array.
 
 - parameter location: The [latitude, longitude] pair to encode into a geohash.
 - parameter precision: The length of the geohash to create. If no precision is specified, the global default is used.
 - returns: The geohash of the inputted location.
 */
public func encodeGeohash(location: CLLocation, precision: Int = Constants.geohashPrecision) -> String {
    let precision: Int = {
        if precision <= 0 {
            return 1
        }
        if precision > 22 {
            return 22
        }
        return precision
    }()
    let latitudeRange = DegreesRange(lowerBound: -90, upperBound: 90)
    let longitudeRange = DegreesRange(lowerBound: -180, upperBound: 180)
    return {
        var hash = ""
        var hashValue = 0
        var bits = 0
        var even = true
        while hash.characters.count < precision {
            let value = even ? location.coordinate.longitude : location.coordinate.latitude
            let range = even ? longitudeRange : latitudeRange
            let middle = (range.lowerBound + range.upperBound) / 2
            if value > middle {
                hashValue = (hashValue << 1) + 1
                range.lowerBound = middle
            } else {
                hashValue = (hashValue << 1) + 0
                range.upperBound = middle
            }
            even = !even
            if bits < 4 {
                bits += 1
            } else {
                bits = 0
                hash += String(Constants.base32[hashValue])
                hashValue = 0
            }
        }
        return hash
    }()
}

// MARK: - Internal
enum Constants {
    /// Characters used in location geohashes
    static let base32: String = "0123456789bcdefghjkmnpqrstuvwxyz"
    
    // Number of bits per geohash character
    static let bitsPerChar: Int = 5
    
    /**
     The following value assumes a polar radius of
     ```
     var g_EARTH_POL_RADIUS = 6356752.3;
     ```
     The formulate to calculate g_E2 is
     ```
     g_E2 == (g_EARTH_EQ_RADIUS^2-g_EARTH_POL_RADIUS^2)/(g_EARTH_EQ_RADIUS^2)
     ```
     The exact value is used here to avoid rounding errors
     */
    static let e2: Double = 0.00669447819799
    
    /// Equatorial radius of the earth in meters
    static let earthEquatorialRadius: Double = 6378137.0
    
    /// The meridional circumference of the earth in meters
    static let earthMeridionalCircumference: Double = 40007860
    
    /// Cutoff for rounding errors on double calculations
    static let epsilon: Double = 1e-12
    
    /// Default geohash length
    static let geohashPrecision: Int = 10
    
    /// Maximum length of a geohash in bits
    static let maximumBitsPrecision: Int = 22 * Constants.bitsPerChar
    
    /// Length of a degree latitude at the equator
    static let metersPerDegreeLatitude: Double = 110574
}

func boundingBoxBits(coordinate: CLLocationCoordinate2D, size: CLLocationDistance) -> Int {
    let latitudeDeltaDegrees = size / Constants.metersPerDegreeLatitude
    let latitudeNorth = min(90, coordinate.latitude + latitudeDeltaDegrees)
    let latitudeSouth = max(-90, coordinate.latitude - latitudeDeltaDegrees)
    let bitsLatitude = Int(floor(latitudeBits(for: size))) * 2
    let bitsLongitudeNorth = Int(floor(longitudeBits(for: size, latitude: latitudeNorth))) * 2 - 1
    let bitsLongitudeSouth = Int(floor(longitudeBits(for: size, latitude: latitudeSouth))) * 2 - 1
    return min(bitsLatitude, bitsLongitudeNorth, bitsLongitudeSouth, Constants.maximumBitsPrecision)
}

/**
 Calculates eight points on the bounding box and the center of a given circle. At least one
 geohash of these nine coordinates, truncated to a precision of at most radius, are guaranteed
 to be prefixes of any geohash that lies within the circle.
 
 - parameter center: The center of the circle.
 - parameter radius: The radius of the circle.
 - returns: The eight bounding box points.
 */
func boundingBoxCoordinates(center: CLLocationCoordinate2D, radius: CLLocationDistance) -> [CLLocation] {
    let latitudeDegrees = radius / Constants.metersPerDegreeLatitude
    let latitudeNorth = min(90, center.latitude + latitudeDegrees)
    let latitudeSouth = max(-90, center.latitude - latitudeDegrees)
    let longitudeDegreesNorth = metersToLongitudeDegrees(distance: radius, latitude: latitudeNorth)
    let longitudeDegreesSouth = metersToLongitudeDegrees(distance: radius, latitude: latitudeSouth)
    let longitudeDegrees = max(longitudeDegreesNorth, longitudeDegreesSouth)
    return [
        CLLocation(latitude: center.latitude, longitude: center.longitude),
        CLLocation(latitude: center.latitude, longitude: wrapLongitude(center.longitude - longitudeDegrees)),
        CLLocation(latitude: center.latitude, longitude: wrapLongitude(center.longitude + longitudeDegrees)),
        CLLocation(latitude: latitudeNorth, longitude: center.longitude),
        CLLocation(latitude: latitudeNorth, longitude: wrapLongitude(center.longitude - longitudeDegrees)),
        CLLocation(latitude: latitudeNorth, longitude: wrapLongitude(center.longitude + longitudeDegrees)),
        CLLocation(latitude: latitudeSouth, longitude: center.longitude),
        CLLocation(latitude: latitudeSouth, longitude: wrapLongitude(center.longitude - longitudeDegrees)),
        CLLocation(latitude: latitudeSouth, longitude: wrapLongitude(center.longitude + longitudeDegrees))
    ]
}

/**
 Converts degrees to radians.
 
 - parameter degrees: The number of degrees to be converted to radians.
 - returns: The number of radians equal to the inputted number of degrees.
 */
func degreesToRadians(degrees: Double) -> Double {
    return degrees * Double.pi / 180
}

/**
 * Calculates the bounding box query for a geohash with x bits precision.
 *
 * @param {string} geohash The geohash whose bounding box query to generate.
 * @param {number} bits The number of bits of precision.
 * @return {Array.<string>} A [start, end] pair of geohashes.
 */
/***/
func geohashQuery(geohash: String, bits: Int) -> ClosedRange<String> {
    let precision = Int(ceil(Double(bits) / Double(Constants.bitsPerChar)))
    if geohash.characters.count < precision {
        return geohash...(geohash + "~")
    }
    let geohash = geohash.substring(to: precision)
    let base = geohash.substring(to: geohash.characters.count - 1)
    let lastValue = Constants.base32.characterIndex(of: geohash[geohash.characters.count - 1])
    let significantBits = bits - (base.characters.count * Constants.bitsPerChar)
    let unusedBits = Constants.bitsPerChar - significantBits
    // delete unused bits
    let startValue = (lastValue >> unusedBits) << unusedBits
    let endValue = startValue + (1 << unusedBits)
    if endValue > 31 {
        return (base + String(Constants.base32[startValue]))...(base + "~")
    } else {
        return (base + String(Constants.base32[startValue]))...(base + String(Constants.base32[endValue]))
    }
}

/**
 Calculates the bits necessary to reach a given resolution, in meters, for the latitude.
 
 - parameter resolution: The bits necessary to reach a given resolution, in meters.
 - returns: The bits necessary to reach a given resolution, in meters.
 */
func latitudeBits(for resolution: Double) -> Double {
    return min(log2(Constants.earthMeridionalCircumference / 2 / resolution), Double(Constants.maximumBitsPrecision))
}

/**
 Calculates the bits necessary to reach a given resolution, in meters, for the longitude at a given latitude.
 
 - parameter resolution: The desired resolution.
 - parameter latitude: The latitude used in the conversion.
 - returns: The bits necessary to reach a given resolution, in meters.
 */
func longitudeBits(for resolution: Double, latitude: Double) -> Double {
    let degrees = metersToLongitudeDegrees(distance: resolution, latitude: latitude)
    return (abs(degrees) > 0.000001) ? max(1, log2(360 / degrees)) : 1
}


/**
 Calculates the number of degrees a given distance is at a given latitude.
 
 - parameter distance: The distance to convert.
 - parameter latitude: The latitude at which to calculate.
 - returns: The number of degrees the distance corresponds to.
 */
func metersToLongitudeDegrees(distance: Double, latitude: Double) -> Double {
    let radians = degreesToRadians(degrees: latitude)
    let number = cos(radians) * Constants.earthEquatorialRadius * Double.pi / 180
    let denomination = 1 / sqrt(1 - Constants.e2 * sin(radians) * sin(radians))
    let deltaDegrees = number * denomination
    if deltaDegrees < Constants.epsilon {
        return distance > 0 ? 360 : 0
    } else {
        return min(360, distance / deltaDegrees)
    }
}

/**
 * Wraps the longitude to [-180,180].
 *
 * @param {number} longitude The longitude to wrap.
 * @return {number} longitude The resulting longitude.
 */
/***/
func wrapLongitude(_ longitude: CLLocationDegrees) -> CLLocationDegrees {
    if longitude <= 180 && longitude >= -180 {
        return longitude
    }
    let adjusted = longitude + 180
    if adjusted > 0 {
        return adjusted.truncatingRemainder(dividingBy: 360) - 180
    } else {
        return 180 - (-adjusted.truncatingRemainder(dividingBy: 360))
    }
}

extension String {
    subscript(index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
    
    func substring(to index: Int) -> String {
        return self.substring(to: self.index(self.startIndex, offsetBy: index))
    }
    
    func characterIndex(of character: Character) -> Int {
        if let index = self.characters.index(of: character) {
            return self.distance(from: self.startIndex, to: index)
        } else {
            return -1
        }
    }
}

final class DegreesRange {
    var lowerBound: CLLocationDegrees
    var upperBound: CLLocationDegrees
    
    init(lowerBound: CLLocationDegrees, upperBound: CLLocationDegrees) {
        self.lowerBound = lowerBound
        self.upperBound = upperBound
    }
}
