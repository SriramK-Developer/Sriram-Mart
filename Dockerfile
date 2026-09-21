# ---- build ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /src
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B -DskipTests package

# ---- run ----
FROM eclipse-temurin:17-jre
WORKDIR /app
RUN useradd --system --create-home srirammart && mkdir -p /app/data /app/uploads && chown -R srirammart /app
COPY --from=build /src/target/srirammart-1.0.0.jar /app/app.jar
USER srirammart
ENV UPLOAD_DIR=/app/uploads

# 1. CHANGE THIS FROM 8080 TO 10000
EXPOSE 10000

VOLUME ["/app/data", "/app/uploads"]

# 2. OPTIONAL BUT RECOMMENDED: Force Spring to read the PORT variable directly at entrypoint
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-Dserver.port=${PORT:10000}", "-jar", "/app/app.jar"]
