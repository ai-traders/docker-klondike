# Docker Klondike

## Mono based

- ```2.1.1-mono-4.6.1.3```

Docker container to run a Self Hosted version of [Klondike](https://github.com/themotleyfool/Klondike)

Forked from [athieriot/docker-klondike](https://github.com/athieriot/docker-klondike/commit/094517f0349ddec6317da7ce7bfcdf40ae52a4fd),
 but this variant runs Klondike not interactively.

# Usage

## Getting Started

```
docker run -it -d -p 8080:8080 --name klondike xmik/klondike
```

## Persist Package directory

```
docker run -it -d -p 8080:8080 -v /path/to/packages/:/app/App_Data/Package --name klondike xmik/klondike
```

## Override configuration            

```
docker run -it -d \
  -p 8080:8080 \
  -v /path/to/Settings.config:/app/Settings.config \
  -v /path/to/Web.config:/app/Web.config \
  --name klondike \
  xmik/klondike
```

# Development

### Build
1. Add any changes and increment version in `image/variables.sh`
 (no automated version management).
2. Build the docker image:
```
./build.sh
```

### Test
Run:
```
./test.sh
```
