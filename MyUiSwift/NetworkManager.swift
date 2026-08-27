//import Foundation
//
//class NetworkManager {
//    
//    static let shared = NetworkManager()
//    private init() {}
//    
//    private let baseURL = "https://myapiservice-yn1p.onrender.com/"
//    
//    // MARK: - Fetch Customers
//    func fetchCustomers(completion: @escaping (Result<[BankApiData], Error>) -> Void) {
//        let end_url = baseURL + "customers"
//        guard let url = URL(string: end_url) else {
//            completion(.failure(NetworkError.invalidURL))
//            return
//        }
//        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            
//            // Handle error
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            
//            // Check data
//            guard let data = data else {
//                completion(.failure(NetworkError.noData))
//                return
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                
//                // Custom date decoding (handles multiple formats)
//                decoder.dateDecodingStrategy = .custom { decoder in
//                    let container = try decoder.singleValueContainer()
//                    let dateString = try container.decode(String.self)
//                    
//                    let formatters: [DateFormatter] = {
//                        let f1 = DateFormatter()
//                        f1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
//                        f1.locale = Locale(identifier: "en_US_POSIX")
//                        f1.timeZone = TimeZone(secondsFromGMT: 0)
//                        
//                        let f2 = DateFormatter()
//                        f2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
//                        f2.locale = Locale(identifier: "en_US_POSIX")
//                        f2.timeZone = TimeZone(secondsFromGMT: 0)
//                        
//                        return [f1, f2]
//                    }()
//                    
//                    for formatter in formatters {
//                        if let date = formatter.date(from: dateString) {
//                            return date
//                        }
//                    }
//                    
//                    throw DecodingError.dataCorruptedError(
//                        in: container,
//                        debugDescription: "Invalid date format: \(dateString)"
//                    )
//                }
//                
//                let result = try decoder.decode([BankApiData].self, from: data)
//                
//                DispatchQueue.main.async {
//                    completion(.success(result))
//                }
//                
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            }
//            
//        }.resume()
//    }
//    
////    func verify_customer(username: String, password: String) -> Bool{
////        let end_url = baseURL + "login"
////        
////        let isVerified = true
////        return isVerified
////    }
//    
////    func verify_customer(username: String,
////                         password: String,
////                         completion: @escaping (Result<BankApiData, String>) -> Void) {
////        
////        let end_url = baseURL + "login"
////        
////        guard let url = URL(string: end_url) else {
////            completion(.failure("Invalid URL"))
////            return
////        }
////        
////        var request = URLRequest(url: url)
////        request.httpMethod = "POST"
////        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
////        
////        let loginBody = LoginRequest(user_id: username, password: password)
////        
////        do {
////            request.httpBody = try JSONEncoder().encode(loginBody)
////        } catch {
////            completion(.failure("Failed to encode request"))
////            return
////        }
////        
////        URLSession.shared.dataTask(with: request) { data, response, error in
////            
////            if let error = error {
////                DispatchQueue.main.async {
////                    completion(.failure(error.localizedDescription))
////                }
////                return
////            }
////            
////            guard let data = data else {
////                DispatchQueue.main.async {
////                    completion(.failure("No data received"))
////                }
////                return
////            }
////            
////            let decoder = JSONDecoder()
////            
////            // Same date decoding strategy as before
////            decoder.dateDecodingStrategy = .custom { decoder in
////                let container = try decoder.singleValueContainer()
////                let dateString = try container.decode(String.self)
////                
////                let formats = [
////                    "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
////                    "yyyy-MM-dd'T'HH:mm:ss"
////                ]
////                
////                let formatter = DateFormatter()
////                formatter.locale = Locale(identifier: "en_US_POSIX")
////                formatter.timeZone = TimeZone(secondsFromGMT: 0)
////                
////                for format in formats {
////                    formatter.dateFormat = format
////                    if let date = formatter.date(from: dateString) {
////                        return date
////                    }
////                }
////                
////                throw DecodingError.dataCorruptedError(
////                    in: container,
////                    debugDescription: "Invalid date format"
////                )
////            }
////            
////            do {
////                // Try success response
////                let user = try decoder.decode(BankApiData.self, from: data)
////                
////                DispatchQueue.main.async {
////                    completion(.success(user))
////                }
////                
////            } catch {
////                // Try error response
////                if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
////                    DispatchQueue.main.async {
////                        completion(.failure(errorResponse.detail))
////                    }
////                } else {
////                    DispatchQueue.main.async {
////                        completion(.failure("Something went wrong"))
////                    }
////                }
////            }
////            
////        }.resume()
////    }
//    
//}
//
//// MARK: - Custom Errors
//enum NetworkError: Error {
//    case invalidURL
//    case noData
//}














import Foundation
import BioHaazNetwork
class NetworkManager: NSObject {

    static let shared = NetworkManager()
//    let newInterceptor = ApiInterceptor()
//    let newTracker = ApiTracker()
    
    let customerDetails = "customers"
    let verifyLogin = "login"
    let transferAmount = "transfer"
    
    
    func initilizedFramework() -> Bool {
        let config = BioHaazNetworkConfig(
            environments: [
                .prod: "http://myapiservice-yn1p.onrender.com/" // http://192.168.0.118:8000/
            ],
            defaultEnvironment: .prod, debug: true)
        BioHaazNetworkManager.shared.initialize(with: config)
        print("BioHaazNetworkManager initialized ")
        return true
    }

    func getAllUsers(completion: @escaping ([BankApiData]?, Error?) -> Void){
        print("getAllCustomers")
        BioHaazNetworkManager.shared.request(
            method: "GET",
            url: customerDetails,
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: nil
        ) { result in
            print("getAllCustomers inside request")
            switch result {
            case .success(let data):
                do {
                    let users = try JSONDecoder().decode([BankApiData].self, from: data)
                    completion(users, nil)
                } catch {
                    print("Decoding failed:", error.localizedDescription)
                    print(error)
                    completion(nil, error)
                }
                break
            case .failure(let error):
                print("this is from network failure")
                print(error.localizedDescription)
                completion(nil, error)
            }
        }
    }
    
    func getSingleUsers(userId: String, completion: @escaping (BankApiData?, Error?) -> Void) {
        BioHaazNetworkManager.shared.request(
            method: "GET",
            url: customerDetails + "/\(userId)",
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: nil
        ) { result in
            switch result {
            case .success(let data):
               // let users = try JSONDecoder().decode([UsersData], from: data)
                print("the userid: \(userId)")
                do {
//                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    
                    let jsonData = try JSONDecoder().decode(BankApiData.self, from: data)
                    
                    completion(jsonData, nil)
                } catch  {
                    print(error.localizedDescription)
                    completion(nil, error)
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getVerifiedUserData(userId: String, passwd: String, completion: @escaping (BankApiData?, Error?) -> Void){
        let params = ["user_id":userId,
                      "password": passwd] as NSDictionary
//        print(params)
        let urlWithQuery = "\(verifyLogin)?user_id=\(userId)&password=\(passwd)"
//        print(urlWithQuery)
        
        BioHaazNetworkManager.shared.request(
            method: "POST",
            url: urlWithQuery,
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: nil
        ){ result in
            switch result{
            case .success(let data):
                do{
//                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//                    print(jsonData)
//
                    let jsonData = try JSONDecoder().decode(BankApiData.self, from: data)
                    
                    completion(jsonData, nil)
                }catch{
                    print("catch: ",error.localizedDescription)
                    completion(nil, error)
                }
            case .failure(let error):
                print("failure: ",error)
                completion(nil, error)
            }
        }
    }
    
    
    func createUser(fname:String, lname: String, gen: String, pnumber:String, email: String, address: String, empid: String){
        let params = ["firstname":fname,
                      "lastname": lname,
                      "gender": gen,
                      "phone": pnumber,
                      "email": email,
                      "address": address,
                      "empid": empid] as NSDictionary
        print(params)
        BioHaazNetworkManager.shared.request(
            method: "POST",
            url: "employees", //self.newUser ,
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: params as? [String : Any]
        ) { result in
            switch result{
            case .success(let data):
                do{
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    print(jsonData)
                }catch{
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateUser(userId:String,fname:String, lname: String, gen: String, pnumber:String, email: String, address: String){
        let params = ["firstname":fname,
                      "lastname": lname,
                      "gender": gen,
                      "phone": pnumber,
                      "email": email,
                      "address": address] as NSDictionary
        BioHaazNetworkManager.shared.request(
            method: "PUT",
            url: customerDetails,
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: nil //params as? [String : Any]
        ) { result in
            switch result{
            case .success(let data):
                do{
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    print(jsonData)
//                    print("User updated successfully")
                }catch{
                    print(error.localizedDescription)
//                    print("User updated catch")
                }
            case .failure(let error):
                print(error)
//                print("User updation failed")
            }
        }
    }
    
    func createUserAccount(user_id: String, fullname: String, email: String,acc_no: String,upi_id: String, phone: String, passwd: String){
        let params = ["user_id": user_id ,
                      "name": fullname,
                      "phone_number": phone,
                      "email": email,
                      "account_number": acc_no,
                      "upi_id": upi_id,
                      "account_balance": 50000,
                      "password": passwd,
                      "transactions": []] as NSDictionary
        BioHaazNetworkManager.shared.request(
            method: "POST",
            url: "customers",
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: params as? [String : Any]
        ) { result in
            switch result{
            case .success(let data):
                do{
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    print(jsonData)
//                    print("User updated successfully")
                }catch{
                    print(error.localizedDescription)
//                    print("User updated catch")
                }
            case .failure(let error):
                print(error)
//                print("User updation failed")
            }
        }
    }
    
    
//    func userTransfer(fromUser:String, toUser: String, amount: Double) {
//        let params = ["from_user_id":fromUser,
//                      "to_user_id": toUser,
//                      "amount": amount] as NSDictionary
//        print(params)
//        
//        let urlWithQuery = "transfer?from_user_id=\(fromUser)&to_user_id=\(toUser)&amount=\(amount)"
//        print(urlWithQuery)
//        
//        BioHaazNetworkManager.shared.request(
//            method: "POST",
//            url: urlWithQuery, //"transfer",
//            headers: nil,
//            params: nil
//        ) { result in
//            switch result{
//            case .success(let data):
//                do{
//                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//                    print("userTransfer success : ", jsonData)
//                }catch{
//                    print("userTransfer catch : ",error.localizedDescription)
//                }
//            case .failure(let error):
//                print("userTransfer failure : ",error)
//            }
//        }
//    }
    
    func getUserAccountNo(completion: @escaping (String?) -> Void){
        BioHaazNetworkManager.shared.request(
            method: "GET",
            url: "getNewCustAccNo",
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: nil
        ) { result in
            switch result {
            case .success(let data):
                do {
                    let accountNo = try JSONDecoder().decode(String.self, from: data)
                    print("Account No: \(accountNo)")
                    completion(accountNo)
                } catch {
                    print("Decoding error:", error)
                    print("Raw response:", String(data: data, encoding: .utf8) ?? "")
                }
                
            case .failure(let error):
                print("API Error:", error)
            }
        }
    }
    
    
    func getUserIdNo(completion: @escaping (String?) -> Void){
        BioHaazNetworkManager.shared.request(
            method: "GET",
            url: "getNewCustUserId",
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: nil
        ) { result in
            switch result {
            case .success(let data):
                do {
                    let newUserId = try JSONDecoder().decode(String.self, from: data)
                    print("User Id: \(newUserId)")
                    completion(newUserId)
                } catch {
                    print("Decoding error:", error)
                    print("Raw response:", String(data: data, encoding: .utf8) ?? "")
                }
                
            case .failure(let error):
                print("API Error:", error)
            }
        }
    }
    
    
    func userTransfer(fromUser: String, toUser: String, amount: Double, completion: @escaping (Bool) -> Void) {
        
        let urlWithQuery = "transfer?from_user_id=\(fromUser)&to_user_id=\(toUser)&amount=\(amount)"
        
        BioHaazNetworkManager.shared.request(
            method: "POST",
            url: urlWithQuery,
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: nil
        ) { result in
            
            switch result {
            case .success(let data):
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        if let message = jsonData["message"] as? String, message == "Transfer successful" {
                            completion(true)
                        } else if let detail = jsonData["detail"] as? String, detail == "Transfer failed" {
                            completion(false)
                        } else {
                            completion(false) // fallback
                        }
                    } else {
                        completion(false)
                    }
                } catch {
                    print("Parsing error:", error.localizedDescription)
                    completion(false)
                }
                
            case .failure(let error):
                print("userTransfer failure:", error)
                completion(false)
            }
        }
    }
    
    func getUsersTransactions(userId: String, completion: @escaping ([TransactionData?], Error?) -> Void) {
//        BioHaazNetworkManager.shared.request(method: "GET", url: "transactions/\(userId)") { result in
//            switch result {
//            case .success(let data):
//                print(data)
//                do{
//                    let jsonData = try JSONDecoder().decode([TransactionData].self, from: data)
//                    print(jsonData)
//                } catch {
//                    print(error)
//                }
////                do {
//               //
//               //                    let jsonData = try JSONDecoder().decode([TransactionData.self], from: data)
//               //
//               //                    completion(jsonData, nil)
//               //                } catch  {
//               //                    print(error.localizedDescription)
//               //                    completion(nil, error)
//               //                }
//                break
//            case .failure(let error):
//                print(error)
//                break
//            }
//            print(result)
//        }
        BioHaazNetworkManager.shared.request(
            method: "GET",
            url: "transactions/\(userId)",
            headers: ["x-api-key":"FBCSecretKeyForTesting"],
            params: nil
        ) { result in
            switch result {
            case .success(let data):
               // let users = try JSONDecoder().decode([UsersData], from: data)
//                print("the userid: \(userId)")
                do {
                    
                    let jsonData = try JSONDecoder().decode([TransactionData].self, from: data)
//                    print(jsonData)
                    completion(jsonData, nil)
                } catch  {
                    print(error.localizedDescription)
                    completion([], error)
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                completion([], error)
            }
        }
    }

    
//    func deleteUser(userId:Int){
//        BioHaazNetworkManager.shared.request(
//            method: "DELETE",
//            url: "\(self.deleteUserURL)\(userId)",
//            headers: nil,
//            params: nil
//        ) { result in
//            switch result{
//            case .success(let data):
//                do{
//                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
////                    print(jsonData)
//                }catch{
//                    print(error.localizedDescription)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
    
    func deleteUser(userId:String){
        BioHaazNetworkManager.shared.request(
            method: "DELETE",
            url: "employees/",
            headers: nil,
            params: nil
        ) { result in
            switch result{
            case .success(let data):
                do{
                    let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//                    print(jsonData)
                    
                }catch{
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
}
