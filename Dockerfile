# Builder phase.
FROM registry.ci.openshift.org/ocp/builder:rhel-8-golang-1.17-openshift-4.10 AS builder
MAINTAINER enriquebelarte@redhat.com
ENV GOPATH /usr/
RUN mkdir -p /usr/src/
WORKDIR /usr/src/
RUN git clone https://github.com/cdvultur/oc-dummy-device-plugin.git
WORKDIR /usr/src/oc-dummy-device-plugin
RUN go mod init && go mod tidy && go mod vendor 
RUN CGO_ENABLED=0 go build -a -o oc-dummy-device-plugin dummy.go

# Copy phase
FROM alpine:latest
# If you need to debug, add bash.
# RUN apk add --no-cache bash
COPY --from=builder /usr/src/oc-dummy-device-plugin/oc-dummy-device-plugin /oc-dummy-device-plugin
COPY --from=builder /usr/src/oc-dummy-device-plugin/dummyResources.json /dummyResources.json
ENTRYPOINT ["/oc-dummy-device-plugin"]
