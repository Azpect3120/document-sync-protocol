package main

import (
	"bufio"
	"context"
	"log"
	"net"
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

	for {
		message, err := bufio.NewReader(conn).ReadString('\n')
		if err != nil {
			log.Printf("Error reading data from connection: %s\n", err.Error())
			break
		}
		log.Printf("[%s] %s", conn.RemoteAddr().String(), message)
	}
}
