import Foundation

class Problem {
    
    var id: Int?
    var name: String?
    
    init() {
        
        self.id = 0
        self.name = ""
    }
    
    init(dictionary: NSDictionary) {
        
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as? String
    }
}
