ARG BUILD_FROM
FROM ghcr.io/wez/govee2mqtt:latest AS govee2mqtt
FROM $BUILD_FROM

COPY run.sh /run.sh

# ⬇️ HIER kommt deine selbst kompilierte Binary rein
COPY bin/govee /app/govee

# ⬇️ Assets und Zertifikat weiterhin von wez
COPY --from=govee2mqtt /app/assets /app/assets/
COPY --from=govee2mqtt /app/AmazonRootCA1.pem /app/

CMD [ "/run.sh" ]
