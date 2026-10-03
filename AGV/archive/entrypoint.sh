#!/usr/bin/env bash
set -e

# --- Start X server (virtual) ---
export DISPLAY="${DISPLAY:-:1}"
RES="${VNC_RESOLUTION:-1280x720}"

Xvfb "$DISPLAY" -screen 0 "${RES}x24" -ac +extension GLX +render -noreset &
sleep 1

# --- Start XFCE desktop ---
dbus-launch --exit-with-session startxfce4 >/tmp/xfce.log 2>&1 &
sleep 2

# --- Start VNC + noVNC ---
x11vnc -display "$DISPLAY" -forever -shared -nopw -rfbport 5900 >/tmp/x11vnc.log 2>&1 &
websockify --web=/usr/share/novnc/ 6080 localhost:5900 >/tmp/novnc.log 2>&1 &

# --- ROS environment ---
source /opt/ros/noetic/setup.bash

if [ -f /root/catkin_ws/devel/setup.bash ]; then
  source /root/catkin_ws/devel/setup.bash
fi

export GAZEBO_MODEL_PATH="/root/catkin_ws/src/aws-robomaker-small-warehouse-world/models:${GAZEBO_MODEL_PATH}"
export GAZEBO_RESOURCE_PATH="/root/catkin_ws/src/aws-robomaker-small-warehouse-world:${GAZEBO_RESOURCE_PATH}"

export ROS_MASTER_URI="${ROS_MASTER_URI:-http://localhost:11311}"
export ROS_IP="${ROS_IP:-127.0.0.1}"

echo "ROLE=${ROLE}"
echo "ROS_MASTER_URI=${ROS_MASTER_URI}"
echo "ROS_IP=${ROS_IP}"
echo "DISPLAY=${DISPLAY}"
echo "Starting roscore automatically..."
echo "Gazebo will NOT auto-launch."

grep -qxF 'source /opt/ros/noetic/setup.bash' /root/.bashrc || \
  echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc
grep -qxF '[ -f /root/catkin_ws/devel/setup.bash ] && source /root/catkin_ws/devel/setup.bash' /root/.bashrc || \
  echo '[ -f /root/catkin_ws/devel/setup.bash ] && source /root/catkin_ws/devel/setup.bash' >> /root/.bashrc

if ! pgrep -x "roscore" >/dev/null && ! pgrep -x "rosmaster" >/dev/null; then
  roscore >/tmp/roscore.log 2>&1 &
  sleep 3
  echo "roscore started."
else
  echo "roscore already running."
fi

# Keep container alive
tail -f /tmp/xfce.log /tmp/x11vnc.log /tmp/novnc.log /tmp/roscore.log