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

# --- Realistic factory floor world (AWS Small Warehouse) ---
RUN apt-get update && apt-get install -y \
    git \
    python3-catkin-tools \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/catkin_ws/src
WORKDIR /root/catkin_ws/src
RUN git clone https://github.com/aws-robotics/aws-robomaker-small-warehouse-world.git
WORKDIR /root/catkin_ws
RUN /bin/bash -lc "source /opt/ros/noetic/setup.bash && catkin_make"

# Avoid Gazebo trying to use audio
ENV SDL_AUDIODRIVER=dummy

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 6080
ENTRYPOINT ["/entrypoint.sh"]

