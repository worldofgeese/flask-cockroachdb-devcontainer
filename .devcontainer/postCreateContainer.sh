#!/usr/bin/env bash
eval "$(pdm --pep582)"

pdm export -o requirements.txt

mkdir -p $HOME/.kube
cp /usr/local/share/kube-localhost/config $HOME/.kube/config

mkdir -p $HOME/.config/gcloud
cp -r /usr/local/share/gcloud-localhost/* $HOME/.config/gcloud/

mkdir -p $HOME/.pulumi
cp -r /usr/local/share/pulumi-localhost/* $HOME/.pulumi/
