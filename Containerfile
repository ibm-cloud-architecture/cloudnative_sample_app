# Build stage - could use maven or our image
FROM maven:3.3-jdk-8 as builder

COPY . .
RUN mvn clean install

FROM openliberty/open-liberty:springBoot2-ubi-min as staging

COPY --chown=1001:0 --from=builder /target/cloudnativesampleapp-1.0-SNAPSHOT.jar /config/app.jar
RUN springBootUtility thin \
    --sourceAppPath=/config/app.jar \
    --targetThinAppPath=/config/dropins/spring/thinClinic.jar \
    --targetLibCachePath=/opt/ol/wlp/usr/shared/resources/lib.index.cache




