wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz
tar xvf helm-v3.0.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/

helm create avalon-helm

rm -rf avalon-helm/templates/*.yaml
rm -rf avalon-helm/templates/NOTES.txt
rm -rf avalon-helm/templates/tests/
rm -rf avalon-helm/*.yaml

cp -r helm-files/* avalon-helm/
