#!/bin/bash
CONTAINER_ID=$(crictl ps -a --label io.kubernetes.container.name=etcd --label io.kubernetes.pod.namespace=kube-system | awk 'NR>1{r=$1} $0~/Running/{exit} END{print r}')
if [[ -z $CONTAINER_ID ]]
then
  exit 1
fi
echo "ETCD контейнер: $CONTAINER_ID"
etcdctl="crictl exec $CONTAINER_ID etcdctl --cert /etc/kubernetes/pki/etcd/peer.crt --key /etc/kubernetes/pki/etcd/peer.key --cacert /etc/kubernetes/pki/etcd/ca.crt"

echo "Проверка состояния кластера"
$etcdctl member list -w table

echo "Создаем снапшот"
$etcdctl snapshot save /var/lib/etcd/snap1.db

echo "Перемащаем снапшот в домашнюю директорию"
date=`date '+%Y-%m-%d_%H:%M'`
mv /var/lib/etcd/snap1.db ~/snap_etcd_$date.db
echo "Снапшот создан:"
echo snap_etcd_$date.db
