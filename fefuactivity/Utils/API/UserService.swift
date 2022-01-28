import Foundation

class UserService: APIService {
    static let groupUrl: String = baseUrl + "/user"

    static func profile(resolve: @escaping((UserModel) -> Void),
                        reject: @escaping((ErrorModel) -> Void)) {

        guard let url = URL(string: groupUrl + "/profile") else {
            return
        }

        let request = super.getRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let res = response as? HTTPURLResponse else {
                return
            }

            switch res.statusCode {
            case 200:
                do {
                    let user = try super.decoder.decode(UserModel.self, from: data)
                    resolve(user)
                } catch let e {
                    print("Decode error: \(e)")
                }

            case 401:
                do {
                    let error = try super.decoder.decode(ErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }

            default:
                break
            }
        }
        task.resume()
    }
}
