# Etapa 1: Build
FROM swift:5.9 as builder

WORKDIR /app

# 🧩 Agregar dependencias necesarias para compilar MongoDB Driver
RUN apt-get update && \
    apt-get install -y libssl-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

COPY . .
RUN swift build -c release

# Etapa 2: Producción
FROM swift:5.9-slim

WORKDIR /app
COPY --from=builder /app/.build/release/Run /app/
COPY --from=builder /app/Public ./Public
COPY --from=builder /app/Resources ./Resources

EXPOSE 8080
CMD ["./Run"]
