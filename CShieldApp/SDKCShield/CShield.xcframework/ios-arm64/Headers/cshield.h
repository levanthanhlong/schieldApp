#ifndef CSHIELD_SDK_H
#define CSHIELD_SDK_H

#include <stdbool.h>
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif

// Kiểm tra xem app có đang chạy trên simulator/emulator không
bool simulatorDetector(void);

// Kiểm tra xem app có đang chạy debugger không
bool debuggerDetector(void);

// kiểm tra tampering: TeamID, BundleID, và optional SHA256(executable)
int temperingDetector(const char *expectedTeamID, const char *expectedBundleID, const char *expectedExeHashHex);

// Debug: in chi tiết (in cả actual hash)
void temperingDetectorDebug(const char *expectedTeamID, const char *expectedBundleID, const char *expectedExeHashHex);

// =========================== Jailbreak Detection
// Bitmask flags: mỗi bit biểu thị một nghi vấn jailbreak
enum {
  JB_FLAG_NONE = 0,
  JB_FLAG_SUSPICIOUS_FILES = 1 << 0,
  JB_FLAG_WRITE_OUTSIDE_SANDBOX = 1 << 1,
  JB_FLAG_DYLD_INJECTION = 1 << 2,
  JB_FLAG_LOOPBACK_PORT = 1 << 3,
  JB_FLAG_ROOTFS_RW = 1 << 4,
};

// Hàm chính: trả về bitmask (0 = sạch, khác 0 = có nghi vấn jailbreak)
uint32_t jailbreakDetectorCheck(void);

// true nếu phát hiện ít nhất 1 nghi vấn jailbreak
bool jailbreakDetector(void);

#ifdef __cplusplus
}  // Kết thúc extern "C"
#endif

#endif // CSHIELD_SDK_H
