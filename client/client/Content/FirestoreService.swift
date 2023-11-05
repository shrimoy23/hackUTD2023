import Foundation

struct Property: Codable, Identifiable {
    var address: String
    var squareFootage: Int
    var id: String

    enum CodingKeys: String, CodingKey {
        case address
        case squareFootage = "square_foot"
        case id
    }
}


class FirestoreService: ObservableObject {
    private let serverURL = "http://192.168.4.26:5000"
    
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
    func addProperty(id: String, address: String, squareFootage: Int, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "\(serverURL)/add_house"
        guard let url = URL(string: urlString) else { return }
        
        // Prepare the data to be sent in the request
        let propertyData = Property(address: address, squareFootage: squareFootage, id: id)
        guard let uploadData = try? JSONEncoder().encode(propertyData) else {
            completion(false, nil)
            return
        }
        
        // Create a POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData
        
        // Create the data task
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
        
        // Start the task
        task.resume()
    }
    
    
    func deleteProperty(_ propertyId: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "\(serverURL)/delete_house"
        guard let url = URL(string: urlString) else {
            completion(false, nil)
            return
        }
        
        // Prepare the data to be sent in the request
        let deleteData = ["id": propertyId]
        guard let uploadData = try? JSONEncoder().encode(deleteData) else {
            completion(false, nil)
            return
        }
        
        // Create a DELETE request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData
        
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
