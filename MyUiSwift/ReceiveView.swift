import SwiftUI
import CoreImage.CIFilterBuiltins

struct ReceiveView: View {
    @ObservedObject var vm: BankingViewModel
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    private let navy = Color(red: 0.08, green: 0.20, blue: 0.38)

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    HStack(spacing: 14) {
                        Image(systemName: "arrow.down.left").font(.title2.bold()).foregroundStyle(.white).frame(width: 48, height: 48).background(navy).clipShape(RoundedRectangle(cornerRadius: 14))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Receive money").font(.title2.bold()).foregroundStyle(navy)
                            Text("Share your QR code to get paid instantly.").font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    VStack(spacing: 18) {
                        Text("Your payment QR").font(.headline).foregroundStyle(navy)
                        Image(uiImage: generateQRCode(from: "\(vm.name ?? "Customer") \(vm.upi_id ?? "") \(vm.user_id ?? "")"))
                            .interpolation(.none).resizable().scaledToFit().frame(width: 240, height: 240).padding(16).background(.white).clipShape(RoundedRectangle(cornerRadius: 16)).shadow(color: .black.opacity(0.08), radius: 10)
                        VStack(spacing: 5) {
                            Text("UPI ID").font(.caption).foregroundStyle(.secondary)
                            Text(vm.upi_id ?? "-").font(.headline).foregroundStyle(navy)
                        }
                        Button { print("Share QR") } label: {
                            Label("Share QR code", systemImage: "square.and.arrow.up").fontWeight(.semibold).frame(maxWidth: .infinity).padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent).tint(navy)
                    }
                    .padding(22).frame(maxWidth: .infinity).background(.white).clipShape(RoundedRectangle(cornerRadius: 20))
                    Label("Payments are credited to your linked account", systemImage: "checkmark.shield.fill").font(.caption).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
                .padding(20)
            }
        }
        .navigationTitle("Receive Money")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func generateQRCode(from string: String) -> UIImage {
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        if let outputImage = filter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent) { return UIImage(cgImage: cgImage) }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview { NavigationStack { ReceiveView(vm: BankingViewModel()) } }
