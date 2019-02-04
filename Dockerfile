FROM phusion/baseimage:0.10.0

LABEL maintainer="Luis Jesus <luisjesus89@gmail.com>"

CMD ["/sbin/my_init"]

ENV LC_ALL "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LANG "en_US.UTF-8"

ENV VERSION_SDK_TOOLS "4333796"
ENV VERSION_BUILD_TOOLS "28.0.3"
ENV VERSION_TARGET_SDK "28"

ENV ANDROID_HOME "/android-sdk"

ENV PATH "$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools"
ENV DEBIAN_FRONTEND noninteractive

ENV HOME "/android"

RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get -y install --no-install-recommends \
    curl \
    openjdk-8-jdk \
    unzip \
    zip \
    git \
    ruby2.4 \
    ruby2.4-dev \
    build-essential \
    file \
    ssh

ADD https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip /tools.zip
RUN unzip /tools.zip -d $ANDROID_HOME && rm -rf /tools.zip

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

RUN mkdir -p $HOME/.android && touch $HOME/.android/repositories.cfg
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "platform-tools" "tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

# Install Fastlane

RUN gem install fastlane

# Install gcloud

RUN apt install python2.7 python-pip -y \
RUN apt-get install wget

RUN wget --quiet --output-document=/tmp/google-cloud-sdk.tar.gz https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz
RUN mkdir -p /opt
RUN tar zxf /tmp/google-cloud-sdk.tar.gz --directory /opt
RUN /opt/google-cloud-sdk/install.sh --quiet
RUN source /opt/google-cloud-sdk/path.bash.inc
RUN gcloud components update

ADD id_rsa $HOME/.ssh/id_rsa
ADD id_rsa.pub $HOME/.ssh/id_rsa.pub
ADD adbkey $HOME/.android/adbkey
ADD adbkey.pub $HOME/.android/adbkey.pub

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*