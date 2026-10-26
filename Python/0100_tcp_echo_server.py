# 0100_tcp_echo_server

import socket
import threading

srv = socket.socket()
srv.bind(("127.0.0.1", 0))
srv.listen(1)
port = srv.getsockname()[1]


def serve():
    conn, _ = srv.accept()
    with conn:
        conn.sendall(conn.recv(1024))


t = threading.Thread(target=serve)
t.start()
with socket.create_connection(("127.0.0.1", port)) as c:
    c.sendall(b"hello")
    print(c.recv(1024))
t.join()
srv.close()
