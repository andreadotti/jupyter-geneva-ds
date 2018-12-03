FROM jupyter/scipy-notebook
USER jovyan
COPY . /source
RUN conda env update -n base -f /source/environment.yml
RUN cp /source/readme.md work/README.md && \
    echo "## List of installed packages\n\n" >> work/README.md && \
    echo "\`\`\`" >> work/README.md && \ 
    conda list >> work/README.md  && \
    echo "\`\`\`" >> work/README.md  
RUN pandoc -s -f markdown -t html --metadata title=README -o work/README.html work/README.md
RUN . /source/post-install.sh