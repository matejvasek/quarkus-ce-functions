## Stage 1 : build with maven builder image with native capabilities
FROM quay.io/boson/centos-quarkus-maven:19.3.1-java11-20200426 AS builder

USER root
RUN mkdir -p /proj/user-app
COPY ./pom.xml /proj
RUN chown -R quarkus /proj
USER quarkus

WORKDIR /proj

RUN mvn -B install dependency:go-offline -DskipTests

# Install user-app dependencies
WORKDIR /proj/user-app

COPY --chown=quarkus:quarkus ./user-app/pom.xml ./pom.xml
RUN mvn -B compile dependency:go-offline

COPY --chown=quarkus:quarkus ./user-app/src ./src
RUN mvn -B package -Pnative

## Stage 2 : create the docker final image
FROM registry.access.redhat.com/ubi8/ubi-minimal:latest
WORKDIR /work/
COPY --from=builder /proj/user-app/target/*-runner /work/application

# set up permissions for user `1001`
RUN chmod 775 /work /work/application \
  && chown -R 1001 /work \
  && chmod -R "g+rwX" /work \
  && chown -R 1001:root /work

EXPOSE 8080
USER 1001

CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]
