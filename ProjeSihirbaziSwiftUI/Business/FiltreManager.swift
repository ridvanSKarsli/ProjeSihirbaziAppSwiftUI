import Foundation

class FiltreManager: FiltreService {
    
    private let filtreDataAccess = FiltreDataAccess()
    
    func getKurumlar(tur: String, completion: @escaping (Result<[String], Error>) -> Void) {
        filtreDataAccess.getKurumlar(tur: tur, completion: completion)
    }
    
    func getSektorler(completion: @escaping (Result<[String], Error>) -> Void) {
        filtreDataAccess.getSektorler(completion: completion)
    }
    
    func getIl(completion: @escaping (Result<[String], Error>) -> Void) {
        filtreDataAccess.getIl(completion: completion)
    }
    
    func getUni(completion: @escaping (Result<[String], Error>) -> Void) {
        filtreDataAccess.getUni(completion: completion)
    }
    
    func getKeyword(completion: @escaping (Result<[String], Error>) -> Void) {
        filtreDataAccess.getKeyword(completion: completion)
    }
}
