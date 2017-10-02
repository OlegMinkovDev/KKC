import Foundation

class Survey {
    
    var id: Int?
    var name: String?
    var about: String?
    var complete: Bool?
    var isActive: Bool?
    var used: Bool?
    var createDate: String?
    var fromDate: String?
    var toDate: String?
    var usedDate: String?
    var fields: [Field]?
    
    init() {
        
        self.id = 0
        self.name = ""
        self.about = ""
        self.complete = false
        self.isActive = false
        self.used = false
        self.createDate = ""
        self.fromDate = ""
        self.toDate = ""
        self.usedDate = ""
        self.fields = [Field]()
    }
    
    init(dictionary: NSDictionary) {
    
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as? String
        self.about = dictionary["about"] as? String
        self.complete = dictionary["complete"] as? Bool
        self.isActive = dictionary["is_active"] as? Bool
        self.used = dictionary["used"] as? Bool
        self.createDate = dictionary["create_date"] as? String
        self.fromDate = dictionary["from_date"] as? String
        self.toDate = dictionary["to_date"] as? String
        self.usedDate = dictionary["used_date"] as? String
        
        if let fields = dictionary["fields"] as? [NSDictionary] {
            
            self.fields = []
            for dictionary in fields {
                
                let field = Field(dictionary: dictionary)
                self.fields?.append(field)
            }
        }
    }
}

class Field {
    
    var id: Int?
    var typeId: Int?
    var name: String?
    var about: String?
    var variants: [Variant]?
    
    init() {
        
        self.id = 0
        self.typeId = 0
        self.name = ""
        self.about = ""
        self.variants = [Variant]()
    }
    
    init(dictionary: NSDictionary) {
    
        self.id = dictionary["id"] as? Int
        self.typeId = dictionary["type_id"] as? Int
        self.name = dictionary["name"] as? String
        self.about = dictionary["about"] as? String
        
        if let variants = dictionary["variants"] as? [NSDictionary] {
            
            self.variants = []
            for dictionary in variants {
                
                let variant = Variant(dictionary: dictionary)
                self.variants?.append(variant)
            }
        }
    }
}

class Variant {
    
    var id: Int?
    var name: String?
    var about: String?
    var isChecked: Bool?
    
    init() {
        
        self.id = 0
        self.name = ""
        self.about = ""
        self.isChecked = false
    }
    
    init(dictionary: NSDictionary) {
    
        self.id = dictionary["id"] as? Int
        self.name = dictionary["name"] as? String
        self.about = dictionary["about"] as? String
        self.isChecked = dictionary["is_checked"] as? Bool
    }
}
