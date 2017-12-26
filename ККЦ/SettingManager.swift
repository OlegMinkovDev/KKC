import Foundation
import UIKit

class SettingManager: NSObject {
    
    static let shered = SettingManager()
    private override init() {}
    
    private var credential: Credentials?
    private var cities = [City]()
    private var districts = [District]()
    private var streets = [Street]()
    private var clientCategories = [ClientCategory]()
    private var profile: Profile?
    private var utilities = [Utilities]()
    private var contactTypes = [ContactType]()
    private var problems = [Problem]()
    private var causes = [Cause]()
    private var contacts = [Contact]()
    private var surveys = [Survey]()
    private var alerts = [Alert]()
    private var messages = [Int : [Message]]()
    
    static let MAX_TEXTFIELD_LENGTH = 75
    static var HEADERS: [String : String]!
    static var MY_PROFILE: Profile!
    
    func saveCredential(credential: Credentials) {
        
        UserDefaults.standard.set(credential.id!, forKey: "id")
        UserDefaults.standard.set(credential.apiKey!, forKey: "apiKey")
        UserDefaults.standard.set(credential.token!, forKey: "token")
        UserDefaults.standard.set(credential.user!, forKey: "user")
        UserDefaults.standard.set(credential.verify!, forKey: "verify")
        
        self.credential = credential
        
        updateHeaders()
    }
    
    func getCredential() -> Credentials? {
        
        if UserDefaults.standard.value(forKey: "token") != nil {
            
            let credential = Credentials()
            credential.id = UserDefaults.standard.integer(forKey: "id")
            credential.apiKey = UserDefaults.standard.value(forKey: "apiKey") as? String
            credential.token = UserDefaults.standard.value(forKey: "token") as? String
            credential.user = UserDefaults.standard.value(forKey: "user") as? String
            credential.verify = UserDefaults.standard.value(forKey: "verify") as? String
            
            return credential
        }
        
        return nil
    }
    
    func updateHeaders() {
        
        let credential = getCredential()
        let stringToConvert = "\(credential!.token!):"
        
        if let data = stringToConvert.data(using: .utf8) {
            
            let base64String = "BASIC " + data.base64EncodedString()
            
            let headers = ["Authorization" : base64String, "API-KEY" : "\(credential!.apiKey!)", "Accept" : "application/json", "Content-Type" : "application/json"]
            print(base64String)
            print(credential!.apiKey!)
            SettingManager.HEADERS = headers
        }
    }
    
    func saveCities(cities: [City]) {
        self.cities = cities
    }
    
    func getCities() -> [City] {
        return self.cities
    }
    
    func getCity(byName name: String) -> City? {
        
        for city in self.cities {
            if city.name! == name {
                return city
            }
        }
        
        return nil
    }
    
    func getCity(byId id: Int) -> City? {
        
        for city in self.cities {
            if city.id! == id {
                return city
            }
        }
        
        return nil
    }
    
    func saveCityId(cityId: Int) {
        UserDefaults.standard.set(cityId, forKey: "cityId")
    }
    
    func getCityId() -> Int {
        return UserDefaults.standard.integer(forKey: "cityId")
    }
    
    func saveDistricts(districts: [District]) {
        self.districts = districts
    }
    
    func getDistricts() -> [District] {
        return self.districts
    }
    
    func getDistrict(by name: String) -> District? {
        
        for district in self.districts {
            if district.name! == name {
                return district
            }
        }
        
        return nil
    }
    
    func saveStreets(streets: [Street]) {
        self.streets = streets
    }
    
    func getStreets() -> [Street] {
        return self.streets
    }
    
    func getStreets(by districtionId: Int) -> [Street] {
        return self.streets.filter() {$0.districtionId! == districtionId}
    }
    
    func getStreet(by name: String) -> Street? {
        
        for street in self.streets {
            if street.name! == name {
                return street
            }
        }
        
        return nil
    }
    
    func getStreet(by id: Int) -> Street? {
        
        for street in self.streets {
            if street.id! == id {
                return street
            }
        }
        
        return nil
    }
    
    func saveClientCategories(clientCategories: [ClientCategory]) {
        self.clientCategories = clientCategories
    }
    
    func getClientCategories() -> [ClientCategory] {
        return self.clientCategories
    }
    
    func getClientCategory(by name: String) -> ClientCategory? {
        
        for clientCategory in self.clientCategories {
            if clientCategory.name! == name {
                return clientCategory
            }
        }
        
        return nil
    }
    
    func getClientCategory(by id: Int) -> ClientCategory? {
        
        for clientCategory in self.clientCategories {
            if clientCategory.id! == id {
                return clientCategory
            }
        }
        
        return nil
    }
    
    func saveProfile(profile: Profile) {
        self.profile = profile
    }
    
    func getProfile() -> Profile {
        return self.profile!
    }
    
    func saveUtilities(utilities: [Utilities]) {
        self.utilities = utilities
    }
    
    func getUtilities() -> [Utilities] {
        return self.utilities
    }
    
    func getUtilities(by id: Int) -> Utilities? {
        
        for service in self.utilities {
            if service.id! == id {
                return service
            }
        }
        
        return nil
    }
    
    func saveProblems(problems: [Problem]) {
        self.problems = problems
    }
    
    func getProblems() -> [Problem] {
        return self.problems
    }
    
    func getProblem(by name: String) -> Problem? {
        
        for problem in self.problems {
            if problem.name! == name {
                return problem
            }
        }
        
        return nil
    }
    
    func getProblem(by id: Int) -> Problem? {
        
        for problem in self.problems {
            if problem.id! == id {
                return problem
            }
        }
        
        return nil
    }
    
    func saveCauses(causes: [Cause]) {
        self.causes = causes
    }
    
    func getCauses() -> [Cause] {
        return self.causes
    }
    
    func getCause(by name: String) -> Cause? {
        
        for cause in self.causes {
            if cause.name! == name {
                return cause
            }
        }
        
        return nil
    }
    
    func saveContactTypes(contactTypes: [ContactType]) {
        self.contactTypes = contactTypes
    }
    
    func getContactTypes() -> [ContactType] {
        return self.contactTypes
    }
    
    func getContactType(by name: String) -> ContactType? {
        
        for contactType in self.contactTypes {
            if contactType.name! == name {
                return contactType
            }
        }
        
        return nil
    }
    
    func getContactType(by id: Int) -> ContactType? {
        
        for contactType in self.contactTypes {
            if contactType.id! == id {
                return contactType
            }
        }
        
        return nil
    }
    
    func saveContacts(contacts: [Contact]) {
        self.contacts = contacts
    }
    
    func getContacts() -> [Contact] {
        return self.contacts
    }
    
    func addContact(contact: Contact) {
        self.contacts.append(contact)
    }
    
    func saveSurveys(surveys: [Survey]) {
        self.surveys = surveys
    }
    
    func getSurveys() -> [Survey] {
        return self.surveys
    }
    
    func saveAlerts(alerts: [Alert]) {
        self.alerts = alerts
    }
    
    func getAlerts() -> [Alert] {
        return self.alerts
    }
    
    func addMessage(roomId: Int, message: Message) {
        
        var messageArray = self.messages[roomId]
        if messageArray == nil {
            messageArray = []
        }
        
        messageArray?.append(message)
        self.messages[roomId] = messageArray
    }
    
    func getMessages(roomId: Int) -> [Message] {
        
        if let messages = self.messages[roomId] {
            return messages
        }
        
        return []
    }
}

@IBDesignable class CustomLabel: UILabel {
    
    @IBInspectable var txtColor: UIColor! {
        didSet {
            self.textColor = txtColor
        }
    }
}
