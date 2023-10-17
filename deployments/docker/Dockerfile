FROM golang:1.21-alpine AS builder

WORKDIR /go/src/github.com/nazarslota/gke-multi-cluster-load-balancing

COPY /go.mod .
COPY /go.sum .

RUN go mod download

COPY ./ ./
RUN CGO_ENABLED=0 GOOS=linux go build -o ./build/server .

FROM alpine:latest

WORKDIR /root/

COPY --from=builder /go/src/github.com/nazarslota/gke-multi-cluster-load-balancing/build/server ./

EXPOSE 50051

ENTRYPOINT ["./entrypoint.sh"]
CMD ["./server"]
