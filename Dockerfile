FROM anapsix/alpine-java
COPY ./credhub-acceptance-tests /usr/src/acceptance/src/github.com/cloudfoundry-incubator/credhub-acceptance-tests
COPY ./credhub/build/libs/credhub.jar /usr/src/credhub/credhub.jar
RUN mkdir -p /usr/src/credhub/src/main /usr/src/credhub/test
COPY ./credhub/src/main/resources /usr/src/credhub/src/main/resources
COPY ./credhub/src/test/resources /usr/src/credhub/src/test/resources
COPY truststore_setup.sh /usr/src/credhub/truststore_setup.sh
ENV GOPATH=/usr/src/acceptance \
    JAVA_HOME=/opt/jdk
WORKDIR /usr/src/credhub
#RUN ./truststore_setup.sh

COPY ./entrypoint.sh /usr/src/credhub/entrypoint.sh
ENTRYPOINT ["./entrypoint.sh"]
