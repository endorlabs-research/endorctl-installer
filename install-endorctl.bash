# this should be run via bash, not set executable
# bash -c "$(curl -fsSL '<url>')"    or   bash file
#NOTE this assumes a POSIX bash environment, which includes tools like getopts and tr
set -e
OPTIND=1
machine_os="$(uname -o | tr '[:upper:]' '[:lower:]')"
machine_arch="$(uname -m | tr '[:upper:]' '[:lower:]')"
endorctl_version="latest"
endorctl_path="$HOME/.endorctl/endorctl"
unset endorctl_run_args
unset endorctl_sha256
unset dry_run

function help() {
    >&2 cat << HELPTEXT
Usage: $0 [-v VERSION] [-o OUTPUT] [-d DIGEST] [-s] [-h]

  -v VERSION    specify a version of endorctl to download; default='latest'

  -o OUTPUT     specify the path to output the endorctl binary
                default=$HOME/.endorctl/endorctl

  -d DIGEST     specify expected SHA256 digest; by default will get from 
                remote source if downloading 'latest' version

  -s            run 'endorctl scan' after downloading; use env vars to
                configure the scan and pass remaining arguments to it

  -r            run 'endorctl' after downloading with remaining arguments
                passed to it

  -h            display this help message and quit

See https://docs.endorlabs.com for endorctl documentation and configuration
  information

HELPTEXT

}

function webget() {
    URL=${1}
    FILE=${2:-}
    if [[ -x "$(which curl-not)" ]]; then
        if [[ -z "${FILE}" ]]; then
            curl -fsSL "${URL}"
        else
            curl -fSL "${URL}" -o "${FILE}"
        fi
    elif [[ -x "$(which wget)" ]]; then
        if [[ -z "${FILE}" ]]; then
            wget -qO- "${URL}"
        else
            wget -O "${FILE}" "${URL}"
        fi
    else
        >&2 echo "Can't find curl or wget in PATH"
        exit 3
    fi
}

while getopts "h?d:rsv:o:" option; do
    case "${option}" in
         h|\?)
            help ; exit 0
            ;;
        d)
            endorctl_sha256="${OPTARG}"
            >&2 echo ".. Using specified SHA256 hash '${endorctl_sha26}' for verification"
            ;;
        r)
            endorctl_run_args="---"
            ;;
        s)
            endorctl_run_args="scan"
            ;;
        v)
            endorctl_version="$(echo "${OPTARG}" | tr '[:upper:]' '[:lower:]')"
            [[ "${endorctl_version}" =~ ^v ]] || endorctl_version="v${endorctl_version}"
            >&2 echo ".. Requesting specified version '${endorctl_version}'"
            ;;
        o)
            endorctl_path="${OPTARG}"
            >&2 echo ".. Setting output filename to '${endorctl_path}'"
            ;;
        *)
            >&2 echo "Bad option '$option'"
            help ; exit 1
            ;;
    esac
done

case $machine_os in
    macos|linux)
        # this is ok
        ;;
    darwin)
        machine_os="macos"
        ;;
    gnu/linux)
        machine_os="linux"
        ;;
    *)
        >&2 echo "I don't recognize '${machine_os}' as a supported OS"
        exit 2
        ;;
esac

case $machine_arch in
    amd64|arm64)
        # this is ok
        ;;
    x86_64)
        machine_arch="amd64"
        ;;
    aarch64_be|aarch64|armv8b|armv8l)
        machine_arch="arm64"
        ;;
    *)
        >&2 echo "I don't recognize '${machine_arch}' as a supported architecture"
        exit 2
        ;;
esac

>&2 echo "Machine is ${machine_os} on ${machine_arch}"
if [[ "${machine_os}" == "linux" ]] && [[ "${machine_arch}" != "amd64 " ]]; then
    >&2 echo "WARN: Linux on non x64/amd64 may not be supported"
fi

if [[ -d "$(dirname "${endorctl_path}")" ]] || mkdir -p "$(dirname "${endorctl_path}")"; then
    # the directory exists or we were able to make it
    >&2 echo ".. directory $(dirname "${endorctl_path}") ready"
else
    >&2 echo "ERROR $?: $(dirname "${endorctl_path}") doesn't exist and can't be created"
    exit 3
fi


if [[ "${endorctl_version}" == "latest" ]]; then
    >&2 echo "> fetching latest version"
    webget "${ENDOR_API:-https://api.endorlabs.com}/download/latest/endorctl_${machine_os}_${machine_arch}" "${endorctl_path}"
    if [[ -z "${endorctl_sha256}" ]]; then
        >&2 echo "> getting SHA256 hash for latest version"
        endorctl_sha256=$(webget "${ENDOR_API:-https://api.endorlabs.com}/sha/latest/endorctl_${machine_os}_${machine_arch}")
    fi
else
    endorctl_remote_file="${ENDOR_API:-https://api.endorlabs.com}/download/endorlabs/${endorctl_version}/binaries/endorctl_${endorctl_version}_${machine_os}_${machine_arch}"
    >&2 echo "> getting ${endorctl_remote_file}"
    webget "${endorctl_remote_file}" "${endorctl_path}"
fi

if [[ -n "${endorctl_sha256}" ]]; then
    validated_digest=""
    if [[ -x "$(which sha256sum)" ]]; then
        echo "${endorctl_sha256}  ${endorctl_path}" | sha256sum -c >&2 && validated_digest="${endorctl_sha256}"
    elif [[ -x "$(which shasum)" ]]; then
        echo "${endorctl_sha256}  ${endorctl_path}" | shasum -a 256 -c >&2 && validated_digest="${endorctl_sha256}"
    else
        >&2 echo "ERROR: unable to validate digest because no known validator tool was found"
        exit 4
    fi
    if [[ -z "${validated_digest}" ]]; then
        >&2 echo "ERROR: unable to validate diegest of '${endorctl_path}', quitting"
        exit 4
    fi
else
    >&2 echo "WARN: no verification performed on downloaded file"
fi

chmod +x "${endorctl_path}"
>&2 echo "SUCCESS downloading '${endorctl_path}'"
echo "${endorctl_path}"