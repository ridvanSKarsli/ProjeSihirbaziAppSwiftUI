import Foundation

protocol DashboardService {
    func fetchDashboardData(completion: @escaping (Result<Dashboard, Error>) -> Void)
}
