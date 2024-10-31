#!/bin/bash

# Define a function to stop the Docker container
function stop_container() {
          echo "Stopping genoselect container..."
            docker stop $container_id
              echo "Genoselect container stopped."
      }

      # Run the genoselect container and get its ID
      echo "Starting genoselect container..."
      container_id=$(docker run -itd -p 4040:4040 -v "$(pwd)":/mount yfd2/ags:1.0.24 /bin/bash)
      echo "Genoselect container started with ID $container_id"

      # Run your R script in the container
docker exec $container_id Rscript opt/app/run.R &

# Print the Docker container logs
docker logs -f $container_id &

# Trap the SIGINT signal (ctrl+c) and call the stop_container function
trap stop_container SIGINT

# Wait for 3 seconds before opening the browser
sleep 4

# Open a new browser window and navigate to localhost:4040
if [ -z "$WSL_DISTRO_NAME" ]; then
          # This is not a WSL environment, use `open` to start the browser
            xdg-open http://localhost:4040
    else
              # This is a WSL environment, use `cmd.exe` to start the browser
                cmd.exe /c start http://localhost:4040
fi

# Listen for the session ended message
docker logs -f $container_id | while read line ; do
    if echo $line | grep -q "Session ended" ; then
                    stop_container
                            break
                                fi
                        done

                        # To ensure the script exits after stopping the container
                        exit 0
                        
