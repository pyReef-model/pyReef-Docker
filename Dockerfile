# Pull base image.
FROM pyreefmodel/pyreef-dependencies-docker

MAINTAINER Tristan Salles

WORKDIR /build
RUN git clone https://github.com/pyReef-model/pyReef.git
WORKDIR /build/pyReef/Model/libUtils
RUN make clobber
RUN make dist
RUN pip install -e /build/pyReef

ENV TINI_VERSION v0.8.4
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

# Copy cluster configuration
RUN mkdir /root/.ipython
COPY profile_mpi /root/.ipython/profile_mpi

RUN mkdir /workspace && \
    mkdir /workspace/volume 

# Copy test files to workspace
RUN cp -av /build/pyReef/Test/* /workspace/

COPY run.sh /build
RUN chmod +x /build/run.sh

# setup space for working in
VOLUME /workspace/volume

# launch notebook
WORKDIR /workspace
EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/tini", "--"]

ENV LD_LIBRARY_PATH=/workspace/volume/pyReef/Model/libUtils:/build/pyReef/Model/libUtils
CMD /build/run.sh
