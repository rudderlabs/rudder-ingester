module rudder-ingester

go 1.23.2

require (
	github.com/prometheus/client_golang v1.20.5
	github.com/rudderlabs/rudder-go-kit v0.43.0
	github.com/valyala/fasthttp v1.56.0
)

replace github.com/gocql/gocql => github.com/scylladb/gocql v1.14.2 // fix for JetBrains IDEs

require (
	github.com/andybalholm/brotli v1.1.0 // indirect
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/cespare/xxhash/v2 v2.3.0 // indirect
	github.com/klauspost/compress v1.17.10 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/prometheus/client_model v0.6.1 // indirect
	github.com/prometheus/common v0.59.1 // indirect
	github.com/prometheus/procfs v0.15.1 // indirect
	github.com/valyala/bytebufferpool v1.0.0 // indirect
	golang.org/x/sys v0.25.0 // indirect
	google.golang.org/protobuf v1.34.2 // indirect
)
