import Foundation

/// 월드보스 API 서비스
/// diablo4.life API를 통해 월드보스 정보 조회
final class WorldBossAPIService {

    // MARK: - Constants

    private enum Constants {
        static let baseURL = "https://diablo4.life/api/trackers/worldBoss/reportHistory"
        static let timeoutInterval: TimeInterval = 10
    }

    // MARK: - Errors

    enum APIError: Error, LocalizedError {
        case invalidURL
        case networkError(Error)
        case invalidResponse
        case decodingError(Error)
        case noData

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "잘못된 URL입니다"
            case .networkError(let error):
                return "네트워크 오류: \(error.localizedDescription)"
            case .invalidResponse:
                return "잘못된 응답입니다"
            case .decodingError(let error):
                return "데이터 파싱 오류: \(error.localizedDescription)"
            case .noData:
                return "데이터가 없습니다"
            }
        }
    }

    // MARK: - Singleton

    static let shared = WorldBossAPIService()

    // MARK: - Private Properties

    private let session: URLSession
    private let decoder: JSONDecoder

    // MARK: - Initialization

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }

    // MARK: - Public Methods

    /// 월드보스 정보 조회 (async/await)
    func fetchWorldBossInfo() async throws -> WorldBossAPIResponse {
        guard let url = URL(string: Constants.baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = Constants.timeoutInterval
        request.cachePolicy = .reloadIgnoringLocalCacheData

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }

            do {
                let apiResponse = try decoder.decode(WorldBossAPIResponse.self, from: data)
                return apiResponse
            } catch {
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    /// 월드보스 이벤트 정보 조회 및 파싱
    func fetchWorldBossEvent() async throws -> WorldBossEvent? {
        let response = try await fetchWorldBossInfo()
        return WorldBossCalculator.shared.parseAPIResponse(response)
    }
}

// MARK: - Convenience Methods

extension WorldBossAPIService {
    /// 월드보스 정보 조회 후 캐시에 저장
    func fetchAndCache(repository: SettingsRepository) async {
        do {
            let response = try await fetchWorldBossInfo()

            if let reports = response.reports,
               let latestReport = reports.first {
                repository.cacheWorldBossData(
                    name: latestReport.name,
                    location: latestReport.location,
                    spawnTime: latestReport.spawnDate
                )
            }
        } catch {
            print("Failed to fetch world boss info: \(error)")
        }
    }

    /// 네트워크 연결 가능 여부 확인 (간단한 체크)
    var isNetworkAvailable: Bool {
        // 실제 구현에서는 Network framework 사용 권장
        // 여기서는 간단히 true 반환
        return true
    }
}
