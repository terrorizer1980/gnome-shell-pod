ARG fedora_version=latest
FROM fedora:${fedora_version}

RUN dnf update -y && \
    dnf install -y gnome-session-xsession gnome-extensions-app vte291 libxslt \
                   gtk3-devel gtk4-devel glib2-devel \
                   xorg-x11-server-Xvfb xdotool xautomation \
                   sudo make patch jq unzip git npm

COPY etc /etc

# Start Xvfb via systemd on display :99.
# Add the gnomeshell user with no password.
# Unmask required on Fedora 32
RUN systemctl unmask systemd-logind.service console-getty.service getty.target && \
    systemctl enable xvfb@:99.service && \
    systemctl set-default multi-user.target && \
    systemctl --global disable dbus-broker && \
    systemctl --global enable dbus-daemon && \
    adduser -m -U -G users,adm,wheel gnomeshell && \
    echo "gnomeshell     ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add the scripts.
COPY bin /usr/local/bin

# dbus port
EXPOSE 1234

CMD [ "/usr/sbin/init", "systemd.unified_cgroup_hierarchy=0" ]
