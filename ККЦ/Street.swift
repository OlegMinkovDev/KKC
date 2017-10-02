import Foundation

class Street {
    
    var id: Int?
    var name: String?
    var city: Int?
    var districtionId: Int?
    var districtionName: String?
    var type: Int?
    var typename: String?
    
    init() {
        
        self.id = 0
        self.name = ""
        self.city = 0
        self.districtionId = 0
        self.districtionName = ""
        self.type = 0
        self.typename = ""
    }
    
    init(dictionary: NSDictionary) {
        
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as? String
        self.city = dictionary["city"] as? Int
        self.districtionId = dictionary["distr"] as? Int
        self.districtionName = dictionary["distrname"] as? String
        self.type = dictionary["type"] as? Int
        self.typename = dictionary["typename"] as? String
    }
}
