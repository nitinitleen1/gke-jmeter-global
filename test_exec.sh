#!/usr/bin/env bash

working_dir=`pwd`

# For every cluster, copy the load_test config map element to /jmeter folder and make it executable.

for ctx in $(kubectl config get-contexts -o=name --kubeconfig $working_dir/clusters.yaml); do

  master_pod=`kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" get po | grep jmeter-master | awk '{print $1}'`

  kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" exec -it $master_pod -- cp -r /load_test /jmeter/load_test

  kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" exec -it $master_pod -- chmod 755 /jmeter/load_test

done
