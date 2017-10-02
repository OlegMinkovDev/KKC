import Foundation

class Credentials {
    
    var id: Int?
    var token: String?
    var apiKey: String?
    var user: String?
    var verify: String?
    
    init() {
        
        self.id = 0
        self.token = ""
        self.apiKey = ""
        self.user = ""
        self.verify = ""
    }
    
    init(parameters: NSDictionary) {
        
        self.id = parameters["Id"] as? Int
        self.token = parameters["token"] as? String
        self.apiKey = parameters["apikey"] as? String
        self.user = parameters["user"] as? String
        self.verify = parameters["verify"] as? String
    }
}
