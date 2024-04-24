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

	// Print connection details
	log.Printf("Connection made to %s from %s\n", conn.RemoteAddr().String(), conn.LocalAddr().String())

	// Start connection write loop in new thread
	kill := make(chan struct{})
	go connectionWriteLoop(conn, kill)

	// Begin connection read loop
	reader := bufio.NewReader(conn)
	for {
		select {
		case <-kill:
			return
		default:
			message, err := reader.ReadString('\n')
			if err != nil {
				log.Printf("Error reading data from connection: %s\n", err.Error())
				break
			}
			log.Printf("[%s] %s", conn.RemoteAddr().String(), message)
		}
	}
}

func connectionWriteLoop(conn net.Conn, ch chan struct{}) {
	// Write welcome message to client
	num, err := conn.Write([]byte("Thank you!\n"))
	if err != nil {
		log.Printf("Error sending response message: %s\n", err.Error())
		ch <- struct{}{}
		return
	}

	// Print success to console
	log.Printf("Sent response message(%d)\n", num)

	for {
		time.Sleep(time.Second * 5)
		_, err := conn.Write([]byte("Data: \n"))
		if err != nil {
			log.Printf("Error sending data to server: %s\n", err.Error())
			ch <- struct{}{}
			return
		}
	}

}
