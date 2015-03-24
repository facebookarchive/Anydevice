# Overview

AnyDevice is an Internet of Things (IoT) sample application built on Parse. It
demonstrates the usage of Parse to enable communication between an Android or iOS device
and an IoT device. The IoT device could theoretically be any hardware which runs
an [Embedded SDK](https://www.parse.com/products/iot). Specifically, this
application communicates with the Texas Instruments
[SimpleLink Wi-Fi CC3200 LaunchPad](http://www.ti.com/tool/cc3200-launchxl).

## Getting Started

1. Clone this repository.

2. Download the Parse Embedded C SDK by initializing the git submodule in this repository. Run this command in this repository's top-level directory.

  ```
  git submodule update --init --recursive
  ```

2. Choose either [Android](android/Anydevice/) or [iOS](ios/) and follow the instructions from there.
