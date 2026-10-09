FROM golang:1.27-alpine AS dev
WORKDIR /app
RUN go install github.com/air-verse/air@latest
COPY go.mod go.sum ./
RUN go mod download
CMD ["air", "-c", ".air.toml"]

FROM golang:1.27-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o guestbook

FROM scratch
WORKDIR /app
COPY --from=builder /app/guestbook .
COPY public public
EXPOSE 3000
ENTRYPOINT ["./guestbook"]
