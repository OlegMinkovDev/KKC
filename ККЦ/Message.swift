import Foundation

class Message {
    
    var createDate: String?
    var clientId: Int?
    var clientName: String?
    var text: String?
    
    init() {
        
        createDate = ""
        clientId = 0
        clientName = ""
        text = ""
    }
    
    init(dictionary: NSDictionary) {
        
        createDate = dictionary["create_date"] as? String
        clientId = dictionary["client_id"] as? Int
        clientName = dictionary["clientname"] as? String
        text = dictionary["text"] as? String
    }
}
