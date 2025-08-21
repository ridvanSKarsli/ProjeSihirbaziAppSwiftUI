import Foundation

class FiltreDataAccess: FiltreService {
    
    // NetworkError enum'u
    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError(String)
    }
    
    // Genel veri çekme fonksiyonu
    private func fetchData<T: Decodable>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Hata varsa
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(NetworkError.decodingError(error.localizedDescription)))
            }
        }
        
        task.resume()
    }
    
    // `getKurumlar` verisini çekme
    func getKurumlar(tur: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = APIEndpoints.getKurumURL(tur: tur)
        fetchData(urlString: urlString, completion: completion)
    }
    
    // `getSektorler` verisini çekme
    func getSektorler(completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = APIEndpoints.getSectors.url
        fetchData(urlString: urlString, completion: completion)
    }
    
    // `getIl` verisini çekme
    func getIl(completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = APIEndpoints.provinces.url
        fetchData(urlString: urlString, completion: completion)
    }
    
    // `getUni` verisini çekme
    func getUni(completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = APIEndpoints.universities.url
        fetchData(urlString: urlString, completion: completion)
    }
    
    // `getKeyword` verisini çekme
    func getKeyword(completion: @escaping (Result<[String], Error>) -> Void) {
        let urlString = APIEndpoints.keywordsurl.url
        fetchData(urlString: urlString, completion: completion)
    }
}
