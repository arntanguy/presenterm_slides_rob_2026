Docker for wayland

```
mkdir workspace_tutorial
git clone https://github.com/arntanguy/presenterm_slides
```


For wayland:

```
docker run -it -e XDG_RUNTIME_DIR=/tmp  -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/tmp/$WAYLAND_DISPLAY -v $(pwd)/workspace_tutorial:/workspace nixos/nix
```

For X11:
```
xhost +
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v $(pwd)/workspace_tutorial:/workspace nixos/nix
```

Then in the docker:

```
# 2. activate the new CLI and flake features
echo 'experimental-features = nix-command flakes' | tee -a /etc/nix/nix.conf

# 3. (optional) if you trust us, add our binary caches to avoid recompiling everything
echo 'extra-substituters = https://gepetto.cachix.org https://attic.iid.ciirc.cvut.cz/ros https://mc-rtc-nix.cachix.org' | tee -a /etc/nix/nix.conf
echo 'extra-trusted-public-keys = gepetto.cachix.org-1:toswMl31VewC0jGkN6+gOelO2Yom0SOHzPwJMY2XiDY= ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q= mc-rtc-nix.cachix.org-1:5M3sLvHXJCep4wc1tQl7QuFWL2eH2I0jkuvWtqJDYQs=' | tee -a /etc/nix/nix.conf
```
