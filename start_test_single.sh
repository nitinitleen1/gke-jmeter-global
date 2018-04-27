#!/usr/bin/env bash

#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod. This script is meant for a single cluster only. For multi cluster setup use start_test_multi.sh
#It requires that you supply the path to the jmx file
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=`pwd`

read -p 'Enter path to the jmx file ' jmx

if [ ! -f "$jmx" ];
then
    echo "Test script file was not found in PATH"
    echo "Kindly check and input the correct file path"
    exit
fi

for ctx in $(kubectl config get-contexts -o=name --kubeconfig $working_dir/clusters.yaml); do
  
  master_pod=`kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" get po | grep jmeter-master | awk '{print $1}'`

  kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" cp $jmx $master_pod:/$jmx

  # Echo Starting Jmeter load test

  echo "Starting Jmeter test for $ctx using test plan $jmx"

  kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" exec -it $master_pod -- /jmeter/load_test $jmx

done
