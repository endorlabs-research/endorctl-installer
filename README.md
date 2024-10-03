# endorctl-installer

Installer helpers to make deployment of endorctl *even easier*

## Linux and MacOS, with bash

Prerequisites -- you'll need:

* `curl` or `wget` installed and in your `PATH`
* `bash` in a POSIX environment (so tools like `tr` are available)

```bash
curl -s 'https://github.com/endorlabs-research/endorctl-installer/releases/latest/download/install-endorctl.bash' | bash -s --
# OR
wget -qO- 'https://github.com/endorlabs-research/endorctl-installer/releases/latest/download/install-endorctl.bash' | bash -s --
```

## Windows

Not yet supported: see [the Endor Labs official documenation](https://docs.endorlabs.com/endorctl/install-and-configure/#download-and-install-the-endorctl-binary-directly) for installation instructions
