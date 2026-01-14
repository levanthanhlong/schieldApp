
#ifndef AIP_H
#define AIP_H

#include <iostream>
#include <string>
#include <vector>

// Khai báo hàm sign
// std::string sign(const std::string& payload, void* context);
std::string sign(std::string& payload);

// Khai báo hàm verify
// bool verify(const std::string& encode, const std::string& signature, void* context);
bool verify( std::string& encode,  std::string& signature);


// Thêm C wrapper để Swift có thể gọi
#ifdef __cplusplus
extern "C" {
#endif

// C wrapper functions
const char* sign_c(const char* payload);
bool verify_c(const char* encode, const char* signature);
void free_c_string(const char* str);

#ifdef __cplusplus
}
#endif

#endif // AIP_H
