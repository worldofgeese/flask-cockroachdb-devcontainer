#!/usr/bin/env bash
poetry install
poetry export -f requirements.txt --output requirements.txt

mkdir -p $HOME/.kube
cp /usr/local/share/kube-localhost/config $HOME/.kube/config

mkdir -p $HOME/.config/gcloud
cp -r /usr/local/share/gcloud-localhost/* $HOME/.config/gcloud/
