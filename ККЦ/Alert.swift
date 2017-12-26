import Foundation

class Alert {
    
    var id: Int?
    var typeId: Int?
    var type: String?
    var cityId: Int?
    var forcity: String?
    var createDate: String?
    var text: String?
    var content: String?
    var isAlarm: Bool?
    
    init() {
        
        self.id = 0
        self.typeId = 0
        self.type = ""
        self.cityId = 0
        self.forcity = ""
        self.createDate = ""
        self.text = ""
        self.content = ""
        self.isAlarm = false
    }
    
    init(dictionary: NSDictionary) {
        
        self.id = dictionary["id"] as? Int
        self.typeId = dictionary["type_id"] as? Int
        self.type = dictionary["type"] as? String
        self.cityId = dictionary["city_id"] as? Int
        self.forcity = dictionary["forcity"] as? String
        self.createDate = dictionary["create_date"] as? String
        self.text = dictionary["text"] as? String
        self.content = dictionary["content"] as? String
        self.isAlarm = dictionary["is_alarm"] as? Bool
    }
}
