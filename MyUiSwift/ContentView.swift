import SwiftUI

struct ContentView: View {
    @StateObject var vm = BankingViewModel()
    
    var body: some View {
        ZStack{
            if vm.isLoggedIn {
                DashboardView(vm: vm)
            } else {
                NavigationStack {
                        LoginView(vm: vm)
                    }
            }
        }
    }
}

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil, from: nil, for: nil)
    }
}

#Preview {
    ContentView()
}
