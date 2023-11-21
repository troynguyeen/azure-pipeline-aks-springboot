#Using lightweight openjdk 17-alpine
FROM openjdk:17-slim

WORKDIR /app

COPY target/*.jar springapp.jar

RUN mkdir -p log

ENTRYPOINT ["java", "-jar"]

CMD ["-Dspring.profiles.active=production", "-DLOG_DIR=log", "springapp.jar"]