# Kubecon EU 2020 Zero Database Downtime with etcd-operator: ETCD Cluster Provisioning and Upgrading

Presentation details: https://sched.co/Zeqj

This repo has automation used in this KubeCon talk.

The repo requires a Kubernetes cluster (KUBECONFIG exported), kubectl, cfssl, and ansible. Dependencies can be installed with the following commands:
```
#Linux
pip3 install ansible~=2.9
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssl_1.4.1_linux_amd64
curl -LO https://github.com/cloudflare/cfssl/releases/download/v1.4.1/cfssljson_1.4.1_linux_amd64
mv cfssl_1.4.1_linux_amd64 "/usr/local/bin/cfssl"
mv cfssljson_1.4.1_linux_amd64 "/usr/local/bin/cfssljson"
mv ./kubectl /usr/local/bin/kubectl
chmod +x /usr/local/bin/cfssl
chmod +x /usr/local/bin/cfssljson
chmod +x /usr/local/bin/kubectl


#Mac OSX
brew install python3
brew install kubectl
brew install cfssl
pip3 install ansible~=2.9
```

The main script is runtemplater.sh and can be ran with
`bash runtemplater.sh`

The script makes the assumption python3 is installed at `/usr/local/bin/python3`. This assumption can be changed by changing the
`-e ansible_python_interpreter="/usr/local/bin/python3"` variable to point to the location of python3 on the user's system. 
