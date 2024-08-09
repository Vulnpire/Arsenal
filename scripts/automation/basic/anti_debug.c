#include <windows.h>
#include <stdio.h>
#include <wchar.h>
#include <tlhelp32.h>

BOOL CALLBACK EnumWindowsProc(HWND hwnd, LPARAM lParam) {
    DWORD dwProcessId = (DWORD)lParam;
    DWORD dwWindowProcessId;
    GetWindowThreadProcessId(hwnd, &dwWindowProcessId);

    if (dwProcessId == dwWindowProcessId) {
        int windowTitleSize = GetWindowTextLengthW(hwnd);
        if (windowTitleSize <= 0) {
            return TRUE;
        }
        wchar_t* windowTitle = (wchar_t*)malloc((windowTitleSize + 1) * sizeof(wchar_t));
        GetWindowTextW(hwnd, windowTitle, windowTitleSize + 1);

        if (wcsstr(windowTitle, L"dbg") != 0 || wcsstr(windowTitle, L"debugger") != 0) {
            free(windowTitle);
            return FALSE;
        }

        free(windowTitle);
        return FALSE;
    }

    return TRUE;
}

BOOL IsDebuggerProcess(DWORD dwProcessId) {
    DWORD g_dwDebuggerProcessId = -1;
    EnumWindows(EnumWindowsProc, (LPARAM)dwProcessId);
    return g_dwDebuggerProcessId == dwProcessId;
}

void SuspendDebuggerThreads(DWORD dwProcessId) {
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
    if (hSnapshot == INVALID_HANDLE_VALUE) {
        printf("Failed to create snapshot: %d\n", GetLastError());
        return;
    }

    THREADENTRY32 te32;
    te32.dwSize = sizeof(THREADENTRY32);

    if (!Thread32First(hSnapshot, &te32)) {
        printf("Failed to get first thread: %d\n", GetLastError());
        CloseHandle(hSnapshot);
        return;
    }

    do {
        if (te32.th32OwnerProcessID == dwProcessId) {
            HANDLE hThread = OpenThread(THREAD_SUSPEND_RESUME, FALSE, te32.th32ThreadID);
            if (hThread != NULL) {
                if (IsDebuggerProcess(te32.th32OwnerProcessID)) {
                    printf("Debugger found with pid %i! Suspending!\n", te32.th32OwnerProcessID);
                    if (SuspendThread(hThread) == -1) {
                        printf("Failed to suspend thread: %d\n", GetLastError());
                    }
                }
                CloseHandle(hThread);
            }
        }
    } while (Thread32Next(hSnapshot, &te32));

    CloseHandle(hSnapshot);
}

int main(void) {
    // Replace this process ID with the targeted process ID
    DWORD targetProcessId = GetCurrentProcessId();

    SuspendDebuggerThreads(targetProcessId);

    printf("Continuing operation...");
    getchar();

    return 0;
}