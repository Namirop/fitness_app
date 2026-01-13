# 1️⃣ Image Go officielle
FROM golang:1.24-alpine

# 2️⃣ Dossier de travail dans le container
WORKDIR /app

# 3️⃣ Copier les fichiers Go
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# 4️⃣ Build du binaire
RUN go build -o app

# 5️⃣ Port exposé
EXPOSE 3000

# 6️⃣ Commande de démarrage
CMD ["./app"]