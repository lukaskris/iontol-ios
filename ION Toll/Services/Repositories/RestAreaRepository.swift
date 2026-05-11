import Foundation

protocol RestAreaRepositoryProtocol: Sendable {
    func getList(latitude: Double, longitude: Double) async throws -> [RestAreaItem]
    func getDetail(id: String, view: String?) async throws -> RestAreaDetailDto
    func getCategories() async throws -> [CategoryItem]
}

final class RestAreaRepository: RestAreaRepositoryProtocol {
    private let api: RestAreaApiServiceProtocol

    init(api: RestAreaApiServiceProtocol = RestAreaApiService()) {
        self.api = api
    }

    func getList(latitude: Double, longitude: Double) async throws -> [RestAreaItem] {
        let response = try await api.getRestAreaList(latitude: latitude, longitude: longitude, query: nil)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return data.map { $0.toItem() }
    }

    func getDetail(id: String, view: String?) async throws -> RestAreaDetailDto {
        let response = try await api.getRestAreaDetail(id: id, view: view)
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return data
    }

    func getCategories() async throws -> [CategoryItem] {
        let response = try await api.getCategories()
        guard let data = response.data else {
            throw APIError.serverError(message: response.message)
        }
        return data.map { $0.toItem() }
    }
}
