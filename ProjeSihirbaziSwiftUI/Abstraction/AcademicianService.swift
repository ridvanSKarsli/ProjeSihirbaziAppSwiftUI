import Foundation

protocol AcademicianService {
    func getAcademics(currentPage: Int, selectedName: String, selectedProvince: String, selectedUniversity: String, selectedKeywords: String, completion: @escaping (Result<([Academician], Int), Error>) -> Void)
}
