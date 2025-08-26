import Foundation

protocol UserService {
    func getUserData(token: String, completion: @escaping (User?) -> Void)
    func logIn(email: String, password: String, completion: @escaping (Bool) -> Void)
    func updateUserData(token: String, name: String, surname: String, imageFile: String, password: String, completion: @escaping (User?) -> Void)
    func forgetPassword(email: String, completion: @escaping (String) -> Void)
    func refreshToken(completion: @escaping (Bool) -> Void)
}
