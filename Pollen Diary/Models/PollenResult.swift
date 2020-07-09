//
//  PollenResult.swift
//  Pollen Diary
//
//  Created by Wolfgang Sigel on 12.06.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation

struct PollenResult: Codable {
    var last_update: String
    var legend: LegendType
    var content: [ContentType]
    var sender: String
    var next_update: String
    var name: String
}

struct ContentType: Codable {
    var region_name: String
    var partregion_id: Int
    var partregion_name: String
    var region_id: Int
    var Pollen: PollenCollectionType
}

struct PollenCollectionType: Codable {
    var Ambrosia: PollenType
    var Roggen: PollenType
    var Beifuss: PollenType
    var Graeser: PollenType
    var Esche: PollenType
    var Hasel: PollenType
    var Birke: PollenType
    var Erle: PollenType
}

struct PollenType: Codable {
    var today: String
    var tomorrow: String
    var dayafter_to: String
}


struct LegendType: Codable {
    var id1: String
    var id2: String
    var id3: String
    var id4: String
    var id5: String
    var id6: String
    var id7: String
    var id1_desc: String
    var id2_desc: String
    var id3_desc: String
    var id4_desc: String
    var id5_desc: String
    var id6_desc: String
    var id7_desc: String
}
