# endorctl-installer

Installer helpers to make deployment of endorctl *even easier*

## Linux and MacOS, with bash

Prerequisites -- you'll need:

* `curl` or `wget` installed and in your `PATH`
* `bash` in a POSIX environment (so tools like `tr` are available)

```bash
curl -s 'https://raw.githubusercontent.com/endorlabs-research/endorctl-installer/refs/heads/main/install-endorctl.bash' | bash -s --
```

**OR** if you prefer wget

```bash
wget -qO- 'https://raw.githubusercontent.com/endorlabs-research/endorctl-installer/refs/heads/main/install-endorctl.bash' | bash -s --
```

Then run endorctl with:

```bash
$HOME/.endorctl/endorctl [OPTIONS]
```

* You can replace `main` in the URLs above with a tag if you want to pin a version of the script.
* you can add script arguments after the final `--` which let you specify versions, your own hashes, download path ,etc.
* use `-o path/to/endorctl` to download to somewhere other than `$HOME/.endorctl/endorctl`; the final component of the path will be treated as a filename
* the STDOUT of this script will be the location of the installed binary, if successful; that lets you do things like
  
  ```bash
  export ENDORCTL_BIN=$(curl -s 'https://raw.githubusercontent.com/endorlabs-research/endorctl-installer/refs/heads/main/install-endorctl.bash' | bash -s --)
  "${ENDORCTL_BIN}" scan --path="${PWD}"
  ```

**NOTE:** as with all "curl-piping", it's wise to inspect the script to ensure that it's safe for your environment before using it in this way.

### Example GitHub CI snippet

*see also:* [Endor Labs GitHub Action](https://github.com/marketplace/actions/endor-labs-scan) as a supported alternative to the installer script

```yaml
jobs:
  run:
    runs-on: ubuntu-22.04
    permissions:
      id-token: write
    steps:
      - name: install Endor Labs
        shell: bash
        run: |
          set -e
          curl -s 'https://raw.githubusercontent.com/endorlabs-research/endorctl-installer/refs/heads/main/install-endorctl.bash' | bash -s -- -o ${{ github.workspace }}/.endorctl/endorctl

      ## put checkout and build steps here

      - name: run Endor Labs scan
        shell: bash
        env:
          ENDOR_NAMESPACE: my-namespace
          ENDOR_GITHUB_ACTION_TOKEN_ENABLE: true
        run: endorctl scan --secrets --dependencies --enable-remediation-action --disable-private-package-analysis
```

**Example output** of installation step:

```text
Machine is linux on amd64
.. directory /home/runner/work/example-repo ready
> fetching latest version
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  160M  100  160M    0     0  40.1M      0  0:00:04  0:00:04 --:--:-- 40.1M
> getting SHA256 hash for latest version
/home/runner/work/example-repo/.endorctl/endorctl: OK
SUCCESS downloading '/home/runner/work/example-repo/.endorctl/endorctl'
/home/runner/work/example-repo/.endorctl/endorctl
Detected running in GitHub environment
adding '/home/runner/work/example-repo/.endorctl' to end of PATH
```

### Example for Jenkins

```groovy
pipeline {
    // Select an agent class that is a Linux or macOS environment with bash available
    agent any

    // Endorctl scan uses following environment variables to the trigger endorctl scan
    environment {
        ENDOR_API = credentials('ENDOR_API')
        ENDOR_NAMESPACE = credentials('ENDOR_NAMESPACE')
        ENDOR_API_CREDENTIALS_KEY = credentials('ENDOR_API_CREDENTIALS_KEY')
        ENDOR_API_CREDENTIALS_SECRET = credentials('ENDOR_API_CREDENTIALS_SECRET')
    }
    stages {
        // We're using a Java example
        // Not required if repository is allready cloned to trigger a endorctl scan
        stage('Checkout') {
            steps {
                // Checkout the Git repository
                checkout scmGit(branches: [[name: '*/main']], userRemoteConfigs: [[url: 'https://github.com/endorlabstest/app-java-demo.git']])
            }
        }

        stage('Build') {
            // Not required if project is already built\
            // For this example, we're assuming the agent already has the Java build stack, including Maven, installed
            steps {
                // Perform any build steps if required
                sh 'mvn clean install'
            }
        }

        stage('endorctl Scan') {
            steps {
                // Download and install endorctl.
                sh '''#!/bin/bash
                    echo "Downloading latest version of endorctl"
                    curl -s 'https://raw.githubusercontent.com/endorlabs-research/endorctl-installer/refs/heads/main/install-endorctl.bash' | bash -s -- -o ./endorctl
                    // Check endorctl version and installation.
                    ./endorctl --version
                    // Run the scan.
                    ./endorctl scan -a $ENDOR_API -n $ENDOR_NAMESPACE --api-key $ENDOR_API_CREDENTIALS_KEY --api-secret $ENDOR_API_CREDENTIALS_SECRET
                '''
            }
        }
    }
}
```

## Windows

Not yet supported: see [the Endor Labs official documenation](https://docs.endorlabs.com/endorctl/install-and-configure/#download-and-install-the-endorctl-binary-directly) for installation instructions
