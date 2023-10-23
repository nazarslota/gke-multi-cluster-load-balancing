package main

import (
	"crypto/tls"
	"crypto/x509"
	"flag"
	"fmt"
	"log"
	"net"
	"os"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/health"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"
)

const defaultPort = "50051"

func startServer(address string, useTLS bool, certFile string, keyFile string, caFile string) {
	var opts []grpc.ServerOption

	if useTLS {
		cert, err := tls.LoadX509KeyPair(certFile, keyFile)
		if err != nil {
			log.Fatalf("Failed to load server key pair: %v", err)
		}

		caData, err := os.ReadFile(caFile)
		if err != nil {
			log.Fatalf("Failed to read CA certificate: %v", err)
		}

		caPool := x509.NewCertPool()
		if !caPool.AppendCertsFromPEM(caData) {
			log.Fatalf("Failed to add CA certificate to pool")
		}

		tlsConfig := &tls.Config{
			Certificates: []tls.Certificate{cert},
			ClientAuth:   tls.RequireAndVerifyClientCert,
			ClientCAs:    caPool,
		}

		opts = append(opts, grpc.Creds(credentials.NewTLS(tlsConfig)))
	}

	lis, err := net.Listen("tcp", address)
	if err != nil {
		log.Fatalf("Failed to listen on %s: %v", address, err)
	}

	grpcServer := grpc.NewServer(opts...)

	// Health check setup
	healthServer := health.NewServer()
	healthServer.SetServingStatus("", healthpb.HealthCheckResponse_SERVING)
	healthpb.RegisterHealthServer(grpcServer, healthServer)

	reflection.Register(grpcServer)

	log.Printf("Starting gRPC server on %s", address)
	if err := grpcServer.Serve(lis); err != nil {
		log.Fatalf("Failed to serve gRPC server: %v", err)
	}
}

func main() {
	port := flag.String("port", defaultPort, "The port to bind the server")
	useTLS := flag.Bool("tls", false, "Enable TLS")
	certFile := flag.String("cert", "path/to/cert.pem", "The certificate file (required if TLS is enabled)")
	keyFile := flag.String("key", "path/to/key.pem", "The key file (required if TLS is enabled)")
	caFile := flag.String("ca", "path/to/ca.pem", "The CA certificate file (required if TLS is enabled)")

	flag.Parse()

	if *useTLS && (*certFile == "" || *keyFile == "" || *caFile == "") {
		log.Fatalf("You must provide paths to certificate, key, and CA files when TLS is enabled")
	}

	address := fmt.Sprintf("0.0.0.0:%s", *port)
	startServer(address, *useTLS, *certFile, *keyFile, *caFile)
}
