//import Foundation
//import CommonCrypto
//import CShield
//// CShieldInterceptor - can thiệp vào yêu cầu HTTP và thêm các thông tin bảo mật vào header
//class CShieldInterceptor {
//
//    // Hàm can thiệp vào yêu cầu HTTP để thêm các header vào
//    func intercept(request: inout URLRequest, completion: @escaping (URLRequest?, Error?) -> Void) {
//        do {
//            let method = request.httpMethod ?? "GET"
//            let url = request.url?.path ?? ""
//            let timestamp = String(Int(Date().timeIntervalSince1970))
//            let bodyHash = try getBodyHash(request)
//            
//            // Tạo payload và chữ ký
//            let payload = "\(method).\(url).\(timestamp).\(bodyHash)"
//            let signature = sign_c(payload)
//            print("Signature: \(String(cString: signature!))")
//            
//            // Thêm header vào yêu cầu
//            request.addValue(timestamp, forHTTPHeaderField: "cs-timestamp")
//            if let signaturePointer = signature {
//                request.addValue(String(cString: signaturePointer), forHTTPHeaderField: "cs-signature")
//            } else {
//                print("signature is nil")
//                // Có thể thêm xử lý lỗi hoặc đặt giá trị mặc định ở đây
//            }
//            completion(request, nil)
//        } catch {
//            completion(nil, error)
//        }
//    }
//    
//    // Hàm tính toán băm SHA-256 của phần thân yêu cầu
//    private func getBodyHash(_ request: URLRequest) throws -> String {
//        guard let body = request.httpBody else {
//            return ""
//        }
//        
//        if let boundary = request.value(forHTTPHeaderField: "Content-Type")?.split(separator: ";").first(where: { $0.contains("multipart") }) {
//            let formData = try parseMultipartBody(body)
//            let jsonData = try JSONSerialization.data(withJSONObject: formData, options: [])
//            return jsonData.toSHA256()
//        } else {
//            return body.toSHA256()
//        }
//    }
//    
//    // Hàm xử lý multipart body (nếu có)
//    private func parseMultipartBody(_ body: Data) throws -> [String: String] {
//        var formData = [String: String]()
//        // Thêm logic phân tích multipart body ở đây nếu cần
//        return formData
//    }
//}
//
//// Extension để chuyển Data sang SHA-256
//extension Data {
//    func toSHA256() -> String {
//        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//        _ = self.withUnsafeBytes {
//            CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
//        }
//        return hash.map { String(format: "%02x", $0) }.joined()
//    }
//}
//
//// Extension để chuyển String sang SHA-256
//extension String {
//    func toSHA256() -> String {
//        if let data = self.data(using: .utf8) {
//            return data.toSHA256()
//        }
//        return ""
//    }
//}
//
//// Định nghĩa một số model ví dụ
//struct FormRequest: Encodable {
//    let otp: String
//}
//
//struct ApiResponse: Decodable {
//    let success: Bool
//    let message: String
//}
