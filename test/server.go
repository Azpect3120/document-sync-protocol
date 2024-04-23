package main

import (
	"bufio"
	"log"
	"net"
	"strings"
)

func main() {
	listener, err := net.Listen("tcp", "localhost:3270")
	if err != nil {
		log.Fatalf("Error starting listener: %s\n", err.Error())
	}
	defer listener.Close()

	log.Println("Successfully started server!")

	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Error accepting connection: %s\n", err.Error())
			continue
		}

		handleConnection(conn)
	}
}

func handleConnection(conn net.Conn) {
	// Close the connection
	defer conn.Close()
	defer log.Printf("Connection from %s closed.\n", conn.RemoteAddr().String())

	// Print connection details
	log.Printf("Client connected from %s\n", conn.RemoteAddr().String())

	reader := bufio.NewReader(conn)

	for {
		message, err := reader.ReadString('\n')
		if err != nil {
			if strings.Contains(err.Error(), "forcibly closed by the remote host") {
				break
			}

			log.Printf("Error reading data from connection %s: %s", conn.RemoteAddr().String(), err.Error())
			continue
		}
		log.Printf("[%s] %s", conn.RemoteAddr().String(), message)
	}
}
