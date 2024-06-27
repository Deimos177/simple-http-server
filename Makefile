SHELL := /bin/bash

build:
	@echo "Building the project..."
	GOOS=linux GOARCH=amd64 go build -o dist/simple-http-server

send-exe-to-remote-server: build
	@echo "Sending the executable to the remote server..."
	ssh -t ec2-user@$(SERVER_IP) 'sudo systemctl stop http-server'
	scp ./dist/simple-http-server ec2-user@$(SERVER_IP):/home/ec2-user/

send-service-file-to-remote-server:
	@echo "Sending the service file to the remote server..."
	scp ./http-server.service ec2-user@$(SERVER_IP):/home/ec2-user/

deploy: send-exe-to-remote-server send-service-file-to-remote-server
	@echo "Executing steps to make the server run in background"
	ssh -t ec2-user@$(SERVER_IP) '\
		sudo mv /home/ec2-user/http-server.service /etc/systemd/system/http-server.service && \
		sudo systemctl daemon-reload && \
		sudo systemctl enable http-server && \
		sudo systemctl restart http-server'
