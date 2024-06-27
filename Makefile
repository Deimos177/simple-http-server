SHELL := C:/Program Files/Git/bin/bash.exe
build:
		@echo "Building the project..."
		GOOS=linux GOARCH=amd64 go build -o dist/simple-http-server
send-exe-to-remote-server:
		@echo "Sending the executable to the remote server..."
		scp -i "C:/Users/bruce/.ssh/ec2-ssh.pem" ./dist/simple-http-server ec2-user@$(SERVER_IP):~
send-service-file-to-remote-server:
		@echo "Sending the service file to the remote server..."
		scp -i "C:/Users/bruce/.ssh/ec2-ssh.pem" ./http-server.service ec2-user@$(SERVER_IP):~
deploy: build send-exe-to-remote-server send-service-file-to-remote-server
		@echo "Executing steps to make the server run in background"
		ssh -i "C:/Users/bruce/.ssh/ec2-ssh.pem" -t ec2-user@$(SERVER_IP) '\
				sudo mv /home/ec2-user/http-server.service /etc/systemd/system/http-server.service && \
				sudo systemctl daemon-reload && \
				sudo systemctl enable http-server && \
				sudo systemctl restart http-server'