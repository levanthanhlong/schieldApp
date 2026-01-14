//
//  OTPViewModel.swift
//  CShieldApp
//
//  Created by ThanhLe on 13/1/26.
//

import Foundation
import Combine
import CShield

class OTPViewModel: ObservableObject {
    @Published var otp: String = ""
    @Published var isLoading: Bool = false
    @Published var message: String = ""
    @Published var signedPayload: String = ""
    
    private var cancellables: Set<AnyCancellable> = []
    
    
    func signMessage(payload: String) -> String? {
        // Bước 1: Gọi hàm C
        let cResult = sign_c(payload)
        
        // Bước 2: Kiểm tra kết quả
        guard let cString = cResult else {
            print("Sign failed")
            return nil
        }
        
        // Bước 3: Convert C string -> Swift String
        let result = String(cString: cString)
        
        // Bước 4: QUAN TRỌNG - Free memory
        free_c_string(cString)
        
        //Bước 5: Return kết quả
        return result
    }
    
    // Sử dụng
    func example() {
        let payload = "Hello World"
        if let signature = signMessage(payload: payload) {
            print("Signature: \(signature)")
        } else {
            print("Failed to generate signature")
        }
    }
    
    
    
    func validateOTP() {
        guard !otp.isEmpty else {
            self.message = "OTP Không thể để trống"
            return
        }
        self.isLoading = true
        self.message = ""
        
        guard let url = URL(string: "https://api.com") else {
            self.message = "URL Không hợp lệ"
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = ["otp": otp]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: OTPResponse.self, decoder: JSONDecoder())
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.message = "Lỗi: \(error.localizedDescription)"
                    self.isLoading = false
                case .finished:
                    break
                }
            } receiveValue: { otpResponse in
                self.isLoading = false
                if otpResponse.success {
                    self.message = "Xác thực OTP thành công!"
                } else {
                    self.message = otpResponse.message ?? "null"
                }
            }
            .store(in: &cancellables)
        
    }
}
