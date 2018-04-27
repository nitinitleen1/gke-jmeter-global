#!/usr/bin/env bash
#Script created to launch Jmeter tests directly from the current terminal without accessing the jmeter master pod. This script is meant for multi-cluster setup, for single cluster setup use start_test_single.sh
#After execution, test script jmx file may be deleted from the pod itself but not locally.

working_dir=`pwd`

for ctx in $(kubectl config get-contexts -o=name --kubeconfig $working_dir/clusters.yaml); do

  # This checks which cluster is selected and accordingly selects the appropriate jmeter test plan stored in the same directory.
  # e.g If context of palo-asia is selected then jmeter test plan for 'asia' region is assigned to 'jmx'. 

  if echo "$ctx" | grep -q "palo-asia"; then
	  jmx="palo-asia.jmx"
  elif echo "$ctx" | grep -q "palo-us"; then
	  jmx="palo-us.jmx"
  else 
	  jmx="palo-europe.jmx"
  fi

  master_pod=`kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" get po | grep jmeter-master | awk '{print $1}'`

  kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" cp $jmx $master_pod:/$jmx

  # Echo Starting Jmeter load test using xyz test plan

  echo "Starting Test for $ctx using test plan $jmx" 

  kubectl --kubeconfig $working_dir/clusters.yaml --context="${ctx}" exec -it $master_pod -- /jmeter/load_test $jmx &

done
