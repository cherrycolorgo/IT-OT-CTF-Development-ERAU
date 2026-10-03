#!/usr/bin/env bash
set -e

# --- Start X server (virtual) ---
export DISPLAY="${DISPLAY:-:1}"
RES="${VNC_RESOLUTION:-1280x720}"

Xvfb $DISPLAY -screen 0 ${RES}x24 -ac +extension GLX +render -noreset &
sleep 1

# --- Start XFCE desktop ---
dbus-launch --exit-with-session startxfce4 >/tmp/xfce.log 2>&1 &
sleep 2

# --- Start VNC + noVNC ---
x11vnc -display $DISPLAY -forever -shared -nopw -rfbport 5900 >/tmp/x11vnc.log 2>&1 &
websockify --web=/usr/share/novnc/ 6080 localhost:5900 >/tmp/novnc.log 2>&1 &

# --- ROS environment ---
source /opt/ros/noetic/setup.bash

# Source our catkin workspace if present (warehouse world)
if [ -f /root/catkin_ws/devel/setup.bash ]; then
  source /root/catkin_ws/devel/setup.bash
fi

# Make Gazebo find the warehouse models/world files
export GAZEBO_MODEL_PATH=/root/catkin_ws/src/aws-robomaker-small-warehouse-world/models:${GAZEBO_MODEL_PATH}
export GAZEBO_RESOURCE_PATH=/root/catkin_ws/src/aws-robomaker-small-warehouse-world:${GAZEBO_RESOURCE_PATH}

# Optional: show key env in logs
echo "ROLE=${ROLE}"
echo "ROS_MASTER_URI=${ROS_MASTER_URI}"
echo "ROS_IP=${ROS_IP}"
echo "DISPLAY=${DISPLAY}"
echo "GAZEBO_MODEL_PATH=${GAZEBO_MODEL_PATH}"

# --- Role actions ---
if [ "${ROLE}" = "master" ]; then
  # Start ROS master
  roscore >/tmp/roscore.log 2>&1 &
  echo "roscore started."

elif [ "${ROLE}" = "sim" ]; then
  # Wait a moment for roscore
  sleep 3

  # Launch AWS small warehouse world
  WORLD=/root/catkin_ws/src/aws-robomaker-small-warehouse-world/worlds/small_warehouse.world
  roslaunch gazebo_ros empty_world.launch world_name:=$WORLD >/tmp/gazebo.log 2>&1 &
  echo "Warehouse world launched."

  # Spawn TurtleBot3 into the running Gazebo instance
  sleep 5
  export TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL:-burger}
  roslaunch turtlebot3_gazebo turtlebot3_robot.launch >/tmp/tb3_spawn.log 2>&1 &
  echo "TurtleBot3 spawned."

else
  echo "Unknown ROLE. Set ROLE=master or ROLE=sim"
fi

# Keep container alive
tail -f /tmp/xfce.log

