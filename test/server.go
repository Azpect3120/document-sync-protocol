package main

import (
	"bufio"
	"log"
	"net"
	"strings"
	"time"
)

var CONNECTIONS map[net.Addr]net.Conn = make(map[net.Addr]net.Conn)

const MAX_CONNECTIONS int8 = 5

func main() {
	listener, err := net.Listen("tcp", "localhost:3270")
	if err != nil {
		log.Fatalf("Error starting listener: %s\n", err.Error())
	}
	defer listener.Close()

	log.Println("Successfully started server!")

	for {
		conn, err := listener.Accept()
		if int8(len(CONNECTIONS)) < MAX_CONNECTIONS {
			CONNECTIONS[conn.RemoteAddr()] = conn

			if err != nil {
				log.Printf("Error accepting connection: %s\n", err.Error())
				continue
			}

			go handleConnection(conn)
		} else {
			log.Println("Max number of connections have already been made.")
			if err := conn.Close(); err != nil {
				log.Printf("Error closing overflown connection: %s\n", err.Error())
			}
		}
	}
}

func handleConnection(conn net.Conn) {
	// Close the connection
	defer conn.Close()
	defer log.Printf("Connection from %s closed.\n", conn.RemoteAddr().String())
	defer delete(CONNECTIONS, conn.RemoteAddr())

	// Print connection details
	log.Printf("Client connected from %s\n", conn.RemoteAddr().String())

	// Start connections write loop in new thread
	kill := make(chan struct{})
	go connectionWriteLoop(conn, kill)

	// Begin connections read loop
	reader := bufio.NewReader(conn)
	for {
		select {
		// Stop the connection if the writer signals a failure
		case <-kill:
			return
		default:
			message, err := reader.ReadString('\n')
			if err != nil {
				if strings.Contains(err.Error(), "forcibly closed by the remote host") {
					return
				}

				log.Printf("Error reading data from connection %s: %s", conn.RemoteAddr().String(), err.Error())
				continue
			}
			log.Printf("[%s] %s", conn.RemoteAddr().String(), message)
		}
	}
}

func connectionWriteLoop(conn net.Conn, ch chan struct{}) {
	// Write welcome message to client
	num, err := conn.Write([]byte("Welcome to the server!\n"))
	if err != nil {
		log.Printf("Error sending welcome message to %s: %s\n", conn.RemoteAddr().String(), err.Error())
		ch <- struct{}{}
		return
	}

	// Print success to console
	log.Printf("Sent welcome message(%d) to %s.\n", num, conn.RemoteAddr().String())

	for {
		time.Sleep(time.Second)
		_, err := conn.Write([]byte("Data: \n"))
		if err != nil {
			log.Printf("Error sending data to connection %s: %s\n", conn.RemoteAddr().String(), err.Error())
			ch <- struct{}{}
			return
		}
	}
}
