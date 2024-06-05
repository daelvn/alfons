#/usr/bin/env bash
complete -W "$(alfons --list | xargs)" alfons
