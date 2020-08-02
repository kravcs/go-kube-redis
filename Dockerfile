# # build stage
# FROM golang:alpine AS build-env
# LABEL stage=build-env
# WORKDIR /src
# COPY . .
# RUN CGO_ENABLED=0 GOOS=linux go build -a -o goapp .

# # final stage
# FROM alpine
# WORKDIR /
# COPY --from=build-env /src/goapp .

# # executable
# ENTRYPOINT [ "./goapp" ]


FROM golang:alpine AS build-env
RUN mkdir /go/src/app && apk update && apk add git
ADD . /go/src/app/
WORKDIR /go/src/app
RUN go mod download && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o app .

FROM scratch
WORKDIR /app
COPY --from=build-env /go/src/app/app .
COPY --from=build-env /go/src/app/config.json .

ENTRYPOINT [ "./app" ]