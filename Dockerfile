FROM ubuntu:16.04
LABEL MAINTAINER Fethi Susam <fsusam@gmail.com>

ENV JAVA_HOME	/usr/lib/jvm/java-8-oracle
ENV JBOSS_HOME  /opt/jboss/wildfly-14.0.0.Final

RUN apt-get update && \
    apt-get upgrade -y && \
	apt-get --purge remove openjdk* && \
    apt-get install -y  software-properties-common && \
	apt-get install -y nano && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get clean
	
CMD mkdir /opt/jboss
	
WORKDIR /opt/jboss

RUN wget http://download.jboss.org/wildfly/14.0.0.Final/wildfly-14.0.0.Final.tar.gz && \
	tar -xvf wildfly-14.0.0.Final.tar.gz

WORKDIR $JBOSS_HOME/standalone/configuration/
	
# generate self signed certificate and import cacert
RUN  keytool -genkey -alias server -keyalg RSA -keystore \
     application.keystore -validity 10950 \
     -dname "CN=stubbed-enm, OU=ENM, O=ESON, L=Athlone, S=Westmeath, C=ESON" \
     -storepass password -keypass password
RUN keytool -export -alias server -storepass password  -file server.cer  -keystore application.keystore
RUN keytool -import -v -trustcacerts -alias server  -file server.cer -keystore cacert  -keypass password -storepass password -noprompt

# Host the service at HTTPS port
RUN sed -i -e 's/8443/443/g' $JBOSS_HOME/standalone/configuration/standalone.xml	

COPY ear/stubbed-enm-ear.ear  $JBOSS_HOME/standalone/deployments/stubbed-enm-ear.ear
COPY test_data/*.zip  /bulk/export/
COPY test_data/*.json  /opt/test_data/

EXPOSE 443

CMD ["/opt/jboss/wildfly-14.0.0.Final/bin/standalone.sh", "-b", "0.0.0.0"]