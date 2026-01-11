import Foundation

// MARK: - Report Service Protocol

protocol ReportServiceProtocol {
    /// Get user's reports
    func getMyReports() async throws -> [Report]

    /// Submit a report
    func submitReport(request: CreateReportRequest) async throws -> Report
}

// MARK: - Create Report Request

struct CreateReportRequest: Encodable {
    let reportableType: ReportableType
    let reportableId: Int
    let reason: ReportReason
    let note: String?

    enum CodingKeys: String, CodingKey {
        case reason, note
        case reportableType = "reportable_type"
        case reportableId = "reportable_id"
    }
}
