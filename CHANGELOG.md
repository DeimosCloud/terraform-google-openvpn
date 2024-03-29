# Changelog

All notable changes to this project will be documented in this file.

## [2.4.0](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v2.3.0...v2.4.0) (2022-11-09)


### Features

* adding shared-vpc support ([#20](https://github.com/DeimosCloud/terraform-google-openvpn/issues/20)) ([f685ece](https://github.com/DeimosCloud/terraform-google-openvpn/commit/f685ecea568834e7ecaa590c45a63bd592b7638d))

## [2.3.0](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v2.2.1...v2.3.0) (2022-04-06)


### Features

*  add openvpn firewall rule to allow 1194([#18](https://github.com/DeimosCloud/terraform-google-openvpn/issues/18)) ([2923d5f](https://github.com/DeimosCloud/terraform-google-openvpn/commit/2923d5f8ba065bf2123b2822c657444d9cbdca7b))

### [2.2.1](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v2.2.0...v2.2.1) (2022-04-04)


### Bug Fixes

* correct export command in installation script [#17](https://github.com/DeimosCloud/terraform-google-openvpn/issues/17) ([fcbb027](https://github.com/DeimosCloud/terraform-google-openvpn/commit/fcbb0271c3ba1144f3822c9a6c3ae259b9e6848a))

## [2.2.0](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v2.1.1...v2.2.0) (2022-04-04)


### Features

* Add custom DNS Server configuration ([#16](https://github.com/DeimosCloud/terraform-google-openvpn/issues/16)) ([8dbb452](https://github.com/DeimosCloud/terraform-google-openvpn/commit/8dbb452975eb88e64cee00542b1dc1b9d51e54ae))

### [2.1.1](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v2.1.0...v2.1.1) (2022-03-24)


### Bug Fixes

* metadata usage ([#14](https://github.com/DeimosCloud/terraform-google-openvpn/issues/14)) ([a7e1e24](https://github.com/DeimosCloud/terraform-google-openvpn/commit/a7e1e24330a0320cae0e11c8ed160d88d6a714a6))

## [2.1.0](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v2.0.0...v2.1.0) (2022-03-03)


### Features

* use name var instead of prefix ([#12](https://github.com/DeimosCloud/terraform-google-openvpn/issues/12)) ([7753497](https://github.com/DeimosCloud/terraform-google-openvpn/commit/7753497bf22a3b71535e9cac6f38eb6dfa7c23a6))

## [2.0.0](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v1.3.0...v2.0.0) (2022-02-22)


### ⚠ BREAKING CHANGES

* removes instance template module to allow working with lifecycles

### Features

* added persistent disk ([3974529](https://github.com/DeimosCloud/terraform-google-openvpn/commit/3974529c3baed6959fb7ff7b1b0ff79a1effd737))

## [1.3.0](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v1.2.4...v1.3.0) (2022-02-18)


### Features

* Pin version for installation to allow updates ([#8](https://github.com/DeimosCloud/terraform-google-openvpn/issues/8)) ([41bba64](https://github.com/DeimosCloud/terraform-google-openvpn/commit/41bba64edc77a1af80e6ed412ea521d268aec713))

### [1.2.4](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v1.2.3...v1.2.4) (2022-02-05)


### Bug Fixes

* if statement syntax issue ([#7](https://github.com/DeimosCloud/terraform-google-openvpn/issues/7)) ([f2baeb5](https://github.com/DeimosCloud/terraform-google-openvpn/commit/f2baeb5413f1a964ae69a55f7215106f0abe8c6a))

### [1.0.1](https://github.com/DeimosCloud/terraform-google-openvpn/compare/v1.0.0...v1.0.1) (2022-02-04)


### Bug Fixes

* Adding the changes to resolve the revoking of users issue ([#6](https://github.com/DeimosCloud/terraform-google-openvpn/issues/6)) ([92e34d2](https://github.com/DeimosCloud/terraform-google-openvpn/commit/92e34d2c5d3e0094508227abe2ddf8e5e01e7e65))
* clean up unused function ([7657fd5](https://github.com/DeimosCloud/terraform-google-openvpn/commit/7657fd51639b2d83ce4a43f253fd9a0e94f44caf))
