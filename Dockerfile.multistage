# Build stage - could use maven or our image
FROM maven:3.3-jdk-8 as builder

# Creating Work directory
ENV BUILD_DIR=/usr/src/app/
RUN mkdir $BUILD_DIR
WORKDIR $BUILD_DIR

# Reuse local .m2. if not all the dependencies will be always downloaded
# This can be removed if you want to
VOLUME ${HOME}/.m2:/root/.m2
ADD . /usr/src/app

RUN bash -c " mvn clean install"

FROM openliberty/open-liberty:springBoot2-ubi-min as staging
USER root

# Create app directory
ENV APP_HOME=/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy jar file over from builder stage
COPY --from=builder /usr/src/app/target/cloudnativesampleapp-1.0-SNAPSHOT.jar $APP_HOME
RUN mv ./cloudnativesampleapp-1.0-SNAPSHOT.jar app.jar

RUN springBootUtility thin \
    --sourceAppPath=app.jar \
    --targetThinAppPath=/staging/thinClinic.jar \
    --targetLibCachePath=/staging/lib.index.cache

FROM openliberty/open-liberty:springBoot2-ubi-min
USER root
COPY --from=staging /staging/lib.index.cache /opt/ol/wlp/usr/shared/resources/lib.index.cache
COPY --from=staging /staging/thinClinic.jar /config/dropins/spring/thinClinic.jar

RUN chown -R 1001.0 /config && chmod -R g+rw /config
RUN chown -R 1001.0 /opt/ol/wlp/usr/shared/resources/lib.index.cache && chmod -R g+rw /opt/ol/wlp/usr/shared/resources/lib.index.cache

USER 1001
