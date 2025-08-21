import Foundation

class DashboardManager: DashboardService {
    
    private let dashboardDataAccess = DashboardDataAccess()
    
    func fetchDashboardData(completion: @escaping (Result<Dashboard, Error>) -> Void) {
        dashboardDataAccess.fetchDashboardData(completion: completion)
    }
}
