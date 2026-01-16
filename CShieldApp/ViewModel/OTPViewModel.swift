//import Foundation
//import Combine
//import CShieldSDK
//
//@MainActor
//class OTPViewModel: ObservableObject {
//    @Published var otp: String = ""
//    @Published var isLoading: Bool = false
//    @Published var message: String = ""
//    @Published var signedPayload: String = ""
//    
//    private var cancellables: Set<AnyCancellable> = []
//    
//    private let cShieldInterceptor = CShieldInterceptor()
//    
//    
//    // Cập nhật phương thức validateOTP
//    func validateOTP() {
//        guard !otp.isEmpty else {
//            self.message = "OTP Không thể để trống"
//            return
//        }
//        
//        self.isLoading = true
//        self.message = ""
//        
//        guard let url = URL(string: "https://demo-spring-server.onrender.com/verify-otp") else {
//            self.message = "URL Không hợp lệ"
//            self.isLoading = false
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        
//        // Tạo body cho yêu cầu
//        let body: [String: Any] = ["otp": otp]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//    
//        // Can thiệp vào yêu cầu HTTP để thêm thông tin bảo mật vào header
//        cShieldInterceptor.intercept(request: &request) { modifiedRequest, error in
//            guard let modifiedRequest = modifiedRequest, error == nil else {
//                self.message = "Lỗi khi can thiệp vào yêu cầu: \(error?.localizedDescription ?? "Unknown error")"
//                self.isLoading = false
//                return
//            }
//            
//            // Thêm header Content-Type và Accept
//            var requestWithHeaders = modifiedRequest
//            requestWithHeaders.setValue("application/json", forHTTPHeaderField: "Content-Type")  // Đảm bảo Content-Type là application/json
//            requestWithHeaders.setValue("application/json", forHTTPHeaderField: "Accept")  // Đảm bảo Accept là application/json
//            
//            // Gửi yêu cầu sau khi đã can thiệp vào header
//            URLSession.shared.dataTaskPublisher(for: requestWithHeaders)
//                .map { response in
//                    // Kiểm tra phản hồi JSON trước khi giải mã
//                    if let jsonString = String(data: response.data, encoding: .utf8) {
//                        print("JSON Response: \(jsonString)")  // In ra JSON để kiểm tra
//                    }
//                    return response.data
//                }
//                .decode(type: OTPResponse.self, decoder: JSONDecoder())  // Giải mã JSON thành đối tượng OTPResponse
//                .sink { completion in
//                    switch completion {
//                    case .failure(let error):
//                        self.message = "Lỗi: \(error.localizedDescription)"
//                        self.isLoading = false
//                    case .finished:
//                        break
//                    }
//                } receiveValue: { otpResponse in
//                    self.isLoading = false
//                    if otpResponse.success {
//                        self.message = "Xác thực OTP thành công!"
//                    } else {
//                        self.message = otpResponse.message ?? "null"
//                    }
//                }
//                .store(in: &self.cancellables)
//        }
//        
//    }
//}
//


import Foundation
import Combine
import CShieldSDK
import CommonCrypto


@MainActor
class OTPViewModel: ObservableObject {
    @Published var otp: String = ""
    @Published var isLoading: Bool = false
    @Published var message: String = ""
    @Published var signedPayload: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let cShieldInterceptor = CShieldInterceptor()
    
    // Cập nhật phương thức validateOTP
    func validateOTP() {
        guard !otp.isEmpty else {
            self.message = "OTP Không thể để trống"
            return
        }
        
        self.isLoading = true
        self.message = ""
        
        guard let url = URL(string: "https://demo-spring-server.onrender.com/verify-otp") else {
            self.message = "URL Không hợp lệ"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Tạo body cho yêu cầu
        let body: [String: Any] = ["otp": otp]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
    
        // Can thiệp vào yêu cầu HTTP để thêm thông tin bảo mật vào header
        cShieldInterceptor.intercept(request: &request) { modifiedRequest, error in
            guard let modifiedRequest = modifiedRequest, error == nil else {
                self.message = "Lỗi khi can thiệp vào yêu cầu: \(error?.localizedDescription ?? "Unknown error")"
                self.isLoading = false
                return
            }
            
            // Thêm header Content-Type và Accept
            var requestWithHeaders = modifiedRequest
            requestWithHeaders.setValue("application/json", forHTTPHeaderField: "Content-Type")  // Đảm bảo Content-Type là application/json
            requestWithHeaders.setValue("application/json", forHTTPHeaderField: "Accept")  // Đảm bảo Accept là application/json
            
            // Gửi yêu cầu sau khi đã can thiệp vào header
            URLSession.shared.dataTaskPublisher(for: requestWithHeaders)
                .tryMap { (data, response) -> Data in
                    // Kiểm tra phản hồi JSON trước khi giải mã
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("JSON Response: \(jsonString)")  // In ra JSON để kiểm tra
                    }
                    if let httpResponse = response as? HTTPURLResponse {
                        print("http status code: \(httpResponse.statusCode)")
                        if httpResponse.statusCode >= 400 {
                            return data
                        }
                    }
                    
                    if let interceptedData = self.cShieldInterceptor.interceptResponse(response: response, data: data, mode: 2) {
                           return interceptedData
                       } else {
                           // Nếu không thành công trong việc can thiệp, trả về dữ liệu gốc
                           return data
                       }
                    
                    //return data // Trả về data để tiếp tục chuỗi pipeline
                }
                .decode(type: OTPResponse.self, decoder: JSONDecoder())
                .sink { completion in
                    switch completion {
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.message = "Lỗi: \(error.localizedDescription)"
                            self.isLoading = false
                        }
                    case .finished:
                        break
                    }
                } receiveValue: { otpResponse in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        if otpResponse.success {
                            self.message = "Xác thực OTP thành công!"
                        } else {
                            self.message = otpResponse.message ?? "null"
                        }
                    }
                }
                .store(in: &self.cancellables)
        }
    }
}

// Extension để tính toán SHA256 của Data
extension Data {
    func sha256() -> String {
        var hash = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = hash.withUnsafeMutableBytes { hashBytes in
            self.withUnsafeBytes { messageBytes in
                CC_SHA256(messageBytes.baseAddress, CC_LONG(self.count), hashBytes.baseAddress)
            }
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
}
