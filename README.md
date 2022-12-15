
```
docker build -t sonic-pi .
docker container create --name sonic-pi -t sonic-pi
docker container cp sonic-pi:/opt/Sonic_Pi-x86_64.AppImage .
docker container rm sonic-pi
```

* Install jackd jack-tools supercollider pulseaudio-module-jack
* Add user to audio group, restart.

