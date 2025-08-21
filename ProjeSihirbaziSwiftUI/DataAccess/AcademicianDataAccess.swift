import Foundation

class AcademicianDataAccess: AcademicianService {
    
    // Hata türlerini burada tanımlıyoruz
    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError(String)
    }
    
    func getAcademics(currentPage: Int, selectedName: String, selectedProvince: String, selectedUniversity: String, selectedKeywords: String, completion: @escaping (Result<[Academician], Error>) -> Void) {
        
        // URL'yi oluşturuyoruz
        guard let url = URL(string: APIEndpoints.getAcademicsURL(currentPage: currentPage, selectedName: selectedName, selectedProvince: selectedProvince, selectedUniversity: selectedUniversity, selectedKeywords: selectedKeywords)) else {
            completion(.failure(NetworkError.invalidURL))  // Hatalı URL durumu
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        
        // Veri çekme işlemi
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Eğer hata varsa, onu döndürüyoruz
                if let error = error {
                    completion(.failure(error))  // Hata durumunda error'ü döndür
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))  // Veri yoksa noData hatası
                    return
                }
                
                do {
                    // JSON verisini çözümlemeye çalışıyoruz
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ResponseAcademican.self, from: data)
                    
                    // Başarıyla veriyi aldık, sonucu döndürüyoruz
                    completion(.success(response.items))  // Başarıyla akademisyen verilerini döndürüyoruz
                } catch {
                    // JSON çözümleme hatası
                    completion(.failure(NetworkError.decodingError(error.localizedDescription)))  // JSON ayrıştırma hatasını döndürüyoruz
                }
            }
        }
        
        task.resume()  // Veri çekme işlemini başlatıyoruz
    }
}

// API'den gelen yanıtın modeli
struct ResponseAcademican: Codable {
    let currentPage: Int
    let pageSize: Int
    let totalItems: Int
    let totalPages: Int
    let items: [Academician]
}
