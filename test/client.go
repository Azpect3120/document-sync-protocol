package main

import (
	"context"
	"fmt"
	"log"
	"net"
	"os"
	"time"
)

func main() {
	// Create dialer with context that has a 30 second timeout
	var dialer net.Dialer
	ctx, cancel := context.WithTimeout(context.Background(), time.Second*30)
	defer cancel()

	conn, err := dialer.DialContext(ctx, "tcp", "localhost:3270")
	if err != nil {
		log.Fatalf("Error creating TCP connection: %s\n", err.Error())
	}
	defer conn.Close()
	defer log.Printf("Connection to %s closed.\n", conn.RemoteAddr().String())

	log.Printf("Connection made to %s from %s\n", conn.RemoteAddr().String(), conn.LocalAddr().String())

	start := time.Now()
	for {
		time.Sleep(time.Second)

		num, err := conn.Write([]byte(fmt.Sprintf("Client connection has been alive for %.0f seconds\n", time.Since(start).Seconds())))
		if err != nil {
			log.Println("Connection to the server was disconnected")
			os.Exit(0)
		}

		log.Printf("Wrote %d bytes to the server", num)
	}
}
