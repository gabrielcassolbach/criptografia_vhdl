TCP_IP = '192.168.88.254'
TCP_PORT = 7777
BUFFER_SIZE = 2000  # Normally 1024, but we want fast response

message = "340737e0a29831318d305a88a8f643323c4fcf098815f7aba6d2ae2816157e2b"
byte_arr = bytearray.fromhex(message)


import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((TCP_IP, TCP_PORT))
s.listen(1)

conn, addr = s.accept()
print("IP conectado:", addr)

while 1:
    data = conn.recv(BUFFER_SIZE)  # e trava a execução até receber uma conexão de rede
    if not data:
        break
    print("Dado recebido:", data.decode('utf-8'))
    if data.decode('utf-8') == "queroa":
        conn.send(byte_arr)

conn.close()
