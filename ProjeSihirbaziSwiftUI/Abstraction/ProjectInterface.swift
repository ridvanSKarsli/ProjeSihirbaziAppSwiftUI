import Foundation

protocol ProjectInterface{
    
    func getProject(tur: String, page: Int, sector: String, search: String, status: String, company: String, sortOrder: String, completion: @escaping ([Projects]?, Int?, String?) -> Void)
}
