# AGV

The `AGV` directory contains the simulation environment for the Boeing IT/OT CTF Capstone. It includes a fully containerized ROS Noetic + Gazebo aviation warehouse world with a TurtleBot3 Burger AGV, accessible via browser through noVNC.

## Directory Layout

```
AGV/
├── AGV_ROS/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── entrypoint.sh
│   ├── CMakeLists.txt
│   ├── package.xml
│   ├── launch/
│   │   └── aviation_warehouse.launch
│   └── worlds/
│       └── aviation_warehouse.world
└── archive/
    ├── ROSv1/
    └── entrypoint.sh
```

## AGV_ROS

### Dockerfile

Builds the container image from `osrf/ros:noetic-desktop-full`. Installs XFCE4, x11vnc, noVNC, and TurtleBot3 packages. Copies the ROS package into the catkin workspace, runs `catkin_make`, and exposes port 6080.

### docker-compose.yml

Defines the `workstation` service (container: `ros_ctf`). Maps port `6080:6080` for browser-based noVNC access. Sets environment variables for display, ROS master, and TurtleBot3 model.

### entrypoint.sh

Runs on container start. Initializes the virtual display (Xvfb), launches the XFCE4 desktop, starts x11vnc and noVNC, sources the ROS environment, and starts `roscore`.

### CMakeLists.txt

Catkin build configuration for the `aviation_warehouse` package. Installs the `worlds/` and `launch/` directories to the package share destination.

### package.xml

ROS package for `aviation_warehouse`. Declares runtime dependencies: `gazebo_ros`, `turtlebot3_description`, `robot_state_publisher`, and `xacro`.

## launch/

### aviation_warehouse.launch

Main simulation entry point. Loads the aviation warehouse world into Gazebo, spawns the TurtleBot3 Burger at the origin `(0, 0, 0.05)`.

## worlds/

### aviation_warehouse.world

SDF 1.6 world definition for a 25m × 18m enclosed warehouse.

## archive

Contains legacy files kept for reference. Not used in the current deployment.
