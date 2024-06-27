SHELL := "C:/Program Files/Git/bin/bash.exe"

build:
	@echo "Building the project..."
	GOOS=linux GOARCH=amd64 go build -o dist/simple-http-server

send-exe-to-remote-server: build
	@echo "Sending the executable to the remote server..."
	@echo "$(SERVER_SSH_KEY)" > /tmp/ec2-ssh.pem
	@chmod 600 /tmp/ec2-ssh.pem
	scp -i /tmp/ec2-ssh.pem ./dist/simple-http-server ec2-user@$(SERVER_IP):/home/ec2-user/
	@rm /tmp/ec2-ssh.pem

send-service-file-to-remote-server:
	@echo "Sending the service file to the remote server..."
	@echo "$(SERVER_SSH_KEY)" > /tmp/ec2-ssh.pem
	@chmod 600 /tmp/ec2-ssh.pem
	scp -i /tmp/ec2-ssh.pem ./http-server.service ec2-user@$(SERVER_IP):/home/ec2-user/
	@rm /tmp/ec2-ssh.pem

deploy: send-exe-to-remote-server send-service-file-to-remote-server
	@echo "Executing steps to make the server run in background"
	@echo "$(SERVER_SSH_KEY)" > /tmp/ec2-ssh.pem
	@chmod 600 /tmp/ec2-ssh.pem
	ssh -i /tmp/ec2-ssh.pem -t ec2-user@$(SERVER_IP) '\
		sudo mv /home/ec2-user/http-server.service /etc/systemd/system/http-server.service && \
		sudo systemctl daemon-reload && \
		sudo systemctl enable http-server && \
		sudo systemctl restart http-server'
	@rm /tmp/ec2-ssh.pem
