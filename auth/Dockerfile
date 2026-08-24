# build stage
FROM golang:1.27-alpine AS builder
WORKDIR /go/src/app
COPY src/authdb ./src/authdb
COPY src/main ./src/main
WORKDIR /go/src/app/src/main
RUN go build -o /go/bin/app -v ./...

# final stage
FROM alpine:3.19
RUN apk --no-cache add ca-certificates \
    && addgroup -S -g 1000 app && adduser -S -u 1000 app -G app
COPY --from=builder /go/bin/app /app
USER app
LABEL org.opencontainers.image.title="weatherapp-auth" \
      org.opencontainers.image.version="0.0.1"
EXPOSE 8080
ENTRYPOINT ["/app"]
