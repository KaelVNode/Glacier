#!/bin/bash

# Menampilkan ASCII art untuk "Saandy"
echo ".d8888.  .d8b.   .d8b.  d8b   db d8888b. db    db "
echo "88'  YP d8' `8b d8' `8b 888o  88 88  `8D `8b  d8' "
echo "`8bo.   88ooo88 88ooo88 88V8o 88 88   88  `8bd8'  "
echo "  `Y8b. 88~~~88 88~~~88 88 V8o88 88   88    88    "
echo "db   8D 88   88 88   88 88  V888 88  .8D    88    "
echo "`8888Y' YP   YP YP   YP VP   V8P Y8888D'    YP    "

# Memeriksa apakah Docker sudah terinstal
if ! command -v docker &> /dev/null; then
    echo "Docker tidak terinstal. Memulai proses instalasi..."
    
    # Memperbarui paket dan menginstal dependensi
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Menambahkan GPG key resmi Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Menambahkan repository Docker
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Memperbarui paket dan menginstal Docker
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Memeriksa apakah instalasi Docker berhasil
    if ! command -v docker &> /dev/null; then
        echo "Instalasi Docker gagal. Silakan coba lagi."
        exit 1
    fi
    echo "Docker berhasil diinstal."
else
    echo "Docker sudah terinstal. Melewati proses instalasi."
fi

# Memeriksa apakah container 'glacier-verifier' sudah ada
if docker ps -a --format '{{.Names}}' | grep -Eq "^glacier-verifier\$"; then
    echo "Docker container 'glacier-verifier' sudah ada."
else
    # Menanyakan private key dari user
    read -p "Silakan masukkan private key Anda: " PRIVATE_KEY

    # Memeriksa apakah private key telah diberikan
    if [ -z "$PRIVATE_KEY" ]; then
        echo "Error: Private key diperlukan."
        exit 1
    fi

    # Menjalankan Docker container dengan private key
    docker run -d -e PRIVATE_KEY="$PRIVATE_KEY" --name glacier-verifier docker.io/glaciernetwork/glacier-verifier:v0.0.1

    echo "Docker container 'glacier-verifier' sedang berjalan dengan private key yang diberikan."
fi

# Mengikuti log container
echo "Mengikuti log dari container 'glacier-verifier'..."
docker logs -f glacier-verifier
