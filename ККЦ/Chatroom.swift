import Foundation

class Chatroom {
    
    var id: Int?
    var createDate: String?
    var contactId: Int?
    var moderator: Int?
    var name: String?
    var about: String?
    var contact: String?
    var moderatorName: String?
    
    init() {
        
        self.id = 0
        self.createDate = ""
        self.contactId = 0
        self.moderator = 0
        self.name = ""
        self.about = ""
        self.contact = ""
        self.moderatorName = ""
    }
    
    init(dictionary: NSDictionary) {
        
        self.id = dictionary["id"] as? Int
        self.createDate = dictionary["create_date"] as? String
        self.contactId = dictionary["contact_id"] as? Int
        self.moderator = dictionary["moderator"] as? Int
        self.name = dictionary["name"] as? String
        self.about = dictionary["about"] as? String
        self.contact = dictionary["contact"] as? String
        self.moderatorName = dictionary["moderatorname"] as? String
    }
}
