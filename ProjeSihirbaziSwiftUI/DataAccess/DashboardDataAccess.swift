import Foundation

class DashboardDataAccess: DashboardService {
    
    func fetchDashboardData(completion: @escaping (Result<Dashboard, Error>) -> Void) {
        guard let url = URL(string: APIEndpoints.dashboard.url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))  // Handle failure with error
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))  // Handle failure with no data
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let grantCount = json["grantCount"] as? Int ?? 0
                        let academicianCount = json["academicianCount"] as? Int ?? 0
                        let tenderCount = json["tenderCount"] as? Int ?? 0
                        
                        let dashboard = Dashboard(grantCount: grantCount, academicianCount: academicianCount, tenderCount: tenderCount)
                        completion(.success(dashboard))  // Return the parsed dashboard data
                    }
                } catch {
                    completion(.failure(error))  // Handle JSON parsing error
                }
            }
        }
        
        task.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
}
