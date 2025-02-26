import socket
import hashlib

# Define constantes para comunicação
SERVER = "10.0.0.100"
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

# Função principal do cliente
def start_client():
    client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client.connect((SERVER, PORT))
    print(f"[CONECTADO] Conectado ao servidor {SERVER}:{PORT}")

    while True:
        command = input("Digite uma opção (Sair, Arquivo <nome>, Chat <mensagem>): ")
        client.send(command.encode(ENCODING))

        if command.lower() == "sair":
            response = client.recv(BUFFER_SIZE).decode(ENCODING)
            print(f"[SERVIDOR] {response}")
            break

        elif command.startswith("Arquivo"):
            response = client.recv(BUFFER_SIZE).decode(ENCODING)
            if response.startswith("OK"):
                _, file_name, file_size, file_hash = response.split('|')
                file_size = int(file_size)

                print(f"[SERVIDOR] Enviando arquivo {file_name} ({file_size} bytes, hash {file_hash})")

                with open(f"downloaded_{file_name}", 'wb') as f:
                    total_received = 0
                    while total_received < file_size:
                        chunk = client.recv(BUFFER_SIZE)
                        f.write(chunk)
                        total_received += len(chunk)

                # Verifica a integridade do arquivo recebido
                received_hash = calculate_hash(f"downloaded_{file_name}")
                if received_hash == file_hash:
                    print(f"[SUCESSO] Arquivo {file_name} recebido com sucesso e verificado.")
                else:
                    print(f"[FALHA] Hash do arquivo não corresponde! Recebido: {received_hash}, Esperado: {file_hash}")
            else:
                print(f"[ERRO] {response}")

        elif command.startswith("Chat"):
            response = client.recv(BUFFER_SIZE).decode(ENCODING)
            print(f"[SERVIDOR] {response[5:]}")

if __name__ == "__main__":
    start_client()
