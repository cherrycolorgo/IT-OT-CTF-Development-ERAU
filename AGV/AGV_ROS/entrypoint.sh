#!/usr/bin/env bash
set -e

export DISPLAY="${DISPLAY:-:1}"
RES="${VNC_RESOLUTION:-1280x720}"

# --- Virtual display ---
Xvfb "$DISPLAY" -screen 0 "${RES}x24" -ac +extension GLX +render -noreset &
sleep 1

# --- XFCE desktop ---
dbus-launch --exit-with-session startxfce4 >/tmp/xfce.log 2>&1 &
sleep 2

# --- VNC + noVNC ---
x11vnc -display "$DISPLAY" -forever -shared -nopw -rfbport 5900 >/tmp/x11vnc.log 2>&1 &
websockify --web=/usr/share/novnc/ 6080 localhost:5900 >/tmp/novnc.log 2>&1 &

# --- ROS environment ---
source /opt/ros/noetic/setup.bash
[ -f /root/catkin_ws/devel/setup.bash ] && source /root/catkin_ws/devel/setup.bash

export ROS_MASTER_URI="${ROS_MASTER_URI:-http://localhost:11311}"
export ROS_IP="${ROS_IP:-127.0.0.1}"
export TURTLEBOT3_MODEL="${TURTLEBOT3_MODEL:-burger}"

# Persist env in .bashrc for terminal sessions
grep -qxF 'source /opt/ros/noetic/setup.bash' /root/.bashrc || \
  echo 'source /opt/ros/noetic/setup.bash' >> /root/.bashrc
grep -qxF '[ -f /root/catkin_ws/devel/setup.bash ] && source /root/catkin_ws/devel/setup.bash' /root/.bashrc || \
  echo '[ -f /root/catkin_ws/devel/setup.bash ] && source /root/catkin_ws/devel/setup.bash' >> /root/.bashrc
grep -qxF 'export TURTLEBOT3_MODEL=burger' /root/.bashrc || \
  echo 'export TURTLEBOT3_MODEL=burger' >> /root/.bashrc

# --- roscore ---
roscore >/tmp/roscore.log 2>&1 &
sleep 3
echo "roscore started."

echo ""
echo "=========================================="
echo "  ROS/Gazebo Aviation Warehouse CTF"
echo "=========================================="
echo "  noVNC:  http://localhost:6080/vnc.html"
echo ""
echo "  To launch the world (in a terminal):"
echo "    roslaunch aviation_warehouse aviation_warehouse.launch"
echo ""
echo "  To move the robot, publish to /cmd_vel directly:"
echo "    rostopic pub /cmd_vel geometry_msgs/Twist ..."
echo "=========================================="

tail -f /tmp/xfce.log /tmp/x11vnc.log /tmp/novnc.log /tmp/roscore.log
