FROM amazonlinux:2017.09

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
RUN /bin/bash -c "source /root/.nvm/nvm.sh; nvm install 6.10.3"
RUN /bin/bash -c "mkdir /aws-image-server"
RUN echo "source ~/.nvm/nvm.sh; nvm use 6.10.3" > /aws-image-server/.bashrc
RUN curl --silent --location https://rpm.nodesource.com/setup_4.x | bash

RUN yum install -y gcc-c++
