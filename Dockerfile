FROM phusion/baseimage:master

LABEL maintainer="Luis Jesus <luisjesus89@gmail.com>"

CMD ["/sbin/my_init"]

ENV LC_ALL "en_US.UTF-8"
ENV LANGUAGE "en_US.UTF-8"
ENV LANG "en_US.UTF-8"

ENV VERSION_SDK_TOOLS "4333796"
ENV VERSION_BUILD_TOOLS "29.0.2"
ENV VERSION_TARGET_SDK "28"

ENV HOME "/android"
ENV ANDROID_HOME "/android-sdk"

ENV PATH "$PATH:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${HOME}/google-cloud-sdk/bin"
ENV DEBIAN_FRONTEND noninteractive

# Install gcloud
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-add-repository ppa:brightbox/ruby-ng
RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get -y install \ 
    ruby2.4 \
    ruby2.4-dev \
    unzip \
    openjdk-8-jdk \
    build-essential \
    google-cloud-sdk \
    git

ADD https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip /tools.zip
RUN unzip /tools.zip -d $ANDROID_HOME && rm -rf /tools.zip

RUN mkdir -p /root/.android && touch /root/.android/repositories.cfg
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "platform-tools" "tools" "platforms;android-${VERSION_TARGET_SDK}" "build-tools;${VERSION_BUILD_TOOLS}"
RUN ${ANDROID_HOME}/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

# Install Fastlane
RUN gem install fastlane
RUN fastlane update_fastlane

# Install Fastlane CLI
RUN curl -Lo /usr/local/bin/firebase https://firebase.tools/bin/linux/latest
RUN chmod +x /usr/local/bin/firebase

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
