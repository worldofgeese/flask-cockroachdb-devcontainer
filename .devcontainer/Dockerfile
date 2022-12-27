###############################################################################
# POETRY BUILDER IMAGE - Installs Poetry and dependencies
###############################################################################
FROM python:3.11-slim AS builder

ENV PYTHONPATH=/root/.config/pdm/pep5 \
    PDM_HOME=/ \
    PULUMI_VERSION=3.50.2

# install utility packages
RUN apt-get update \
    && apt-get install --no-install-recommends --assume-yes curl \
    && curl -L https://github.com/kubernetes/kompose/releases/download/v1.27.0/kompose-linux-amd64 -o kompose \
    && chmod +x kompose \
    && mv ./kompose /bin/kompose \
    && curl -sL https://get.garden.io/install.sh | bash \
    && curl -fsSL https://get.pulumi.com/ | bash -s -- --version $PULUMI_VERSION \
    && curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/main/install-pdm.py | python3 -

# copy files
COPY pyproject.toml pdm.lock /project/
# COPY pyproject.toml pdm.lock /project/

# install dependencies and project into the local packages directory
WORKDIR /project
RUN mkdir __pypackages__ && pdm install --prod --no-lock --no-editable

###############################################################################
# POETRY RUNTIME IMAGE - Copies PDM-installed packages into a smaller image
###############################################################################
FROM python:3.11-slim

# Install Google Cloud SDK to enable authorization to GKE clusters
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && \
  apt-get -y install --no-install-recommends \
  rsync \
  curl \
  apt-transport-https\
  ca-certificates \
  gnupg \
  lsb-release && \
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  google-cloud-cli \
  google-cloud-sdk-gke-gcloud-auth-plugin && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# retrieve packages from build stage
ENV PYTHONPATH=/venv/lib/python3.11/site-packages/pdm/pep582:/project/pkgs
COPY --from=builder /project/__pypackages__/3.11/lib /project/pkgs
COPY --from=builder /bin/kompose /bin/kompose
# ENV PATH=/root/.garden/bin:${PATH}
COPY --from=builder /root/.garden/bin/. /bin/
COPY --from=builder $PDM_HOME $PDM_HOME
COPY --from=builder /root/.pulumi/bin/. /bin/

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && echo "$SNIPPET" >> "/root/.bashrc"