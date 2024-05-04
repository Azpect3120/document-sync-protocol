package main

import (
	"bufio"
	"context"
	"fmt"
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
				return
			}
			fmt.Printf("%s\n", message)
		}
	}
}

func connectionWriteLoop(conn net.Conn, ch chan struct{}) {
	var connect_event_1 string = `
    {
      "event": "server/connect",
      "host": "127.0.0.1:3270",
      "identifier": "Azpect",
      "password": ""
    }
    `

	var connect_event_2 string = `
    {
      "event": "server/connect",
      "host": "127.0.0.1:32700",
      "identifier": "CrookedShaft",
      "password": ""
    }
    `

	var sent bool = false

	for {
		time.Sleep(time.Second)
		if !sent {
			_, err := conn.Write([]byte(connect_event_1))
			if err != nil {
				log.Printf("Error sending data to server: %s\n", err.Error())
				ch <- struct{}{}
				return
			}
		} else {
			_, err := conn.Write([]byte(connect_event_2))
			if err != nil {
				log.Printf("Error sending data to server: %s\n", err.Error())
				ch <- struct{}{}
				return
			}
		}
		sent = true
	}

}
