import SwiftUI
import AVFoundation

struct ScanPayView: View {
    @ObservedObject var vm: BankingViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var scannedUPI: String?
    @State private var amount = ""
    @State private var isShowingPayment = false
    @State private var showSuccessOverlay = false
    @State private var showMessage = ""
    @State private var showMessageTitle = ""
    @State private var overlayImage = ""
    @State private var overlayImageColor = Color.green
    @State private var showLoader = false
    @State private var pendingPayment: PendingPayment?
    
    @State private var scannedRecipient = ""
    @State private var scannedAmount = 0.0
    @State private var scannedUserId = ""
    @State private var scannedPayload = ""

    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    
                    HStack(spacing: 20) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(width: 48, height: 48)
                            .background(navy)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.leading, 16)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Scan & pay")
                                .font(.title2.bold())
                                .foregroundStyle(navy)
                            Text("Pay securely by scanning a UPI QR code.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(spacing: 14) {
                        QRScannerView(scannedCode: $scannedUPI)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        Label("Align the QR code inside the frame", systemImage: "viewfinder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    if let upi = scannedUPI {
                        let components = upi.split(separator: " ")
                        
                        let toName = components.count > 1 ? components[0...1].joined(separator: " ") : (components.first.map(String.init) ?? "Recipient")
                        let toUpiId = components.count > 2 ? String(components[2]) : ""
                        let toUserId = components.count > 3 ? String(components[3]) : ""
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Payment details")
                                .font(.headline)
                                .foregroundStyle(navy)
                            Text("Paying to: \(toName)")
                                .font(.subheadline.weight(.semibold))
                            
                            Text("UPI: \(toUpiId)")
                                .foregroundColor(.gray)
                            // Amount input
                            HStack {
                                Text("₹")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                TextField("Enter amount", text: $amount)
                                    .keyboardType(.decimalPad)
                                    .font(.title2)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            // Pay Button
                            Button { reviewPayment(toName: toName, toUserId: toUserId, qrPayload: upi) } label: {
                                HStack {
                                    Image(systemName: "paperplane.fill")
                                    Text("Pay")
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(navy)
                                .cornerRadius(13)
                            }
                            .padding(.horizontal)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.horizontal)
                    } else {
                        Text("")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            
            .navigationBarTitleDisplayMode(.inline)
            
            .overlay { resultOverlay }
        }
        .fullScreenCover(item: $pendingPayment) { payment in
            NavigationStack {
                MPINView(recipient: payment.recipient, amount: payment.amount) {
                    executePayment()
                }
            }
        }
    }

   

    private func reviewPayment(toName: String, toUserId: String, qrPayload: String) {
        guard let value = Double(amount), value > 0, value <= (vm.balance ?? 0), vm.user_id != nil else {
            showMessage = "Insufficient balance or invalid amount."
            showMessageTitle = "Payment failed"
            overlayImage = "xmark.circle.fill"
            overlayImageColor = .red
            showSuccessOverlay = true
            return
        }

        scannedRecipient = toName
        scannedAmount = value
        scannedUserId = toUserId
        scannedPayload = qrPayload
        print("Scanned Recipient: \(scannedRecipient), Amount: \(scannedAmount), User ID: \(scannedUserId), Payload: \(scannedPayload)")
        pendingPayment = PendingPayment(recipient: scannedRecipient, amount: scannedAmount)
    }

    private struct PendingPayment: Identifiable {
        let id = UUID()
        let recipient: String
        let amount: Double
    }

    private func executePayment() {
        guard let userId = vm.user_id else { return }
        showLoader = true
        NetworkManager.shared.userTransfer(fromUser: userId, toUser: scannedUserId, amount: scannedAmount) { success in
            DispatchQueue.main.async {
                if success {
                    vm.sendMoney(title: scannedRecipient, amount: scannedAmount, status: "Success")
                    showMessage = "₹\(scannedAmount, default: "%.2f") sent to \(scannedRecipient)."
                    showMessageTitle = "Payment sent"
                    overlayImage = "checkmark.circle.fill"
                    overlayImageColor = .green
                } else {
                    showMessage = "The recipient could not be found."
                    showMessageTitle = "Payment failed"
                    overlayImage = "xmark.circle.fill"
                    overlayImageColor = .red
                    vm.failedTransaction(title: scannedPayload, amount: scannedAmount, status: showMessageTitle)
                }
                showLoader = false
                showSuccessOverlay = true
                amount = ""
                scannedUPI = nil
            }
        }
    }

    private var resultOverlay: some View {
        ZStack {
            if showSuccessOverlay {
                Color.black.opacity(0.35).ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: overlayImage)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundStyle(overlayImageColor)
                        .frame(width: 76, height: 76)
                        .background(overlayImageColor.opacity(0.12))
                        .clipShape(Circle())
                    VStack(spacing: 8) {
                        Text(showMessageTitle).font(.title2.bold()).foregroundStyle(navy)
                        Text(showMessage).font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }
                    HStack {
                        Label("Updated balance", systemImage: "wallet.pass.fill").font(.caption).foregroundStyle(.secondary)
                        Spacer()
                        Text("₹\(vm.balance ?? 0, specifier: "%.2f")").font(.subheadline.bold()).foregroundStyle(navy)
                    }
                    .padding().background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 12))
                    Button { showSuccessOverlay = false; dismiss() } label: {
                        Text("Done").fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 15)
                    }
                    .buttonStyle(.borderedProminent).tint(navy)
                }
                .padding(24).background(.white).clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.18), radius: 24, y: 10).padding(24)
            }
            if showLoader {
                Color.black.opacity(0.25).ignoresSafeArea()
                VStack(spacing: 14) {
                    ProgressView().tint(.white).scaleEffect(1.2)
                    Text("Processing payment...").font(.subheadline.weight(.semibold)).foregroundStyle(.white)
                }
                .padding(28).background(.black.opacity(0.78)).clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }
    
    // MARK: - QR Scanner UIViewRepresentable
    struct QRScannerView: UIViewRepresentable {
        @Binding var scannedCode: String?
        
        func makeUIView(context: Context) -> some UIView {
            let view = UIView()
            let session = AVCaptureSession()
            
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else { return view }
            
            session.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            
            //        previewLayer.frame = UIScreen.main.bounds
            DispatchQueue.main.async {
                previewLayer.frame = view.bounds
            }
            
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
            context.coordinator.session = session
            
            return view
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(scannedCode: $scannedCode)
        }
        
        class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
            var scannedCode: Binding<String?>
            var session: AVCaptureSession?
            
            init(scannedCode: Binding<String?>) {
                self.scannedCode = scannedCode
            }
            
            func metadataOutput(_ output: AVCaptureMetadataOutput,
                                didOutput metadataObjects: [AVMetadataObject],
                                from connection: AVCaptureConnection) {
                if let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                   let code = obj.stringValue {
                    scannedCode.wrappedValue = code
                    session?.stopRunning()
                }
            }
        }
    }
    
    // MARK: - Preview
    struct ScanPayView_Previews: PreviewProvider {
        static var previews: some View {
            ScanPayView(vm: BankingViewModel())
        }
    }
}
