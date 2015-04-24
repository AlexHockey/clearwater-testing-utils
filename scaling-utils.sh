case $chef_env in
  # Set up small_cluster, large_cluster, and new_nodes_filter here.

  *)
    echo "Unrecognized chef_env: '$chef_env'"
    exit 1
    ;;
esac

knife_ssh()
{
  knife ssh -E $chef_env -x ubuntu "chef_environment:$chef_env AND $1" "$2"
}

banner()
{
  echo "***** $1 ($(date)) *****"
}

start_sprout_memcached()
{
  banner "Starting services on new nodes"
  knife_ssh "$new_nodes_filter" "sudo monit monitor sprout &&
                                 sudo monit monitor memcached &&
                                 sleep 15 &&
                                 sudo monit monitor poll_sprout_sip &&
                                 sudo monit monitor poll_sprout_http &&
                                 sudo monit monitor poll_memcached"
}

stop_sprout_memcached()
{
  banner "Stopping services on leaving nodes"
  knife_ssh "$new_nodes_filter" "sudo monit unmonitor sprout &&
                                 sudo monit unmonitor poll_sprout_sip &&
                                 sudo monit unmonitor poll_sprout_http &&
                                 sudo monit unmonitor memcached &&
                                 sudo monit unmonitor poll_memcached &&
                                 sudo service sprout start-quiesce &&
                                 sudo service memcached stop"
}

start_cluster_scale_up()
{
  banner "Starting cluster scale up"
  knife_ssh "role:sprout" "echo servers=$small_cluster | sudo tee /etc/clearwater/cluster_settings &&
                           echo new_servers=$large_cluster | sudo tee -a /etc/clearwater/cluster_settings &&
                           sudo service sprout reload &&
                           sudo service astaire reload"
}

finish_cluster_scale_up()
{
  banner "Finishing cluster scale up"
  knife_ssh "role:sprout" "sudo service astaire wait-sync"
  knife_ssh "role:sprout" "echo servers=$large_cluster | sudo tee /etc/clearwater/cluster_settings &&
                           sudo service sprout reload &&
                           sudo service astaire reload"
}

start_cluster_scale_down()
{
  banner "Starting cluster scale down"
  knife_ssh "role:sprout" "echo servers=$large_cluster | sudo tee /etc/clearwater/cluster_settings &&
                           echo new_servers=$small_cluster | sudo tee -a /etc/clearwater/cluster_settings &&
                           sudo service sprout reload &&
                           sudo service astaire reload"
}

finish_cluster_scale_down()
{
  banner "Finishing cluster scale down"
  knife_ssh "role:sprout" "sudo service astaire wait-sync"
  knife_ssh "role:sprout" "echo servers=$small_cluster | sudo tee /etc/clearwater/cluster_settings &&
                           sudo service sprout reload &&
                           sudo service astaire reload"
}

dns_scale_up()
{
  banner "Adding new nodes to DNS"
  knife dns records scaleup -E $chef_env
}

dns_scale_down()
{
  banner "Removing leaving nodes from DNS"
  knife dns records scaledown -E $chef_env
}

