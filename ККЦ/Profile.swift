import Foundation

class Profile {
    
    var surname: String?
    var name: String?
    var city: Int?
    var tel: String?
    var email: String?
    var datecreate: String?
    var type: Int?
    var address: String?
    var street: Int?
    var gender: Int?
    var house: String?
    var flat: String?
    var gmlat: Int?
    var gmlng: Int?
    var birthday: String?
    var typeId: Int?
    var categoryId: Int?
    var doorCode: Int?
    var entrance: Int?
    var block: String?
    
    init() {
        
        self.surname = ""
        self.name = ""
        self.city = 0
        self.tel = ""
        self.email = ""
        self.datecreate = ""
        self.type = 0
        self.address = ""
        self.street = 0
        self.gender = 0
        self.house = ""
        self.flat = ""
        self.gmlat = 0
        self.gmlng = 0
        self.birthday = ""
        self.typeId = 0
        self.categoryId = 0
        self.doorCode = 0
        self.entrance = 0
        self.block = ""
    }
    
    init(parameters: NSDictionary) {
        
        self.surname = parameters["surname"] as? String
        self.name = parameters["name"] as? String
        self.city = parameters["city"] as? Int
        self.tel = parameters["tel"] as? String
        self.email = parameters["email"] as? String
        self.datecreate = parameters["datecreate"] as? String
        self.type = parameters["type"] as? Int
        self.address = parameters["address"] as? String
        self.street = parameters["street"] as? Int
        self.gender = parameters["gender"] as? Int
        self.house = parameters["house"] as? String
        self.flat = parameters["flat"] as? String
        self.gmlat = parameters["gmlat"] as? Int
        self.gmlng = parameters["gmlng"] as? Int
        self.birthday = parameters["birthday"] as? String
        self.typeId = parameters["type_id"] as? Int
        self.categoryId = parameters["category_id"] as? Int
        self.doorCode = parameters["door_code"] as? Int
        self.entrance = parameters["entrance"] as? Int
        self.block = parameters["block"] as? String
    }
}
