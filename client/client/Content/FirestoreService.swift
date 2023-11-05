import Foundation

struct Property: Codable {
    var id: String
    var address: String
    var squareFootage: Int
}

class FirestoreService: ObservableObject {
    private let serverURL = "http://127.0.0.1:5000"

    // Fetches the list of properties from the server
    func fetchProperties(completion: @escaping ([Property]?, Error?) -> Void) {
        let urlString = "\(serverURL)/"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            do {
                let properties = try JSONDecoder().decode([Property].self, from: data)
                DispatchQueue.main.async {
                    completion(properties, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }

    // Sends new property data to the server
    func addProperty(address: String, squareFootage: Int, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "\(serverURL)/add_house"
        guard let url = URL(string: urlString) else { return }

        // Prepare the data to be sent in the request
        let propertyData = Property(id: UUID().uuidString, address: address, squareFootage: squareFootage)
        guard let uploadData = try? JSONEncoder().encode(propertyData) else {
            completion(false, nil)
            return
        }

        // Create a POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }

            // You can handle the response data here if needed
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
        task.resume()
    }
    
    func deleteProperty(_ propertyId: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "\(serverURL)/delete_house/\(propertyId)"
        guard let url = URL(string: urlString) else {
            completion(false, nil)
            return
        }

        // Create a DELETE request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                DispatchQueue.main.async {
                    completion(false, error)
                }
                return
            }

            // The property was deleted successfully
            DispatchQueue.main.async {
                completion(true, nil)
            }
        }
        task.resume()
    }
}
