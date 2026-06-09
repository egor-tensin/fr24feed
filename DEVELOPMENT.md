Images are built on GitHub Actions pipelines, but in case it for some reason
needs to be done manually, some notes are preserved here.

Dependencies
------------

* Docker with BuildKit support (18.09 or higher),

Multiarch
---------

Build & push multiarch images using

    make buildx/create
    make buildx/push
    make buildx/rm

A guide on how to set up multiarch builds can be found [here].
The goal was to have a single multiarch repo for each container in the
registry.
The approach is to use Docker's new BuildKit builder + the buildx command line
plugin.

Other possibilities are:
* use QEMU + multiarch base images directly ([1][1], [2][2]), and create a
manifest file manually,
* build natively on multiple architectures (not sure how to combine them in a
single manifest then though).

[here]: https://mirailabs.io/blog/multiarch-docker-with-buildx/
[1]: https://lobradov.github.io/Building-docker-multiarch-images/
[2]: https://ownyourbits.com/2018/06/27/running-and-building-arm-docker-containers-in-x86/
