FROM golang:1.9 as build
MAINTAINER Menzo Wijmenga
# Install dep for dependency management
RUN go get github.com/golang/dep/cmd/dep

# Install & Cache dependencies
COPY Gopkg.lock Gopkg.toml /go/src/slurp/
WORKDIR /go/src/slurp
RUN dep ensure -vendor-only

# Add app
COPY . /go/src/slurp
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o slurp .

# add slurp to alpine container to optimize for size
FROM alpine
WORKDIR /slurp
COPY --from=build /go/src/slurp/slurp /go/bin/slurp
COPY *.json /go/bin/
ENTRYPOINT [ "/go/bin/slurp" ]