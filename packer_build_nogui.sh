#!/bin/bash

nohup packer build -force -var "headless=true" template.json &
