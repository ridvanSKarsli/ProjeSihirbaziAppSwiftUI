import Foundation

protocol FiltreService {
    func getKurumlar(tur: String, completion: @escaping (Result<[String], Error>) -> Void)
    func getSektorler(completion: @escaping (Result<[String], Error>) -> Void)
    func getIl(completion: @escaping (Result<[String], Error>) -> Void)
    func getUni(completion: @escaping (Result<[String], Error>) -> Void)
    func getKeyword(completion: @escaping (Result<[String], Error>) -> Void)
}
