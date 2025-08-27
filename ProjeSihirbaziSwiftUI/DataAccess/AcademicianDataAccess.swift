import Foundation
class AcademicianDataAccess: AcademicianService {

    enum NetworkError: Error {
        case invalidURL
        case noData
        case decodingError(String)
    }

    // Parametresiz `init` fonksiyonu
    init() {}

    func getAcademics(currentPage: Int, selectedName: String, selectedProvince: String, selectedUniversity: String, selectedKeywords: String, completion: @escaping (Result<([Academician], Int), Error>) -> Void) {
        let urlString = APIEndpoints.getAcademicsURL(currentPage: currentPage, selectedName: selectedName, selectedProvince: selectedProvince, selectedUniversity: selectedUniversity, selectedKeywords: selectedKeywords)

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))  // Hatalı URL durumu
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))  // Hata durumunda error'ü döndürüyoruz
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))  // Veri yoksa noData hatası
                return
            }

            do {
                // JSON verisini çözümlemeye çalışıyoruz
                let response = try JSONDecoder().decode(ResponseAcademican.self, from: data)

                // Başarıyla veriyi aldık, sonucu döndürüyoruz
                completion(.success((response.items, response.totalPages)))  // Akademisyen verilerini ve totalPages bilgisini döndürüyoruz
            } catch {
                // JSON çözümleme hatası
                completion(.failure(NetworkError.decodingError(error.localizedDescription)))  // JSON ayrıştırma hatasını döndürüyoruz
            }
        }

        task.resume()  // Veri çekme işlemini başlatıyoruz
    }
}


struct ResponseAcademican: Codable {
    let currentPage: Int       // Şu anki sayfa numarası
    let pageSize: Int          // Sayfa başına öğe sayısı
    let totalItems: Int        // Toplam öğe sayısı
    let totalPages: Int        // Toplam sayfa sayısı
    let items: [Academician]   // Akademisyenlerin listesi
}
