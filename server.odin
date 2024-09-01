package main
import "core:fmt"
import "core:net"
import "core:strings"
import "core:os"
import "core:time"
import "core:math"
import "core:bytes"
import "core:mem"
import "core:sort"
import "core:strconv"

BUF_SIZE :: 10240
debug :: 1

Response :: struct{
	path : string,
	response_line : string,
	headers : string,
	data : string,
}

main :: proc(){
	add := net.Address(net.IP4_Address({127,0,0,1}))
	Endpoint:net.Endpoint = {add, 8000}
	listen_socket, listen_error := net.listen_tcp(Endpoint)

	if listen_error != nil {
		fmt.printf("listen_error: %s", listen_error)
	}

	client_soc, client_endpoint, accept_err := net.accept_tcp(listen_socket)

	handleMessages(client_soc)
	net.close(listen_socket)
}

handle_GET :: proc(segments:[]string, response:^Response){
	path:= segments[0]
	path = strings.trim_right(path, "\n")

	full_file_path := strings.concatenate({os.get_current_directory(),path})

	if os.exists(full_file_path){
		file, ferr := os.open(full_file_path)
		if ferr != 0{
			fmt.panicf("error: %d", ferr)
		}
		data, err := os.read_entire_file_from_handle(file)

		file_data := strings.clone_from_bytes(data)

		response.data = file_data
	}
	else {
		response.response_line = "404 NOT_FOUND"
	}

	response.path = full_file_path

	handle_HEAD(segments, response)
}

handle_HEAD :: proc(segments:[]string, response:^Response){
	file, file_error := os.open(response.path)
	file_size, file_size_error := os.file_size(file)

	filesize_string := fmt.tprint(file_size)

	response_header : string 

	if strings.contains(response.path,"http"){
		response_header = "Content-Type : text/html"
	}
	if strings.contains(response.path,"css"){
		response_header = "Content-Type : text/css"
	}
	if strings.contains(response.path,"js"){
		response_header = "Content-Type : text/javascript"
	}

	response_header = strings.concatenate({response_header,"\n", "Content-Length : ", filesize_string})
	if (response.response_line) == "" {
		response.response_line = "200 OK"
	}
	response.headers = response_header
}

Send_Response :: proc(response:^Response) -> string{
	Response:string = strings.concatenate({"HTTP/1.1 ", response.response_line, "\n", response.headers,"\n", "\r\n", response.data})
	return Response
}

parseHTTP :: proc (message:string) -> string{
	segments, split_err := strings.fields(message)
	response:Response

	if split_err != nil {
		fmt.panicf("split_err: %s", split_err)
	}

	switch segments[0] {
		case "GET" : 
			handle_GET(segments[1:], &response)
		case "HEAD" : 
			handle_HEAD(segments[1:], &response)
	}

	Response := Send_Response(&response)
	return Response
}

handleMessages :: proc(client_soc: net.TCP_Socket){
	time_now := time.now()
	for{
		duration : time.Duration = time.since(time_now)
		buf : [BUF_SIZE]byte

		bytes_recv, recv_tcp_error := net.recv_tcp(client_soc, buf[:])

		message := parseHTTP(strings.clone_from_bytes(buf[0:bytes_recv]))

		when debug == 1{
			fmt.println("---------------------------------------------- REQUEST -------------------------------------------")
			fmt.printf("\n\n %s", strings.clone_from_bytes(buf[0:bytes_recv]))
		}

		if recv_tcp_error != nil{
			fmt.printf("recv_tcp_error : %s", recv_tcp_error)
		}

		message = parseHTTP(strings.clone_from_bytes(buf[0:bytes_recv]))

		when debug == 1{
			fmt.println("---------------------------------------------- RESPONSE -------------------------------------------")
			fmt.printf("\n\n %s", (transmute([]u8)message))
		}


		bytes_sent, send_tcp_error := net.send_tcp(client_soc, transmute([]u8)(message))
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
