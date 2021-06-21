kFROM paperist/alpine-texlive-ja:latest

WORKDIR /workdir

COPY sty/* /root/texmf/tex/latex/mymacros/

RUN curl -L http://mirrors.ctan.org/install/macros/latex/contrib/siunitx.tds.zip >siunitx.zip && \
    unzip -d /root/texmf siunitx.zip
