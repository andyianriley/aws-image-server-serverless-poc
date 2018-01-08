FROM amazonlinux

RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
RUN /bin/bash -c "source /root/.nvm/nvm.sh; nvm install 6.10.3"

RUN curl --silent --location https://rpm.nodesource.com/setup_4.x | bash
RUN yum install -y gcc-c++

CMD /bin/bash -c "source /root/.nvm/nvm.sh; nvm use 6.10.3"

WORKDIR /workspace

CMD /bin/bash -c "source /root/.nvm/nvm.sh; npm install"
