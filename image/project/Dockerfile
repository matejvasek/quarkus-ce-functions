## Stage 1 : build with maven builder image with native capabilities
FROM quay.io/quarkus/centos-quarkus-maven:19.3.1-java11 AS builder

COPY . /project

RUN mkdir -p /home/quarkus/.m2/repository/io
RUN tar fx /project/quarkus-mvn.tar.gz -C /home/quarkus/.m2/repository/io

RUN cd /project && mvn -B install dependency:go-offline -DskipTests
# Install user-app dependencies
WORKDIR /project/user-app
COPY ./user-app/src ./src
COPY ./user-app/pom.xml ./
USER root
RUN chown -R quarkus .
USER quarkus
RUN mvn -B clean package -Pnative

## Stage 2 : create the docker final image
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.1
WORKDIR /work/
COPY --from=builder /project/user-app/target/*-runner /work/application

# set up permissions for user `1001`
RUN chmod 775 /work /work/application \
  && chown -R 1001 /work \
  && chmod -R "g+rwX" /work \
  && chown -R 1001:root /work

EXPOSE 8080
USER 1001

CMD ["./application", "-Dquarkus.http.host=0.0.0.0"]
