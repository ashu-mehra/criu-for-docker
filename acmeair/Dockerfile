FROM ashumehra/acmeair-monolithic:latest

USER root
RUN apt-get update && apt-get install -y --no-install-recommends criu iptables sudo vim psmisc \
    && sed -i 's/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL) NOPASSWD:ALL/' /etc/sudoers \
    && usermod -aG sudo default \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/appcr

RUN mkdir -p /opt/appcr/cr_logs \
    && chown -R 1001:0 /opt/appcr/cr_logs \
    && chmod -R g+rw /opt/appcr/cr_logs

ADD common_env_vars.sh /opt/appcr/common_env_vars.sh
ADD appcr.sh /opt/appcr/appcr.sh
ADD app.sh /opt/appcr/app.sh

RUN chown -R 1001:0 /opt/appcr/common_env_vars.sh \
    && chmod -R g+rw /opt/appcr/common_env_vars.sh \
    && chown -R 1001:0 /opt/appcr/appcr.sh \
    && chmod -R g+rw /opt/appcr/appcr.sh \
    && chown -R 1001:0 /opt/appcr/app.sh \
    && chmod -R g+rw /opt/appcr/app.sh

ARG user=root
USER $user

ENTRYPOINT ["/opt/appcr/appcr.sh"]
