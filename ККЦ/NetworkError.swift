import Foundation

enum NetworkError:Error {
    
    case invalidParameters
    case headerNotProvided
    case headerValueError
    case tokenExpired
    case elementNotFound
    case authenticationFailed
    case operationFailed
    case notResourceOwner
}
