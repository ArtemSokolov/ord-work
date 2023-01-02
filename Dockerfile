
FROM gitpod/workspace-base

USER root

RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc |\
    tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc && \
    add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

RUN apt-get update && \
  apt-get install -y gdebi-core r-base

RUN wget https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2022.07.2-576-amd64.deb

RUN gdebi -n rstudio-server-2022.07.2-576-amd64.deb

RUN R -e 'install.packages("tidyverse")'
RUN R -e 'install.packages(c("qs", "microbenchmark", "remotes", "pdist", "rsample", "here"))'
RUN R -e 'remotes::install_github("labsyspharm/ordinalRidge")'

RUN echo "gitpod:gitpod" | chpasswd
USER gitpod
