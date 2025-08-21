import Foundation

class AcademicianManager: AcademicianService {
    
    private let academicianDataAccess = AcademicianDataAccess()
    
    func getAcademics(currentPage: Int, selectedName: String, selectedProvince: String, selectedUniversity: String, selectedKeywords: String, completion: @escaping (Result<[Academician], Error>) -> Void) {
        academicianDataAccess.getAcademics(currentPage: currentPage, selectedName: selectedName, selectedProvince: selectedProvince, selectedUniversity: selectedUniversity, selectedKeywords: selectedKeywords, completion: completion)
    }
}
