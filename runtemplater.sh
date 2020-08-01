#!/usr/bin/env bash
set -e
#test that kubeconfig setup properly
kubectl get node
if [[ -z "$COS_ACCESS_KEY_ID" ]]; then
	COS_ACCESS_KEY_ID=22222
fi
if [[ -z "$COS_SECRET_ACCESS_KEY" ]]; then
	COS_SECRET_ACCESS_KEY=222222
fi
if [[ -z "$COS_REGION" ]]; then
	COS_REGION=us-south
fi
if [[ -z "$COS_ETCD_BACKUPS_ENDPOINT" ]]; then
	COS_ETCD_BACKUPS_ENDPOINT=https://config.cloud-object-storage.cloud.ibm.com
fi
if [[ -z "$COS_ETCD_BACKUPS_BUCKET" ]]; then
	COS_ETCD_BACKUPS_BUCKET=cos-standard-xwl
fi
echo "generating etcd-operator resources"
ansible-playbook -vvv -i "localhost," -c local templater.yml -e ansible_python_interpreter="/usr/local/bin/python3" -e cos_access_key_id="${COS_ACCESS_KEY_ID}" \
	-e cos_secret_access_key="${COS_SECRET_ACCESS_KEY}" -e cos_etcd_backups_region="${COS_REGION}" -e cos_etcd_backups_endpoint="${COS_ETCD_BACKUPS_ENDPOINT}" \
	-e cos_etcd_backups_bucket="${COS_ETCD_BACKUPS_BUCKET}"
echo "finished generating etcd-operator resources"
kubectl apply -f outputdir/etcdclustercertsecrets
kubectl apply -f outputdir/etcdoperatormanifests
kubectl wait --for=condition=Available deploy etcd-operator --timeout=240s
read -p "Press any key to proceed to start provisioning the etcd cluster provisioning"
kubectl apply -f outputdir/etcdclustermanifests
sleep 5
kubectl wait --for=condition=Available etcdcluster/etcd-cluster1 --timeout=240s
read -p "Press any key to proceed to start upgrading the etcd cluster"
sed -i -e 's/version:.*/version: "3.4.3"/g' outputdir/etcdclustermanifests/etcd-cluster.yaml
kubectl apply -f outputdir/etcdclustermanifests
for i in $(seq 24); do
	CURRENT_VERSION=$(kubectl get etcdcluster etcd-cluster1 -o jsonpath='{.status.currentVersion}')
	if [[ "$CURRENT_VERSION" == "3.4.3" ]]; then
		break
	fi
	sleep 10
done
if [[ "$CURRENT_VERSION" == "3.4.3" ]]; then
	echo "upgrade completed"
else
	echo "upgrade failed"
	exit 1
fi
