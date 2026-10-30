# Multi-stage Docker build for CodeQuest (Java EE 10 / Tomcat 10.1)

# Stage 1: Build WAR with Maven
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Build project WAR
COPY src ./src
COPY WebContent ./WebContent
RUN mvn clean package -DskipTests

# Stage 2: Deploy on Tomcat 10.1 (Jakarta EE 10 compatible)
FROM tomcat:10.1-jdk17-temurin-jammy

# Remove default ROOT application
RUN rm -rf /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/examples /usr/local/tomcat/webapps/docs

# Copy WAR as ROOT application so it serves directly from / (and also /codequest)
COPY --from=builder /app/target/codequest.war /usr/local/tomcat/webapps/ROOT.war
COPY --from=builder /app/target/codequest.war /usr/local/tomcat/webapps/codequest.war

# Expose HTTP port
EXPOSE 8080

CMD ["catalina.sh", "run"]
