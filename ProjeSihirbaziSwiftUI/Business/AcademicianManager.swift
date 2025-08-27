import Foundation

class AcademicianManager: AcademicianService {

    private let academicianDataAccess = AcademicianDataAccess()  // Data Access kullanıyoruz
    
    func getAcademics(currentPage: Int, selectedName: String, selectedProvince: String, selectedUniversity: String, selectedKeywords: String, completion: @escaping (Result<([Academician], Int), Error>) -> Void) {
        academicianDataAccess.getAcademics(currentPage: currentPage, selectedName: selectedName, selectedProvince: selectedProvince, selectedUniversity: selectedUniversity, selectedKeywords: selectedKeywords) { result in
            switch result {
            case .success(let (academicians, totalPages)):
                completion(.success((academicians, totalPages)))  // Akademisyen verilerini ve totalPages'i döndürüyoruz
            case .failure(let error):
                completion(.failure(error))  // Hata durumunda aynı hatayı döndürüyoruz
            }
        }
    }
}
