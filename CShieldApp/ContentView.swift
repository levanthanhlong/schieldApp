//
//  ContentView.swift
//  CShieldApp
//
//  Created by ThanhLe on 8/1/26.
//

import SwiftUI
import CShieldSDK

struct ContentView: View {
    
    @State private var simulator = false
    @State private var debugger = false
    @State private var jailbreakMask: UInt32 = 0
    @State private var jailbreakDetected = false
    
    @State private var tamperResult: String = "Chưa kiểm tra"
    
    // ⚠️ Thay bằng giá trị thật của app bạn
    private let expectedTeamID = "ABCDE12345"
    private let expectedBundleID = "com.mobileCS.CShieldApp"
    private let expectedExeHash = "" // để "" nếu không muốn check hash
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    
                    header
                    
                    detectorCard(
                        title: "Runtime Detection",
                        items: [
                            statusRow("Simulator", simulator),
                            statusRow("Debugger", debugger)
                        ],
                        action: runRuntimeCheck
                    )
                    
                    detectorCard(
                        title: "Jailbreak Detection",
                        items: [
                            statusText("Bitmask", "\(jailbreakMask)"),
                            statusRow("Jailbreak Detected", jailbreakDetected)
                        ],
                        action: runJailbreakCheck
                    )
                    
                    tamperCard
                    
                    
                    OTPCard
                    
                }
                .padding()
            }
            .navigationTitle("🛡 C-Shield SDK")
        }
    }
}


extension ContentView {
    
    var header: some View {
        VStack(spacing: 8) {
            Text("C-Shield Security Test")
                .font(.largeTitle.bold())
            Text("Anti-Debug • Anti-Jailbreak • Anti-Tamper")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 10)
    }
    
    func detectorCard(
        title: String,
        items: [AnyView],
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            ForEach(0..<items.count, id: \.self) { i in
                items[i]
            }
            
            Button("Run Check", action: action)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    func statusRow(_ title: String, _ value: Bool) -> AnyView {
        AnyView(
            HStack {
                Text(title)
                Spacer()
                Label(
                    value ? "YES" : "NO",
                    systemImage: value ? "checkmark.circle.fill" : "xmark.circle.fill"
                )
                .foregroundColor(value ? .red : .green)
            }
        )
    }
    
    func statusText(_ title: String, _ value: String) -> AnyView {
        AnyView(
            HStack {
                Text(title)
                Spacer()
                Text(value)
                    .font(.system(.body, design: .monospaced))
            }
        )
    }
    
    
    var tamperCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tampering Detection")
                .font(.headline)
            
            Text(tamperResult)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(tamperResult.contains("OK") ? .green : .red)
            
            Button("Run Tamper Check") {
                runTamperCheck()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    
    var OTPCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(destination: OTPView()){
                Text("OTP Screen")
                    .padding(10)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }.frame(maxWidth: .infinity)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}


extension ContentView {
    
    func runRuntimeCheck() {
        simulator = CShieldSDK.isSimulator()
        debugger = CShieldSDK.isDebuggerDetected()
    }
    
    func runJailbreakCheck() {
        jailbreakMask = CShieldSDK.jailbreakCheck()
        jailbreakDetected = CShieldSDK.isJailbroken()
    }
    
    func runTamperCheck() {
        let result = CShieldSDK.detectTampering(
            expectedTeamID: expectedTeamID,
            expectedBundleID: expectedBundleID,
            expectedExeHashHex: expectedExeHash.isEmpty ? "" : expectedExeHash
        )
        
        if result == 1 {
            tamperResult = "✅ OK – App hợp lệ"
        } else {
            tamperResult = "❌ FAIL – Tampering detected"
        }
        
        // debug log native (NSLog trong SDK)
        CShieldSDK.detectTamperingDebug(
            expectedTeamID: expectedTeamID,
            expectedBundleID: expectedBundleID,
            expectedExeHashHex: expectedExeHash.isEmpty ? "" : expectedExeHash
        )
    }
}


#Preview {
    ContentView()
}
