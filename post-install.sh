#!/bin/bash
#There is an issue with nbextensions configurator
# https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator/issues/82
#manually turn on extensions that are needed after installing
#packages
jupyter nbextension enable freeze/main --sys-prefix
jupyter nbextension enable hide_input/main --sys-prefix
jupyter nbextension enable hide_input_all/main --sys-prefix
jupyter nbextension enable varInspector/main --sys-prefix
jupyter nbextension enable comment-uncomment/main --sys-prefix
jupyter nbextension enable collapsible_headings/main --sys-prefix
jupyter nbextension enable toc2/main --sys-prefix
jupyter nbextension enable execute_time/ExecuteTime --sys-prefix
jupyter nbextension enable spellchecker/main --sys-prefix
jupyter nbextension enable table_beautifier/main --sys-prefix
python -m nltk.downloader all
