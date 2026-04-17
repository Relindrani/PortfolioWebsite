package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("Helios Event Processor running...")
	for {
		time.Sleep(5 * time.Second)
		fmt.Println("Polling for events...")
	}
}
