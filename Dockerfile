# cudaと利用するpytorchに応じて適切なものを選択
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04
WORKDIR /workspace
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 必要そうなライブラリをインストール
RUN apt-get update && apt-get install -y \
    sudo \
    build-essential \
    tzdata \
    git \
    vim \
    wget \
    zsh \
    curl \
    libbz2-dev \
    libffi-dev \
    liblzma-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libssl-dev \
    libxml2-dev \
    libxmlsec1-dev \
    llvm \
    make \
    tk-dev \
    xz-utils \
    zlib1g-dev \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# pyenvをインストール
##環境変数の設定
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
## pyenvでインストールするPythonのバージョンを指定
ARG PYTHON_VERSION="3.11.0"

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init --path)"' >> ~/.bashrc
RUN eval "$(pyenv init --path)"
## 指定したPythonをインストールしグローバルで認識するように設定
RUN pyenv install $PYTHON_VERSION && \
    pyenv global $PYTHON_VERSION

# poetryをインストール
RUN curl -sSL https://install.python-poetry.org | python -

## 依存関係をコピーしインストール
ENV PATH /root/.local/bin:$PATH
COPY ./pyproject.toml /workspace/
RUN poetry config virtualenvs.create false \
  && poetry install --no-interaction --no-ansi
