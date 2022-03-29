# syntax=docker/dockerfile:1


FROM ubuntu:focal as build-image

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    git 

RUN rm -rf /var/lib/apt/lists/*

ARG USER_ID
ARG GROUP_ID
ARG USERNAME

RUN groupdel dialout || true

RUN groupadd -g $GROUP_ID $USERNAME && \
    useradd --home /home/$USERNAME --shell /bin/bash -u $USER_ID -g $GROUP_ID $USERNAME &&\
    mkdir -p /home/$USERNAME && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && mkdir -p /opt/build

ENV NODE_VERSION=15.14.0
ENV NVM_DIR=/home/$USERNAME/.nvm
RUN mkdir -p $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.39.1/install.sh | bash
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="/home/$USERNAME/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

RUN chown -R $USERNAME:$USERNAME $NVM_DIR

RUN chown -R $USERNAME:$USERNAME /opt/build

COPY --chown=$USERNAME:$GROUP_ID ./docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod +x /bin/entrypoint.sh

COPY --chown=$USERNAME:$GROUP_ID . /opt/build

RUN npm install -g npm@latest yarn@latest
RUN cd /opt/build && yarn && yarn build:extension
RUN cd /opt/build/shells/chrome/build && ls -lah
USER $USERNAME

ENTRYPOINT [ "/bin/entrypoint.sh" ]

# WORKDIR /opt/artifacts

# FROM ubuntu:focal as final-image
# COPY --chown=$USERNAME:$GROUP_ID --from=build-image /opt/build/shells/chrome/build .