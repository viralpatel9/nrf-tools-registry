# NRF Tools Registry

A Docker container providing Nordic Semiconductor tools for programming and debugging MCUs.

---

## 🚀 Getting Started

Clone the repository:
```sh
git clone https://github.com/viralpatel9/nrf-tools-registry
```

---

## 📝 Overview

- The [`setup.sh`](./setup.sh) script automatically installs Nordic tools based on your OS.
- The Docker image supports multiple architectures (x86_64, arm64).

---

## 🛠️ Building the Docker Image Locally

Build for your current architecture:
```sh
docker build -t viralpatel9/nrf-tools-registry:v1.0.0 .
```

Build for a specific architecture:
- **amd64 (x86_64):**
  ```sh
  docker buildx build --platform linux/amd64 -t viralpatel9/nrf-tools-registry:v1.0.0 --load .
  ```
- **arm64 (aarch64):**
  ```sh
  docker buildx build --platform linux/arm64 -t viralpatel9/nrf-tools-registry:v1.0.0 --load .
  ```

---

## 🤖 CI/CD Builds

- Build images for `x86_64` and `aarch64` using GitHub Actions.
- Create a branch from `develop` and push your changes.
- Open a PR to `develop` and squash commits (merge commit if tag was pushed).
- For releases: Open a PR to `main` or `master` to trigger a release in the `packages` tab.
- To create a tag:
  ```sh
  # On your feature branch (or develop)
  git tag -a v1.0.0 -m "Initial Release"
  git push origin v1.0.0
  ```

### Use the image on the github actions:
```sh
jobs:
  build:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/viralpatel9/nrf-tools-registry:v1.0.0

    steps:
      - uses: actions/checkout@v4

      - name: Read versions
        run: |
          west build -b nrf52840dk_nrf52840
```

---

## 🏃 Running the Docker Image Locally

Run interactively:
```sh
docker run --rm -it viralpatel9/nrf-tools-registry:v1.0.0
```

For USB access (flashing/programming):
```sh
docker run --rm -it \
  --device /dev/bus/usb \
  ghcr.io/viralpatel9/nrf-tools-registry:v1.0.0
```

---

## 🏗️ Running ARM64 Images on x86 Machines

To run an ARM64 (aarch64) Docker image on an x86 machine, you need QEMU emulation and Docker’s buildx.

### ✅ Step-by-Step: Build & Run ARM64 Image on x86

1️⃣ **Enable multi-arch emulation (one-time setup):**
```sh
docker run --privileged --rm tonistiigi/binfmt --install all
```
This installs QEMU handlers so your system can run ARM containers.

2️⃣ **Create a buildx builder (if not already present):**
```sh
docker buildx create --use --name multiarch
docker buildx inspect --bootstrap
```

3️⃣ **Run the ARM64 image on your x86 machine:**
```sh
docker run --rm -it \
  --platform linux/arm64 \
  ghcr.io/viralpatel9/nrf-tools-registry:v1.0.0
```
You’ll now be inside an ARM64 container, emulated.

🧠 **Verify architecture inside the container:**
```sh
uname -m
```
Expected output:
```sh
aarch64
```

---

## 🔑 Important Docker Flags

- `--platform linux/arm64` → Build/run ARM image
- `--load` → Load image into local Docker for running
- `--device /dev/bus/usb` → USB access for programming

---