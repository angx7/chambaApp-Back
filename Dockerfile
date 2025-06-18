# Etapa 1: Compilación de Vapor
FROM swift:5.9 as builder

WORKDIR /app

# Clona el repositorio directamente
RUN git clone https://github.com/angx7/ChambaApp-Back.git .

RUN swift build -c release

# Etapa 2: Imagen de producción
FROM swift:5.9-slim

WORKDIR /app

COPY --from=builder /app/.build/release/ChambaApp-Back /app/
COPY --from=builder /app/Public ./Public
COPY --from=builder /app/Resources ./Resources

EXPOSE 8080
CMD ["./ChambaApp-Back"]
