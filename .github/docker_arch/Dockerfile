FROM archlinux:latest

RUN \
useradd dot; \
mkdir /home/dot; \
chown dot /home/dot; \
pacman -Sy --noconfirm sudo; \
echo 'dot ALL=NOPASSWD: ALL' >>/etc/sudoers

USER dot
WORKDIR /home/dot
COPY init.sh /init.sh

ENTRYPOINT /init.sh
