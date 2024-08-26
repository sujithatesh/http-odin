package main

import "core:fmt"
import "core:net"
import "core:strings"
import "core:os"
import "core:time"
import "core:math"
import "core:bytes"

main :: proc(){
	add := net.Address(net.IP4_Address({127,0,0,1}))
	myEnd:net.Endpoint = {add, 8000}
	listen_socket, listen_error := net.listen_tcp(myEnd)

	if listen_error != nil {
		fmt.printf("listen_error: %s", listen_error)
	}

	client_soc, client_endpoint, accept_err := net.accept_tcp(listen_socket)

	handleMessages(client_soc)
	net.close(listen_socket)
}

handleMessages::proc(client_soc: net.TCP_Socket){
	time_now := time.now()
	for{
		duration : time.Duration = time.since(time_now)
		buf : [8]byte
		my_str : string

		bytes_recv, recv_tcp_error := net.recv_tcp(client_soc, buf[:])

		if recv_tcp_error != nil{
			fmt.printf("recv_tcp_error : %s", recv_tcp_error)
		}

		bytes_sent, send_tcp_error := net.send_tcp(client_soc, buf[:])

		if send_tcp_error != nil{
			fmt.printf("send_tcp_error : %s", send_tcp_error)
		}

		if f64(duration) > 0.5 * math.pow10(f64(9)) {
			if  bytes_recv > 1{
				time_now = time.now()
			}
			else {
				break;
			}
		}
	}
}
