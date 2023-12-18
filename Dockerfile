FROM azul/zulu-openjdk-debian:17 AS builder

RUN apt-get update -qq && apt-get install -y wget && apt-get install -y unzip && apt install -y git

# Create a directory for the Gradle cache within the image
RUN mkdir -p /home/gradle/.gradle/caches

COPY . fineract
WORKDIR /fineract

RUN ./gradlew --no-daemon -q -x rat -x compileTestJava -x test -x spotlessJavaCheck -x spotlessJava bootJar

# RUN ./gradlew --no-daemon --info -q -x rat -x compileTestJava -x test -x spotlessJavaCheck -x spotlessJava bootJar

# Copy the Gradle cache to the Docker volume
# RUN cp -r /home/gradle/.gradle/caches /gradle-cache

#WORKDIR /fineract/target
#RUN jar -xf /fineract/fineract-provider/build/libs/fineract-provider*.jar

# We download separately a JDBC driver (which not allowed to be included in Apache binary distribution)

# RUN wget -q https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-8.1.0.zip

# RUN unzip mysql-connector-j-8.1.0.zip

#WORKDIR /fineract/target/BOOT-INF/libs
WORKDIR /fineract/libs
RUN wget -q https://downloads.mariadb.com/Connectors/java/connector-java-3.2.0/mariadb-java-client-3.2.0.jar
# RUN wget -q https://dlm.mariadb.com/3418098/Connectors/java/connector-java-3.2.0/mariadb-java-client-3.2.0-sources.jar

# RUN cp ../mysql-connector-j-8.1.0/mysql-connector-j-8.1.0.jar .


WORKDIR /
#RUN git clone -b 1.8.3 https://github.com/openMF/fineract-pentaho.git
#RUN cd fineract-pentaho && ./gradlew -x test distZip && cd ..

# Add our fineract-pentaho reporting plugin, like so:
#RUN unzip /fineract-pentaho/build/distributions/fineract-pentaho*.zip -d /fineract-pentaho/build/run/ && rm /fineract-pentaho/build/run/fineract-pentaho*/fineract-pentaho*.jar
#RUN cd /fineract-pentaho/build/run/fineract-pentaho*/lib/ && rm slf4j-api*.jar && rm javax*.jar && rm poi*.jar

# COPY /fineract/fineract-provider/build/libs/fineract-provider*.jar /fineract

# RUN git clone https://github.com/openMF/fineract-pentaho.git
# RUN cd fineract-pentaho && ./mvnw -Dmaven.test.skip=true clean package && cd ..

WORKDIR /build
RUN cp /fineract/fineract-provider/build/libs/fineract-provider*.jar .
COPY app/plugins /build/libs
COPY pentahoReports /data/pentahoReports/


################################## NEW SETUP #################################
# RUN git clone https://github.com/Chathu94/fineract-pentaho.git
# RUN cd fineract-pentaho && ./gradlew -x test distZip && cd .. && mkdir -p ~/.mifosx/pentahoReports/ && cp ./fineract-pentaho/pentahoReports/* ~/.mifosx/pentahoReports/
# RUN mkdir build/run && cp ../fineract/fineract-provider/build/libs/fineract-provider*.jar build/run
# RUN unzip build/distributions/fineract-pentaho.zip -d build/run/ && rm build/run/fineract-pentaho.jar
# RUN mkdir -p ~/.mifosx/pentahoReports/ && cp build/run/pentahoReports/* ~/.mifosx/pentahoReports/ && rm -rf build/run/pentahoReports


# =========================================

FROM azul/zulu-openjdk-debian:17 AS fineract

# COPY --from=builder /fineract/target/BOOT-INF/libs /app/lib
# COPY --from=builder /fineract/target/META-INF /app/META-INF
# COPY --from=builder /fineract/target/BOOT-INF/classes /app

# uncomment
COPY --from=builder /fineract/fineract-provider/build/libs /app
COPY --from=builder /fineract/libs /app/libs


# COPY --from=builder /fineract-pentaho/build /fineract-pentaho/build
# COPY --from=builder /fineract-pentaho/build/run/lib/ /app/libs
# COPY --from=builder /fineract-pentaho/build/run/fineract-pentaho*/lib/ /app/libs
# COPY --from=builder /build/libs /app/libs

# uncomment
COPY --from=builder /data/pentahoReports /app/pentahoReports
COPY --from=builder /data/pentahoReports /data/pentahoReports



WORKDIR /

#COPY ./app/plugins /app/libs

COPY entrypoint.sh /entrypoint.sh

RUN chmod 775 /entrypoint.sh

EXPOSE 443 8443

ENTRYPOINT ["/entrypoint.sh"]
