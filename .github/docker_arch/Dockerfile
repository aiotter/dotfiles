FROM archlinux:latest

RUN \
useradd dot; \
mkdir /home/dot; \
chown dot /home/dot; \
pacman -Sy --noconfirm sudo; \
echo 'dot ALL=NOPASSWD: ALL' >>/etc/sudoers

USER dot
WORKDIR /home/dot

RUN \
sudo pacman -S --noconfirm --needed git; \
git clone "https://github.com/${GITHUB_REPOSITORY} dotfiles"; \
git checkout "$GITHUB_SHA"

ENTRYPOINT dotfiles/deploy/deploy.sh
