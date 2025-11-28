ARG BUILD_FROM
ARG BUILDPLATFORM
ARG TARGETPLATFORM

############################
# Builder: Rust aus Source
############################
FROM --platform=$BUILDPLATFORM rust:1.81-bullseye AS builder

WORKDIR /app

# Build-Abhängigkeiten für TLS/HTTPS
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      pkg-config \
      libssl-dev \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Source-Code ins Build-Image kopieren
COPY Cargo.toml Cargo.lock ./
COPY build.rs ./
COPY src ./src
COPY assets ./assets
COPY AmazonRootCA1.pem ./

# Release-Build der govee-Binary
RUN cargo build --release -p govee

############################
# Finales Add-on-Image
############################
FROM $BUILD_FROM

# Startskript übernehmen
COPY run.sh /run.sh

# frisch gebaute Binary und Assets übernehmen
COPY --from=builder /app/target/release/govee /app/govee
COPY --from=builder /app/assets /app/assets/
COPY --from=builder /app/AmazonRootCA1.pem /app/

CMD ["/run.sh"]
