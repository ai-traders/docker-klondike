# Docker Klondike

Forked from [athieriot/docker-klondike](https://github.com/athieriot/docker-klondike/commit/094517f0349ddec6317da7ce7bfcdf40ae52a4fd),
 but **this image does not run Klondike interactively**.

## Mono based

- ```2.1.1-mono-4.6.1.3``` - means Klondike 2.1.1 with mono 4.6.1.3

Docker container to run a Self Hosted version of [Klondike](https://github.com/themotleyfool/Klondike)

## Usage

### Getting Started

```
docker run -d -p 8080:8080 --name klondike aitraders/klondike
```

### Persist Package directory

```
docker run -d -p 8080:8080 -v /path/to/packages/:/app/App_Data/Packages --name klondike aitraders/klondike
```

### Override configuration

```
docker run -d \
  -p 8080:8080 \
  -v /path/to/Settings.config:/app/Settings.config \
  -v /path/to/Web.config:/app/Web.config \
  --name klondike \
  aitraders/klondike
```

## Development
1. In a feature branch:
   * you make changes
   * and run tests:
       * `./tasks build`
       * `./tasks itest`
1. You decide that your changes are ready and you:
   * merge into master branch
   * run locally:
     * `./tasks set_version` to set version in CHANGELOG and chart version files to
     the version from OVersion backend
     * e.g. `./tasks set_version 1.2.3` to set version in CHANGELOG and chart version
      files and in OVersion backend to 1.2.3
   * push to master onto private git server
1. CI server (GoCD) tests and releases.
