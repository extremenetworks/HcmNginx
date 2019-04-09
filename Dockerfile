#FROM nginx:latest

#RUN apt-get update -y && apt-get install -y \
#    unzip \
#    openjdk-7-jre \
#    wget \
#    nginx

#WORKDIR /tmp

#RUN wget http://cdn.sencha.com/cmd/6.2.1/no-jre/SenchaCmd-6.2.1-linux-amd64.sh.zip

#RUN unzip SenchaCmd-6.2.1-linux-amd64.sh.zip
#COPY senchacmd.varfile /tmp/senchacmd.varfile

#RUN /tmp/`find SenchaCmd*.sh` -q -varfile /tmp/senchacmd.varfile -dir "/opt/sencha"
#RUN ln -s /opt/sencha/sencha /usr/local/bin/sencha

#COPY * /opt/demo/
#WORKDIR /opt/demo
#RUN sencha app build
#RUN cp -r build/production/demo/* /usr/share/nginx/html

# Based on the official Nginx docker image to serve content
FROM nginx

# We copy over our build to the Nginx server
#COPY build/production/AssetTrackingPortal /usr/share/nginx/html

# Copy the nginx config
COPY nginx-site.conf /etc/nginx/conf.d/default.conf

# Tell Docker we are going to use this port
EXPOSE 80