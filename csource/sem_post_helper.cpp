#include <iostream>
#ifdef _WIN32
#include <windows.h>
#else
#include <semaphore.h>
#include <fcntl.h>
#endif

int main(int argc, char* argv[]) {
    const char* SEM_NAME = "/spinner_semaphore";
#ifdef _WIN32
    HANDLE sem = OpenSemaphore(SEMAPHORE_ALL_ACCESS, FALSE, SEM_NAME);
    if (sem == NULL) {
        std::cerr << "Failed to open semaphore" << std::endl;
        return 1;
    }
    if (!ReleaseSemaphore(sem, 1, NULL)) {
        std::cerr << "Failed to post semaphore" << std::endl;
        CloseHandle(sem);
        return 1;
    }
    CloseHandle(sem);
#else
    sem_t* sem = sem_open(SEM_NAME, 0);
    if (sem == SEM_FAILED) {
        std::cerr << "Failed to open semaphore" << std::endl;
        return 1;
    }
    sem_post(sem);
    sem_close(sem); // Ensure sem_close is called
#endif
    return 0;
}
