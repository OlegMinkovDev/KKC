import UIKit

private let SERVER_BASE_URL = "http://sandora.naumenko.biz"
private var urlRequest:URLRequest?

class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    private override init() { }
    
    private func catchError(response: NSDictionary?) -> NetworkError? {
        
        if let dictionary = response {
            if let code = dictionary["code"] as? Int {
                
                if code == 100 {
                    return NetworkError.invalidParameters
                } else if code == 101 {
                    return NetworkError.headerNotProvided
                } else if code == 102 {
                    return NetworkError.headerValueError
                } else if code == 103 {
                    return NetworkError.tokenExpired
                } else if code == 104 {
                    return NetworkError.elementNotFound
                } else if code == 105 {
                    return NetworkError.authenticationFailed
                } else if code == 106 {
                    return NetworkError.operationFailed
                } else if code == 107 {
                    return NetworkError.notResourceOwner
                }
            }
        }
        
        return nil
    }
    
    private func checkResponse(response: HTTPURLResponse?, data: Data?, error: Error?) -> (response: NSDictionary?, error: String?) {
        
        guard let data = data, error == nil else {                                                 // check for fundamental networking error
            print("error=\(String(describing: error))")
            return (nil, "fundamental networking error")
        }
        
        if let httpStatus = response, httpStatus.statusCode != 200 {           // check for http errors
            print("statusCode should be 200, but is \(httpStatus.statusCode)")
        }
        
        do {
            if let response = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                return (response, nil)
            }
        } catch {
            return (nil, "invalid json object")
        }
        
        return (nil, "unknown error")
    }
    
    func signUp(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Authentication/json/signup"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func verifyCredentials(headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Authentication/json/verifycredentials"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "GET"
        urlRequest?.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func forgotPassword(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
    
        let api = "/Services/Authentication/json/forgotpassword"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getCities(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getcities"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getDistricts(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getdistricts"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getStreets(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getstreets"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getClientCategories(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getclientcategories"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getMyProfile(withHeaders: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Authentication/json/getmyprofile"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "GET"
        urlRequest?.allHTTPHeaderFields = withHeaders
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func updateMyProfile(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Authentication/json/updatemyprofile"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func changePassword(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Authentication/json/changepassword"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getKPList(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getkplist"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getProblemList(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getproblemlist"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getCCTypeList(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getcctypelist"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getCauses(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getcauses"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getGeoList(withParameters: [String: Any], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Dictionary/json/getgeolist"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = ["Accept" : "application/json", "Content-Type" : "application/json"]
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func setNewContact(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/ContactCenter/json/setnewcontact"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "PUT"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func setNewImage(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/ContactCenter/json/setnewimage"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "PUT"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getContacts(headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/ContactCenter/json/getcontacts"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "GET"
        urlRequest?.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getImages(by id: Int, headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/ContactCenter/json/getimagesbyid/\(id)"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "GET"
        urlRequest?.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getCCResult(by id: Int, headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/ContactCenter/json/getccresult/\(id)"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "GET"
        urlRequest?.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func setCCReview(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/ContactCenter/json/setccreview"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func setCCResultScore(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/ContactCenter/json/setccresultscore"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func setCCResultComment(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/ContactCenter/json/setccresultcomment"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getListSurveys(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Survey/json/getlistsurveys"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
    
    func getSurvey(withParameters: [String: Any], headers: [String: String], completion: @escaping (_ responce: NSDictionary?, _ error: NetworkError?) -> ()) {
        
        let api = "/Services/Survey/json/getsurvey"
        urlRequest = URLRequest(url: URL(string: SERVER_BASE_URL + api)!)
        urlRequest?.httpMethod = "POST"
        urlRequest?.allHTTPHeaderFields = headers
        
        var parametersData:Data?
        do {
            parametersData = try JSONSerialization.data(withJSONObject: withParameters, options: [])
        } catch {
            print(error.localizedDescription)
        }
        
        urlRequest?.httpBody = parametersData!
        
        let task = URLSession.shared.dataTask(with: urlRequest!) { data, response, error in
            
            let result: (response: NSDictionary?, error: String?) = self.checkResponse(response: response as? HTTPURLResponse, data: data, error: error)
            completion(result.response, self.catchError(response: result.response))
        }
        task.resume()
    }
}
