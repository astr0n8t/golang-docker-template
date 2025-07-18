# Build Stage
ARG BUILDPLATFORM
FROM --platform=${BUILDPLATFORM} golang:1.24.5 AS build-stage

LABEL app="APP_NAME"
LABEL REPO="https://github.com/astr0n8t/APP_NAME"

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
# Copy all internal modules
COPY cmd/ ./cmd/
COPY pkg/ ./pkg/
COPY internal/ ./internal/
COPY version/ ./version/

ARG TARGETOS
ARG TARGETARCH

RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /APP_NAME

# Deploy the application binary into a lean image
FROM gcr.io/distroless/static-debian11 AS build-release-stage

WORKDIR /

COPY --from=build-stage /APP_NAME /APP_NAME

USER nonroot:nonroot

ENTRYPOINT ["/APP_NAME"]
