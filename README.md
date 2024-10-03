# endorctl-installer

Installer helpers to make deployment of endorctl *even easier*

## Linux and MacOS, with bash

Prerequisites -- you'll need:

* `curl` or `wget` installed and in your `PATH`
* `bash` in a POSIX environment (so tools like `tr` are available)

```bash
curl -s 'https://raw.githubusercontent.com/endorlabs-research/endorctl-installer/refs/heads/main/install-endorctl.bash' | bash -s --
# OR
wget -qO- 'https://raw.githubusercontent.com/endorlabs-research/endorctl-installer/refs/heads/main/install-endorctl.bash' | bash -s --
```

* You can replace `main` in the URLs above with a tag if you want to pin a version of the script.
* you can add script arguments after the final `--` which let you specify versions, your own hashes, download path ,etc.
* use `-o path/to/endorctl` to download to somewhere other than `$HOME/.endorctl/endorctl`; the final component of the path will be treated as a filename
* the STDOUT of this script will be the location of the installed binary, if successful

**NOTE:** as with all "curl-piping", it's wise to inspect the script to ensure that it's safe for your environment before using it in this way.

### Example CI snippet

```yaml
jobs:
  run:
    runs-on: ubuntu-22.04
    steps:
      - name: install and run Endor Labs scan
        shell: bash
        env:
          ENDOR_NAMESPACE: my-namespace
          ...
        run: |
          set -e
          curl -s 'https://raw.githubusercontent.com/endorlabs-research/endorctl-installer/refs/heads/main/install-endorctl.bash' | bash -s -- -o ./endorctl
          ./endorctl scan --secrets --dependencies --enable-remediation-action --disable-private-package-analysis
```

**Example output:**

```text
.. Setting output filename to './endorctl'
Machine is linux on amd64
.. directory . ready
> fetching latest version
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  171M  100  171M    0     0  36.0M      0  0:00:04  0:00:04 --:--:-- 40.3M
> getting SHA256 hash for latest version
./endorctl: OK
SUCCESS downloading './endorctl'
./endorctl
```

## Windows

Not yet supported: see [the Endor Labs official documenation](https://docs.endorlabs.com/endorctl/install-and-configure/#download-and-install-the-endorctl-binary-directly) for installation instructions
