###############################################################################
# PDM BUILDER IMAGE - Installs PDM and dependencies
###############################################################################
# pull official base image
FROM python:3.11-slim AS builder

EXPOSE 5000

# set work directory
WORKDIR /usr/src/app

ENV PDM_HOME=/
ENV PULUMI_VERSION=3.50.2

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && curl -sL https://get.garden.io/install.sh | bash \
    && curl -fsSL https://get.pulumi.com/ | bash -s -- --version $PULUMI_VERSION \
    && curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/main/install-pdm.py | python3 -

# copy files
COPY pyproject.toml pdm.lock /project/

# install dependencies and project into the local packages directory
WORKDIR /project
RUN mkdir __pypackages__ && pdm install

###############################################################################
# PDM RUNTIME IMAGE - Copies PDM-installed packages into a smaller image
###############################################################################
FROM mcr.microsoft.com/devcontainers/base:debian as devcontainer

# Install Google Cloud SDK to enable authorization to GKE clusters
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  google-cloud-cli \
  google-cloud-sdk-gke-gcloud-auth-plugin && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ARG USERNAME=vscode

# retrieve packages from build stage
ENV PYTHONPATH=/project/pkgs/3.11/lib
ENV PATH="${PATH}:/project/pkgs/3.11/bin"
COPY --chown=$USERNAME --from=builder /project/__pypackages__/. /project/pkgs
# Garden can't be installed to /bin because Git will complain of dubious
# ownership so append a locally owned directory instead.
ENV PATH=/home/$USERNAME/.garden/bin:${PATH}
COPY --chown=$USERNAME --from=builder /root/.garden/bin/. /home/$USERNAME/.garden/bin/
COPY --from=builder /root/.pulumi/bin/. /bin/
