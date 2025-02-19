import socket
import threading
import os
import hashlib

# Define constantes para comunicação
PORT = 1234
BUFFER_SIZE = 4096
ENCODING = 'utf-8'

# Função para calcular o hash SHA256 do arquivo
def calculate_hash(file_path):
    sha256 = hashlib.sha256()
    with open(file_path, 'rb') as f:
        while chunk := f.read(BUFFER_SIZE):
            sha256.update(chunk)
    return sha256.hexdigest()

# Função para tratar requisições de um cliente
def handle_client(conn, addr):
    print(f"[NOVA CONEXÃO] Cliente conectado: {addr}")
    while True:
        try:
            data = conn.recv(BUFFER_SIZE).decode(ENCODING)
            if not data:
                break

            if data.lower() == "sair":
                print(f"[DESCONECTADO] Cliente {addr} desconectado.")
                conn.send("Sair".encode(ENCODING))
                break

            elif data.startswith("Arquivo"):
                _, file_name = data.split(maxsplit=1)
                if os.path.exists(file_name):
                    file_size = os.path.getsize(file_name)
                    file_hash = calculate_hash(file_name)

                    # Envia informações do arquivo
                    conn.send(f"OK|{file_name}|{file_size}|{file_hash}".encode(ENCODING))
                    # print(f"Hash do arquivo: {file_hash}")

                    # Envia os dados do arquivo
                    with open(file_name, 'rb') as f:
                        while chunk := f.read(BUFFER_SIZE):
                            conn.send(chunk)
                else:
                    conn.send("NOK|Arquivo inexistente".encode(ENCODING))

            elif data.startswith("Chat"):
                print(f"[CHAT] Cliente {addr}: {data[5:]}")
                msg_to_client = input("Mensagem para o cliente: ")
                conn.send(f"Chat|{msg_to_client}".encode(ENCODING))

        except ConnectionResetError:
            print(f"[ERRO] Conexão com {addr} foi perdida.")
            break

    conn.close()

# Configuração do servidor TCP
def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind(("0.0.0.0", PORT))
    server.listen(5)
    print(f"[INICIADO] Servidor escutando na porta {PORT}...")

    while True:
        conn, addr = server.accept()
        thread = threading.Thread(target=handle_client, args=(conn, addr))
        thread.start()
        print(f"[ATIVO] Threads em execução: {threading.active_count() - 1}")

if __name__ == "__main__":
    start_server()
