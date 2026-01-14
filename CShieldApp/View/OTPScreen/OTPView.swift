//
//  Untitled.swift
//  CShieldApp
//
//  Created by ThanhLe on 13/1/26.
//

import SwiftUI

struct OTPView: View {
    @StateObject private var viewModel = OTPViewModel()
    
    var body: some View {
        VStack(spacing: 25) { // Giảm khoảng cách giữa các phần tử
            // Tiêu đề
            Text("Nhập mã OTP")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.blue)
                .padding(.top, 30)
            
            // TextField cho OTP
            TextField("Nhập mã OTP", text: $viewModel.otp)
                .padding()
                .font(.title2)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 5)
                .keyboardType(.numberPad)
                .padding(.horizontal, 30)
            
            // Nếu đang xác thực, hiển thị ProgressView
            if viewModel.isLoading {
                ProgressView("Đang xác thực OTP...")
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.blue))
                    .padding()
            } else {
                // Nút xác thực OTP
                Button(action: {
                    viewModel.validateOTP()
                }) {
                    Text("Xác thực OTP")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 55)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(15)
                        .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 30)
                        .scaleEffect(viewModel.isLoading ? 1.0 : 1.05) // Thêm hiệu ứng khi nhấn
                        .animation(.spring(), value: viewModel.isLoading) // Hiệu ứng nở khi bấm
                }.frame(width: 340)
            }
            
            // Hiển thị thông báo
            Text(viewModel.message)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(viewModel.message.starts(with: "Lỗi") ? .red : .green)
                .padding(.top, 15) // Giảm khoảng cách giữa thông báo và nút
            
            
            Button(action: {
                viewModel.example()
                
            }) {
                Text("sign payload")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 55)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(15)
                    .shadow(color: Color.blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 30)
                    .scaleEffect(viewModel.isLoading ? 1.0 : 1.05) // Thêm hiệu ứng khi nhấn
                    .animation(.spring(), value: viewModel.isLoading) // Hiệu ứng nở khi bấm
            }.frame(width: 340)
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .top) // Chắc chắn rằng nội dung sẽ trải dài hết màn hình
        .background(Color(UIColor.systemGray6)) // Màu nền sáng cho màn hình
        .cornerRadius(30)
        .shadow(radius: 15)
        .padding(.horizontal, 20) // Padding xung quanh giao diện để không sát viền
    }
}

struct OTPView_Previews: PreviewProvider {
    static var previews: some View {
        OTPView()
    }
}


#Preview {
    OTPView()
}
