#!/bin/bash

arch="amd64" || "i386"
version="1.8.1"
base_url="http://downloads-distro.mongodb.org/repo/ubuntu-upstart/dists/dist/10gen"
wget ${base_url}/binary-${arch}/mongodb-10gen_${version}_${arch}.deb
