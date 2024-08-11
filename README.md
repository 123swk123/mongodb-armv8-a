# monogodb server for aarch64 (armv8) [cortex A53, cortex A55]

## For version 7.xx

### Build, release profile

Configure the build and generate Ninja files
```
buildscripts/scons.py\
 CC=aarch64-linux-gnu-gcc\
 CXX=aarch64-linux-gnu-g++\
 CCFLAGS='-march=armv8-a+crc -mtune=cortex-a53 --sysroot=/home_local/user/prjslocal/rootfs/fs/arm64/jammy'\
 LINKFLAGS='-march=armv8-a+crc -mtune=cortex-a53 --sysroot=/home_local/user/prjslocal/rootfs/fs/arm64/jammy'\
 NINJA_PREFIX=release\
 VARIANT_DIR=release\
 --linker=gold\
 --disable-warnings-as-errors\
 --release\
 --ninja=enabled\
 --link-model=static\
 --opt=on
```

Do the Ninja build
```
ninja -g release.ninja -j0 install-mongod
```

### Configuring mongod
- https://www.mongodb.com/docs/manual/administration/configuration/#std-label-base-config
- https://www.mongodb.com/docs/manual/reference/configuration-options/

#### Sample config
mongod.conf
```yaml
processManagement:
  fork: true
  pidFilePath: /var/run/mongod.pid
  timeZoneInfo: /usr/share/zoneinfo
net:
   bindIp: 0.0.0.0
   port: 27017
storage:
  dbPath: /home/data
  directoryPerDB: true
  wiredTiger:
    engineConfig:
        cacheSizeGB: 1
systemLog:
   destination: file
   path: "/var/log/mongodb/mongod.log"
   logAppend: true
```

## Mongodb community on aarch64 (ISA: armv8)
- [Build advice for arm64/aarch64?](https://www.mongodb.com/community/forums/t/build-advice-for-arm64-aarch64/16736)
- [Add MongoDB 4.2 ARM64 builds for Raspberry Pi OS 64 bit (Debian Buster)](https://www.mongodb.com/community/forums/t/add-mongodb-4-2-arm64-builds-for-raspberry-pi-os-64-bit-debian-buster/5046)
- [Core dump on MongoDB 5.0 on RPi 4](https://www.mongodb.com/community/forums/t/core-dump-on-mongodb-5-0-on-rpi-4/115291)
