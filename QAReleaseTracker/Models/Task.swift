import Foundation

struct Task: Identifiable, Codable {
    var id: UUID = UUID()
    var user_id: UUID? = nil
    var title: String
    var notes: String
    var owner: String
    var status: String
    var priority: String
    var due_date: Date
    var approval_status: String
    var email_sent: Bool
    var text_sent: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, notes, owner, status, priority
        case user_id
        case due_date
        case approval_status
        case email_sent
        case text_sent
    }
}
