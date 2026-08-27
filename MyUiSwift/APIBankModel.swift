import Foundation

struct BankApiData: Codable{
    let id: String?
    let user_id: String?
    let name: String?
    let phone_number: String?
    let email: String?
    let account_number: String?
    let upi_id: String?
    let account_balance: Double?
    let transactions: [TransactionData]
}

struct TransactionData: Codable{
    let transaction_id: String?
    let from_user_id: String?
    let to_user_id: String?
    let amount: Double?
    let transaction_type: String?
    let status: String?
    let created_at: String?
}

struct LoginRequest: Encodable {
    let user_id: String
    let password: String
}

struct ErrorResponse: Decodable {
    let detail: String
}
