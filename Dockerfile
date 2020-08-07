#A Docker script which produces a simple container: an Apache web server that pulls a HTML page from AWS S3 and hosts it. Designed for AWS EKS.
FROM ubuntu:18.04

RUN apt-get update \
  && apt-get -qq -y install apache2 \
  && apt-get -qq -y install wget \
  && rm -rf /var/lib/apt/lists/*
  
RUN echo 'If you see this, something went wrong' > /var/www/html/index.html

RUN echo '. /etc/apache2/envvars' > /root/run_apache.sh && \
  echo 'mkdir -p /var/run/apache2' >> /root/run_apache.sh && \
  echo '/usr/sbin/apache2 -D FOREGROUND' >> /root/run_apache.sh && \
  chmod 755 /root/run_apache.sh
  
EXPOSE 80

CMD wget "my-bucket.s3.us-east-1.amazonaws.com/test-webpage.html" -O temp.html \
  && mv temp.html /var/www/html/index.html \
  && /root/run_apache.sh
