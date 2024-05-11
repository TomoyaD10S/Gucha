import Foundation

class APIManager {
    static func postDataToDynamoDB(authViewModel: AuthenticationViewModel, selectedLanguage: String, completion: @escaping (Result<String?, Error>) -> Void) {
        authViewModel.fetchUserUID()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard let currentUserUID = authViewModel.userUID else {
                completion(.failure(APIError.invalidUserID))
                return
            }

            print(currentUserUID, selectedLanguage)
            let urlString = "\(APIConstants.apiGatewayURL)?id=\(currentUserUID)&language=\(selectedLanguage)"
            guard let url = URL(string: urlString) else {
                completion(.failure(APIError.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                if let responseString = String(data: data, encoding: .utf8) {
                    completion(.success(responseString))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            }
            task.resume()
        }
    }
}

class APIManager_ConfirmPass {
    static func postDataToDynamoDB(authViewModel: AuthenticationViewModel, passme: String, passmatch: String,completion: @escaping (Result<String?, Error>) -> Void) {
        authViewModel.fetchUserUID()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            print(passme,passmatch)
            let urlString = "\(APIConstants.apiGatewayURL_ConfirmPass)?PassMe=\(passme)&PassMatch=\(passmatch)"
            guard let url = URL(string: urlString) else {
                completion(.failure(APIError.invalidURL))
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }

                if let responseString = String(data: data, encoding: .utf8) {
                    completion(.success(responseString))
                } else {
                    completion(.failure(APIError.invalidResponse))
                }
            }
            task.resume()
        }
    }
}


enum APIError: Error {
    case invalidUserID
    case invalidResponse
    case invalidURL
}
