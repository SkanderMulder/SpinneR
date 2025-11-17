#include <iostream>
#include <chrono>
#include <thread>

#ifdef _WIN32
#include <windows.h>
#else
#include <semaphore.h>
#include <fcntl.h>
#include <unistd.h>
#endif

const char* SEM_NAME = "/spinner_semaphore";

const char spinner_chars[] = {'|', '/', '-', '\\'};
const int spinner_count = sizeof(spinner_chars) / sizeof(spinner_chars[0]);

int main() {
#ifdef _WIN32
    HANDLE sem = OpenSemaphore(SEMAPHORE_ALL_ACCESS, FALSE, SEM_NAME);
    if (sem == NULL) {
        sem = CreateSemaphore(NULL, 0, 1, SEM_NAME);
        if (sem == NULL) {
            std::cerr << "Failed to create or open semaphore" << std::endl;
            return 1;
        }
    }
#else
    // Ensure semaphore is unlinked before opening to prevent stale semaphores
    sem_unlink(SEM_NAME);
    sem_t* sem = sem_open(SEM_NAME, O_CREAT | O_EXCL, 0644, 0);
    if (sem == SEM_FAILED) {
        std::cerr << "Failed to create semaphore exclusively, trying to open existing" << std::endl;
        sem = sem_open(SEM_NAME, 0);
        if (sem == SEM_FAILED) {
            std::cerr << "Failed to open semaphore" << std::endl;
            return 1;
        }
    }
#endif

    int idx = 0;
    bool running = true;

    while (running) {
#ifdef _WIN32
        // Check if semaphore has been posted (stop signal)
        DWORD wait_status = WaitForSingleObject(sem, 0); // Check without waiting
        if (wait_status == WAIT_OBJECT_0) {
            running = false;
            // Re-release the semaphore if we acquired it, so sem_post_helper can acquire it
            ReleaseSemaphore(sem, 1, NULL);
            break;
        }
#else
        int sval;
        sem_getvalue(sem, &sval);
        if (sval > 0) {
            running = false;
            break;
        }
#endif

        // Print spinner character with carriage return to overwrite
        std::cout << "\r" << spinner_chars[idx++] << std::flush;
        if (idx >= spinner_count) idx = 0;

        // Sleep 100 ms
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }

    // Clear spinner on exit
    std::cout << "\r \r" << std::flush;

#ifdef _WIN32
    CloseHandle(sem);
#else
    sem_close(sem);
    sem_unlink(SEM_NAME); // Ensure unlinked on clean exit
#endif

    return 0;
}
