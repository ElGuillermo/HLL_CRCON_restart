#!/bin/bash
# ┌───────────────────────────────────────────────────────────────────────────┐
# │ Configuration                                                             │
# └───────────────────────────────────────────────────────────────────────────┘
#
# The complete path of the CRCON folder
# if not set, it will try to find any "hll_rcon_tool" folder on disk
# default : "/root/hll_rcon_tool"
# Note : some Ubuntu distros disable 'root' user,
#        you should use "/home/ubuntu/hll_rcon_tool" then
CRCON_folder_path="/root/hll_rcon_tool"

# Full stop CRCON before restart
# You can just restart it above a running instance (ie "no"),
# but some changes on environment parameters would be ignored
# So it's better to stop CRCON completely before starting it again
# Default : "yes"
fullstop="yes"

# Redis cache flush
# You should NOT enable this one until asked to do so
# That will force CRCON to read ~5 min of previous logs from the game server
# This will resend past automod/votemap/admin/etc messages, punishes and kicks
# Default : "no"
redis_cache_flush="no"

# Set to "yes" if you have modified any file that comes from CRCON repository
# First rebuild will take ~3-4 minutes. Subsequent ones will take ~30 seconds.
# Default : "yes"
rebuild_before_restart="yes"

# Delete logs before restart
# Default : "no"
delete_logs="no"

# Delete the obsolete Docker images, containers and build cache
# This will free a *lot* (several GBs) of disk space
# But the next build procedure will be *minutes* longer
# Default : "no"
clean_docker_stuff="no"

# Storage informations
# Default : "no"
storage_info="no"
#
# └───────────────────────────────────────────────────────────────────────────┘

this_script_dir=$(dirname -- "$( readlink -f -- "$0"; )";)
this_script_name=${0##*/}
current_dir=$(pwd | tr -d '\n')
if [ -n "$CRCON_folder_path" ]; then
  crcon_dir=$CRCON_folder_path
else
  crcon_dir=$(find / -name "hll_rcon_tool" 2>/dev/null)
fi

clear
printf "┌─────────────────────────────────────────────────────────────────────────────┐\n"
printf "│ CRCON restart                                                               │\n"
printf "└─────────────────────────────────────────────────────────────────────────────┘\n\n"
# Script must be launched using 'root' permissions
if [ "$(id -u)" -ne 0 ]; then
  printf "\033[31mError\033[0m :\nThis \033[37m%s\033[0m script must be run with full permissions\n\n" "$this_script_name"
  printf "You're not the 'root' user. You must elevate your permissions using 'sudo' :\n"
  printf "\033[36msudo sh ./%s\033[0m\n\n" "$this_script_name"
  exit
fi
# Script has been launched outside of CRCON folder
if [ ! "$current_dir" = "$crcon_dir" ]; then
  printf "\033[31mError\033[0m :\nThis \033[37m%s\033[0m script should be run from the CRCON folder\n\n" "$this_script_name"
  # A CRCON folder has been found
  if [ -n "$crcon_dir" ]; then
    printf "\033[32mV\033[0m Using \033[33m%s\033[0m as your CRCON folder path\n" "$crcon_dir"
    # This script is located in the CRCON folder
    if [ "$this_script_dir" = "$crcon_dir" ]; then
      printf "\033[32mV\033[0m This script is located in the CRCON folder\n"
      # There is a compose.yaml file in the CRCON folder
      if [ -f "$crcon_dir/compose.yaml" ] && [ -f "$crcon_dir/.env" ]; then
        printf "\033[32mV\033[0m The CRCON seems to be configured\n\n"
      # No compose.yaml file could be found in the CRCON folder
      else
        printf "\033[31mX\033[0m The CRCON doesn't seem to be configured\n\n"
      fi
      printf "\033[32mSolution\033[0m :\nenter the CRCON folder and relaunch the script using this command :\n"
      printf "\033[36mcd %s && sudo sh ./%s\033[0m\n\n" "$crcon_dir" "$this_script_name"
    # This script is located outside the CRCON folder
    else
      printf "This script is located here : \033[33m%s\033[0m\n" "$this_script_dir"
      printf "It should be located in the CRCON folder (\033[33m%s\033[0m)\n" "$crcon_dir"
      printf "\033[32mFixing...\033[0m\n"
      cp "$this_script_dir/$this_script_name" "$crcon_dir"
      printf "\033[32mV\033[0m \033[37m%s\033[0m has been copied into the CRCON folder.\n\n" "$this_script_name" "$crcon_dir"
      printf "\033[32mSolution\033[0m :\nenter the CRCON folder and relaunch the script using this command :\n"
      printf "\033[36mrm %s && cd %s && sudo sh ./%s\033[0m\n\n" "$this_script_dir/$this_script_name" "$crcon_dir" "$this_script_name"
    fi
  # No CRCON folder could be found
  else
    printf "We've searched everywhere, but unfortunately,\n"
    printf "\033[31mX\033[0m no \033[33mhll_rcon_tool\033[0m folder could be found on this disk partition.\n\n"
    printf "\033[32mSolution\033[0m :\nFind your CRCON folder, copy this script in it and relaunch it from there.\n\n"
    printf "  - Maybe you renamed the \033[33mhll_rcon_tool\033[0m folder ?\n"
    printf "    (it will work the same, but you'll have to adapt every maintenance script)\n\n"
    printf "If you followed the official install procedure,\n"
    printf "your \033[33mhll_rcon_tool\033[0m folder should be found here :\n"
    printf "  - \033[33m/root/hll_rcon_tool\033[0m        (most Linux installs)\n"
    printf "  - \033[33m/home/ubuntu/hll_rcon_tool\033[0m (some Ubuntu installs)\n\n"
  fi
# Script has been launched from the CRCON folder
else
  if [ $rebuild_before_restart = "yes" ]; then
    echo "┌──────────────────────────────────────┐"
    echo "│ Build CRCON                          │"
    echo "└──────────────────────────────────────┘"
    docker compose build
    echo "└──────────────────────────────────────┘"
    printf "Build CRCON : \033[32mdone\033[0m.\n\n"
  fi

  if [ $fullstop = "yes" ]; then
    echo "┌──────────────────────────────────────┐"
    echo "│ Stop CRCON                           │"
    echo "└──────────────────────────────────────┘"
    docker compose down
    if [ $delete_logs = "yes" ]; then
      printf "Deleting logs...\n"
      rm -r "$crcon_dir"/logs/*.*
      rm -r "$crcon_dir"/logs/old/*.*
      printf "Deleting logs : \033[32mdone\033[0m.\n"
    fi
    echo "└──────────────────────────────────────┘"
    printf "Stop CRCON : \033[32mdone\033[0m.\n\n"
  fi

  if [ $redis_cache_flush = "yes" ]; then
    echo "┌──────────────────────────────────────┐"
    echo "│ Redis cache flush                    │"
    echo "└──────────────────────────────────────┘"
    docker compose up -d redis
    docker compose exec redis redis-cli flushall
    docker compose down
    echo "└──────────────────────────────────────┘"
    printf "Redis cache flush : \033[32mdone\033[0m.\n\n"
  fi

  echo "┌──────────────────────────────────────┐"
  echo "│ Restart CRCON                        │"
  echo "└──────────────────────────────────────┘"
  docker compose up -d --remove-orphans
  echo "└──────────────────────────────────────┘"
  printf "Restart CRCON : \033[32mdone\033[0m.\n\n"

  if [ $clean_docker_stuff = "yes" ]; then
    echo "┌──────────────────────────────────────┐"
    echo "│ Cleaning Docker stuff                │"
    echo "└──────────────────────────────────────┘"
    docker system prune -a -f
    # docker builder prune --all
    # docker buildx prune --all
    docker volume rm $(docker volume ls -qf dangling=true)
    echo "└──────────────────────────────────────┘"
    printf "Cleaning : \033[32mdone\033[0m.\n\n"
  fi

  if [ $storage_info = "yes" ]; then
    echo "┌──────────────────────────────────────┐"
    echo "│ CRCON storage information            │"
    echo "└──────────────────────────────────────┘"
    { printf "CRCON total size     : "; du -sh "$crcon_dir" | tr -d '\n'; }
    printf "\n────────────────────────────────────────"
    { printf "\n └ Database          : "; du -sh "$crcon_dir"/db_data | tr -d '\n'; }
    db_command="docker exec -it hll_rcon_tool-postgres-1 psql -U rcon -d rcon -t -A -c "
    db_table_size="SELECT pg_size_pretty(pg_total_relation_size('public."
    db_rows_count="SELECT COUNT(*) FROM public."
    { printf "\n   └ audit_log       : "; ($db_command "$db_table_size""audit_log'));") | tr -d ' \t\r\n'; printf "\t("; ($db_command "$db_rows_count""audit_log";) | tr -d ' \t\r\n'; printf " rows)\n"; }
    { printf "   └ log_lines       : "; ($db_command "$db_table_size""log_lines'));") | tr -d ' \t\r\n'; printf "\t("; ($db_command "$db_rows_count""log_lines";) | tr -d ' \t\r\n'; printf " rows)\n"; }
    { printf "   └ player_names    : "; ($db_command "$db_table_size""player_names'));") | tr -d ' \t\r\n'; printf "\t("; ($db_command "$db_rows_count""player_names";) | tr -d ' \t\r\n'; printf " rows)\n"; }
    { printf "   └ player_sessions : "; ($db_command "$db_table_size""player_sessions'));") | tr -d ' \t\r\n'; printf "\t("; ($db_command "$db_rows_count""player_sessions";) | tr -d ' \t\r\n'; printf " rows)\n"; }
    { printf "   └ player_stats    : "; ($db_command "$db_table_size""player_stats'));") | tr -d ' \t\r\n'; printf "\t("; ($db_command "$db_rows_count""player_stats";) | tr -d ' \t\r\n'; printf " rows)\n"; }
    { printf "   └ players_actions : "; ($db_command "$db_table_size""players_actions'));") | tr -d ' \t\r\n'; printf "\t("; ($db_command "$db_rows_count""players_actions";) | tr -d ' \t\r\n'; printf " rows)\n"; }
    { printf "   └ steam_id_64     : "; ($db_command "$db_table_size""steam_id_64'));") | tr -d ' \t\r\n'; printf "\t("; ($db_command "$db_rows_count""steam_id_64";) | tr -d ' \t\r\n'; printf " rows)\n"; }
    { printf "   └ steam_info      : "; ($db_command "$db_table_size""steam_info'));") | tr -d ' \t\r\n'; printf "\t("; ($db_command "$db_rows_count""steam_info";) | tr -d ' \t\r\n'; printf " rows)\n"; }
    { printf " └ Logs              : "; du -sh "$crcon_dir"/logs | tr -d '\n'; }
    { printf "\n └ Redis cache       : "; du -sh "$crcon_dir"/redis_data | tr -d '\n'; }
    printf "\n└──────────────────────────────────────┘\n\n"
  fi
  
  printf "Wait for a full minute before using CRCON's interface.\n\n"
fi
exit
