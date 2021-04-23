FROM golang:latest AS build
# build cloudflared (the official image is not yet available for arm64)
RUN git clone https://github.com/cloudflare/cloudflared.git
WORKDIR /go/cloudflared/
RUN make cloudflared

## simple http server (can replace with any server)
## this one listens on localhost:8080 and serves files out of /www
RUN mkdir /go/http-server
COPY http-server/main.go /go/http-server/
WORKDIR /go/http-server/
RUN go mod init github.com/cohunter/web-app-https-starter/http-server && go build -ldflags="-s -w"

## compress
WORKDIR /
RUN apt update && apt install -y upx
RUN upx -9 /go/http-server/http-server
RUN upx -9 /go/cloudflared/cloudflared

## startup script — launch server in background and then tunnel
RUN echo "#!/bin/sh" | tee /start.sh
RUN echo "/http-server &" | tee -a /start.sh
RUN echo "/cloudflared tunnel  --no-autoupdate --url http://localhost:8080 \$@" | tee -a /start.sh
RUN chmod +x /start.sh

FROM busybox:glibc
COPY --from=build /go/cloudflared/cloudflared /cloudflared
COPY --from=build /go/http-server/http-server /http-server
COPY --from=build /start.sh /start.sh
COPY --from=build /etc/ssl/certs /etc/ssl/certs
ENTRYPOINT [ "/start.sh" ]