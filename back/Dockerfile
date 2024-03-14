FROM maven:3.9.6-eclipse-temurin-17-focal AS builder
WORKDIR /app
COPY pom.xml ./
COPY src ./src
RUN mvn install -DskipTests
 
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
EXPOSE 8080
COPY --from=builder /app/target/*.jar /app/*.jar
ENTRYPOINT ["java","-Dfile.encoding=UTF-8", "-jar", "/app/*.jar" ]
