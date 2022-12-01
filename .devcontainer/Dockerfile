# See here for image contents
ARG VARIANT="3.10-slim"
FROM python:${VARIANT} as python-poetry-base

# from stackoverflow
ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_NO_CACHE_DIR=off \
    \
    # poetry vars
    POETRY_VERSION=1.2.0 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=true \
    \
    # paths
    # this is where requirements will live
    PYSETUP_PATH="/opt/setup" \
    \
    # this is where we toggle production or development mode
    PRODUCTION=false

# prepend poetry to path
ENV PATH="$POETRY_HOME/bin:$PATH"

###############################################################################
# POETRY BUILDER IMAGE - Installs Poetry and dependencies
###############################################################################
FROM python-poetry-base AS python-poetry-builder

RUN apt-get update \
    && apt-get install --no-install-recommends --assume-yes curl

RUN curl -L https://github.com/kubernetes/kompose/releases/download/v1.27.0/kompose-linux-amd64 -o kompose \
    && chmod +x kompose \
    && mv ./kompose /bin/kompose

RUN curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o yq \
    && chmod +x yq \
    && mv ./yq /bin/yq

RUN curl -sSL https://install.python-poetry.org | python3 -

###############################################################################
# POETRY RUNTIME IMAGE - Copies the poetry installation into a smaller image
###############################################################################
FROM python-poetry-base AS python-poetry
COPY --from=python-poetry-builder $POETRY_HOME $POETRY_HOME
COPY --from=python-poetry-builder /bin/kompose /bin/kompose
COPY --from=python-poetry-builder /bin/yq /bin/yq

# just verifying poetry installed properly as this should not flag for another reason
RUN echo poetry --version

WORKDIR $PYSETUP_PATH
COPY poetry.lock pyproject.toml ./
RUN poetry install $(test ${PRODUCTION} == true && echo "--no-dev")

# prepare to export requirements.txt
# RUN poetry self add poetry-plugin-export
RUN poetry export -f requirements.txt --output requirements.txt

WORKDIR /app

RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    && echo "$SNIPPET" >> "/root/.bashrc"


# USER vscode

# [Optional] If your pip requirements rarely change, uncomment this section to add them to the image.
# COPY requirements.txt /tmp/pip-tmp/
# RUN pip3 --disable-pip-version-check --no-cache-dir install -r /tmp/pip-tmp/requirements.txt \
#    && rm -rf /tmp/pip-tmp

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>

# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1