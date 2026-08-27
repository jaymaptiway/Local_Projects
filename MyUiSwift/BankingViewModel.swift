import Foundation
import Combine

struct Transaction: Identifiable {
    let id = UUID()
//    let title: String
//    let amount: Double
//    let status: String
    let transaction_id: String
    let from_user_id: String
    let to_user_id: String
    let amount: Double
    let transaction_type: String
    let status: String
    let transaction_date : String
}

class BankingViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var balance: Double? /* = 45000*/
    @Published var transactions: [Transaction] = []
    @Published var singleCustomerData : BankApiData?
    
    @Published var id: String?
    @Published var user_id: String?
    @Published var name: String?
    @Published var phone_number: String?
    @Published var email: String?
    @Published var account_number: String?
    @Published var upi_id: String?
    @Published var account_balance: Double?
    @Published var account_transaction: [TransactionData]?

    private var transactionPollingCancellable: AnyCancellable?
    private var loadedTransactionIDs: Set<String> = []
    
    init() {
            loadTransactions()
//            printUserNames()
        }
    
    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        
        NetworkManager.shared.getVerifiedUserData(userId: username, passwd: password) { result, error in
            DispatchQueue.main.async {
                if result != nil {
                    print("Show Verified User result : ", result!)
                    self.singleCustomerData = result!
                    self.balance = self.singleCustomerData?.account_balance ?? 0
                    self.setUserData(data: self.singleCustomerData!)
                    self.isLoggedIn = true
                    self.startTransactionPolling()
                    completion(true)
                } else {
//                    print("Show user error result : ", result!)
                    print("Show user error : ", error!.localizedDescription)
                    self.isLoggedIn = false
                    completion(false)
                }
            }
        }
    }
    
    func createUserAccount(fullname: String, email: String, phone: String, dob: String, passwd: String){
        
    }

    func loadTransactions() {
//        transactions = [
//            Transaction(title: "Interest", amount: 500, status: "Received"),
//            Transaction(title: "Swigggy", amount: -1200, status: "Failed"),
//            Transaction(title: "Amazon Shopping", amount: -800, status: "Paid"),
//            Transaction(title: "Salary", amount: 50000, status: "Received"),
//            Transaction(title: "Electricity Bill", amount: -1500, status: "Paid"),
//            Transaction(title: "Netflix Subscription", amount: -499, status: "Paid"),
//            Transaction(title: "Grocery Store", amount: -2200, status: "Failed"),
//            Transaction(title: "Petrol", amount: -1000, status: "Paid"),
//            Transaction(title: "Gym Membership", amount: -1200, status: "Paid"),
//            Transaction(title: "Freelance Payment", amount: 5000, status: "Received"),
//            Transaction(title: "Dining Out", amount: -1800, status: "Paid"),
//            Transaction(title: "Mobile Recharge", amount: -299, status: "Failed")
//        ]
        print("Transactions getting loaded")
    }

    func sendMoney(title:String , amount: Double, status:String) {
        guard amount > 0, amount <= balance! else { return }
//        let transfer = "Transfer to \(title)"
//        transactions.insert(Transaction(title: title, amount: -amount, status: status), at: 0)
        self.reloadTransactions()
        
    }
   
    func receiveMoney(title: String, amount: Double, status:String) {
        guard amount > 0 else { return }
//        let transfer = "Transfer to \(title)"

        balance! += amount
//        transactions.insert(Transaction(title: title, amount: amount,  status: status), at: 0)
    }
    
    func failedTransaction(title:String , amount: Double, status:String){
//        transactions.insert(Transaction(title: title, amount: amount, status: status), at: 0)
        self.reloadTransactions()
    }

    func logout() {
        transactionPollingCancellable?.cancel()
        transactionPollingCancellable = nil
        transactions.removeAll()
        loadedTransactionIDs.removeAll()
        account_transaction = nil
        singleCustomerData = nil
        user_id = nil
        isLoggedIn = false
    }
    
    func updateTransaction(transaction_id: String,
                           from_user_id: String,
                           to_user_id: String,
                           amount: Double,
                           transaction_type: String,
                           status: String,
                           transaction_date: String){
        if transaction_type == "send"{
            //            transactions.insert(Transaction(title: title, amount: -amount, status: status), at: 0)
            transactions.insert(Transaction(transaction_id: transaction_id,
                                            from_user_id: from_user_id,
                                            to_user_id: to_user_id,
                                            amount: -amount,
                                            transaction_type: transaction_type,
                                            status: status,
                                            transaction_date: transaction_date), at: 0)
        }else{
            //            transactions.insert(Transaction(title: title, amount: amount, status: status), at: 0)
            transactions.insert(Transaction(transaction_id: transaction_id,
                                            from_user_id: from_user_id,
                                            to_user_id: to_user_id,
                                            amount: amount,
                                            transaction_type: transaction_type,
                                            status: status,
                                            transaction_date: transaction_date), at: 0)
        }
        
        
        
    }
    
    
    func setUserData(data: BankApiData){
        id = data.id ?? ""
        user_id = data.user_id ?? ""
        name = data.name ?? ""
        phone_number = data.phone_number ?? ""
        email = data.email ?? ""
        account_number = data.account_number ?? ""
        upi_id = data.upi_id ?? ""
        account_balance = data.account_balance ?? 0
        account_transaction = data.transactions
//        print("from setUserData : \n ", account_transaction!)
        
        let sortedTransactions = account_transaction!
            .sorted { ($0.created_at ?? "") > ($1.created_at ?? "") }
        transactions = sortedTransactions.map(makeTransaction)
        loadedTransactionIDs = Set(sortedTransactions.compactMap(\.transaction_id))
        
    }
    
    func reloadTransactions(){
        guard let userId = user_id, !userId.isEmpty else { return }

        NetworkManager.shared.getUsersTransactions(userId: userId){ result, error in
            DispatchQueue.main.async {
                guard self.isLoggedIn, self.user_id == userId else { return }
                if !result.isEmpty {
                    let refreshedTransactions = result.compactMap { $0 }
                        .sorted { ($0.created_at ?? "") > ($1.created_at ?? "") }
                    let newTransactions = refreshedTransactions.filter { item in
                        guard let transactionID = item.transaction_id else { return false }
                        return !self.loadedTransactionIDs.contains(transactionID)
                    }
                    self.balance = self.balanceAfterAdding(newTransactions)
                    self.loadedTransactionIDs.formUnion(refreshedTransactions.compactMap(\.transaction_id))
                    self.transactions = refreshedTransactions.map(self.makeTransaction)
                } else if let error {
                    print("Show reloadTransactions error : ", error.localizedDescription)
                }
            }
        }
    }

    private func makeTransaction(from item: TransactionData) -> Transaction {
        let transactionAmount = item.transaction_type == "send" ? -(item.amount ?? 0) : (item.amount ?? 0)
        return Transaction(transaction_id: item.transaction_id ?? "",
                           from_user_id: item.from_user_id ?? "",
                           to_user_id: item.to_user_id ?? "",
                           amount: transactionAmount,
                           transaction_type: item.transaction_type ?? "",
                           status: item.status ?? "",
                           transaction_date: item.created_at ?? "")
    }

    private func balanceAfterAdding(_ newTransactions: [TransactionData]) -> Double? {
        guard var currentBalance = balance else { return nil }
        for transaction in newTransactions {
            let amount = transaction.amount ?? 0
            currentBalance += transaction.transaction_type == "send" ? -amount : amount
        }
        return currentBalance
    }

    private func startTransactionPolling() {
        transactionPollingCancellable?.cancel()
        transactionPollingCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.reloadTransactions()
            }
    }

    deinit {
        transactionPollingCancellable?.cancel()
    }
}

