import Foundation
import UIKit

class Contact {
    
    var id: Int?
    var cityId: Int?
    var streetId: Int?
    var flat: String?
    var house: String?
    var lat: CGFloat?
    var lng: CGFloat?
    var note: String?
    var causeId: Int?
    var problemId: Int?
    var typeId: Int?
    var execId: Int?
    var isPublic: Bool?
    var reciveDate: String?
    var perfomed: String?
    var approved: Int?
    var imageBase64: [String]?
    var images: [UIImage]?
    
    init() {
        
        self.id = 0
        self.cityId = 0
        self.streetId = 0
        self.flat = ""
        self.house = ""
        self.lat = 0.0
        self.lng = 0.0
        self.note = ""
        self.causeId = 0
        self.problemId = 0
        self.typeId = 0
        self.execId = 0
        self.isPublic = false
        self.reciveDate = ""
        self.perfomed = ""
        self.approved = 0
        self.imageBase64 = []
        self.images = []
    }
    
    init(dictionary: NSDictionary) {
        
        self.id = dictionary["id"] as? Int
        self.cityId = dictionary["city_id"] as? Int
        self.streetId = dictionary["street_id"] as? Int
        self.flat = dictionary["flat"] as? String
        self.house = dictionary["house"] as? String
        self.lat = dictionary["lat"] as? CGFloat
        self.lng = dictionary["lng"] as? CGFloat
        self.note = dictionary["note"] as? String
        self.causeId = dictionary["cause_id"] as? Int
        self.problemId = dictionary["problem_id"] as? Int
        self.typeId = dictionary["type_id"] as? Int
        self.execId = dictionary["exec_id"] as? Int
        self.isPublic = dictionary["is_public"] as? Bool
        self.reciveDate = dictionary["recive_date"] as? String
        self.perfomed = dictionary["perfomed"] as? String
        self.approved = dictionary["approved"] as? Int
    }
}
