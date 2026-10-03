FROM osrf/ros:noetic-desktop-full

ENV DEBIAN_FRONTEND=noninteractive

# --- Base tools + desktop + noVNC stack ---
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal dbus-x11 x11-xserver-utils \
    xvfb x11vnc novnc websockify \
    net-tools iputils-ping iproute2 dnsutils curl wget \
    && rm -rf /var/lib/apt/lists/*

# --- TurtleBot3 sim ---
RUN apt-get update && apt-get install -y \
    ros-noetic-turtlebot3 \
    ros-noetic-turtlebot3-simulations \
    ros-noetic-teleop-twist-keyboard \
    && rm -rf /var/lib/apt/lists/*

# --- Aviation warehouse world (self-contained) ---
RUN mkdir -p /root/catkin_ws/src/aviation_warehouse/worlds \
             /root/catkin_ws/src/aviation_warehouse/launch \
             /root/catkin_ws/src/aviation_warehouse/models/shelving_unit/meshes

COPY worlds/aviation_warehouse.world \
     /root/catkin_ws/src/aviation_warehouse/worlds/aviation_warehouse.world
COPY launch/aviation_warehouse.launch \
     /root/catkin_ws/src/aviation_warehouse/launch/aviation_warehouse.launch
COPY package.xml \
     /root/catkin_ws/src/aviation_warehouse/package.xml
COPY CMakeLists.txt \
     /root/catkin_ws/src/aviation_warehouse/CMakeLists.txt

WORKDIR /root/catkin_ws
RUN /bin/bash -lc "source /opt/ros/noetic/setup.bash && catkin_make"

# Avoid Gazebo audio issues
ENV SDL_AUDIODRIVER=dummy
ENV TURTLEBOT3_MODEL=burger

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6080
ENTRYPOINT ["/entrypoint.sh"]
