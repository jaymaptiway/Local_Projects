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
