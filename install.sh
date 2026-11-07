#!/bin/sh

# System.......: hbRails
# Program......: public/install.sh
# Description..: Bootstrap the verified hbRails installer for native Linux x86_64 or AArch64
# Author.......: Sergio Lima
#
# This script is intentionally small and written for human review.
#
# Responsibilities:
#   1. Validate the supported platform and requested version.
#   2. Resolve the public release or local package source.
#   3. Download the Harbour installer and its checksum.
#   4. Verify the installer before execution.
#   5. Delegate the actual installation to the verified installer.
#
# Package validation, version management, rollback and activation belong to
# the Harbour installer, not to this bootstrap script.

set -eu

umask 077

RELEASES_BASE_URL="https://github.com/hbrails/hbrails-releases/releases/download"

MAX_DOWNLOAD_SIZE=67108864
DOWNLOAD_TIMEOUT=120

INSTALLER_NAME=""
CHECKSUM_NAME=""


# fail
#
# Terminates the script with an error message.
#
# Parameters:
#   $1 - Error message to write to standard error.
#
# Returns:
#   Does not return. Exits the script with status 1.
#
fail()
{
    echo "$1" >&2
    exit 1
}


# check_platform
#
# Verifies that the current operating system and architecture are supported
# by this public installer bootstrap.
#
# Parameters:
#   None.
#
# Returns:
#   0 if the native Linux target is recognized.
#   Terminates the script through fail() when unsupported.
#
check_platform()
{
    system_name=$(uname -s)
    machine_name=$(uname -m)

    [ "$system_name" = "Linux" ] || fail "hbRails requires Linux"
    case "$machine_name" in
        x86_64) target_name=linux-x86_64; elf_machine="62 0" ;;
        aarch64|arm64) target_name=linux-aarch64; elf_machine="183 0" ;;
        *) fail "Unsupported native hbRails architecture" ;;
    esac
    INSTALLER_NAME="hbrails-manager-${target_name}"
    CHECKSUM_NAME="${INSTALLER_NAME}.sha256"
}


# validate_version
#
# Validates that a version string contains only the characters accepted by
# the public hbRails release naming convention.
#
# Parameters:
#   $1 - Version string to validate.
#
# Returns:
#   0 when the version is valid.
#   Terminates the script through fail() when invalid.
#
validate_version()
{
    version_to_check="$1"

    case "$version_to_check" in
        ''|*[!0-9a-z.-]*|*..*)
            fail "Invalid version"
            ;;
    esac
}


# resolve_source
#
# Resolves where installation artifacts must be obtained from.
#
# By default, artifacts are downloaded from the official GitHub release.
# When "--local" is supplied, an absolute local directory is used instead.
#
# Parameters:
#   $1 - hbRails version to resolve.
#   $2 - Optional "--local" argument.
#   $3 - Optional absolute local package directory.
#
# Returns:
#   0 when the artifact source is successfully resolved.
#
# Side effects:
#   Sets the global variable "source_url".
#   Terminates the script through fail() when the arguments are invalid.
#
resolve_source()
{
    version_to_resolve="$1"
    shift

    source_url="${RELEASES_BASE_URL}/v${version_to_resolve}"

    if [ "$#" -eq 0 ]; then
        return 0
    fi

    if [ "$#" -ne 2 ] || [ "$1" != "--local" ]; then
        fail "Usage: install.sh [version [--local directory]]"
    fi

    case "$2" in
        /*)
            source_url="$2"
            ;;
        *)
            fail "Local mirror must be absolute"
            ;;
    esac
}

# download_asset
#
# Copies or downloads one installation artifact into a local destination.
#
# Parameters:
#   $1 - Artifact file name.
#   $2 - Destination path.
#
# Returns:
#   0 when the artifact is successfully obtained.
#   A non-zero status from cp or curl when the operation fails.
#
download_asset()
{
    asset_name="$1"
    destination="$2"

    case "$source_url" in
        /*)
            cp "${source_url}/${asset_name}" "$destination" ||
                fail "hbRails ${version} is unavailable for ${target_name}: missing local asset ${asset_name}"
            ;;
        *)
            # Retain the HTTP result on curl failure; 404 means unavailable, not a network error.
            if http_status=$(curl \
                -fsSL \
                --proto '=https' \
                --proto-redir '=https' \
                --max-time "$DOWNLOAD_TIMEOUT" \
                --max-filesize "$MAX_DOWNLOAD_SIZE" \
                --write-out '%{http_code}' \
                "${source_url}/${asset_name}" \
                -o "$destination"); then
                :
            else
                case "$http_status" in
                    404) fail "hbRails ${version} is unavailable for ${target_name}: missing asset ${asset_name}" ;;
                    *) fail "Download failed for hbRails ${version} (${target_name}), asset ${asset_name}; check network access and try again" ;;
                esac
            fi
            ;;
    esac
}


# verify_installer
#
# Verifies that the downloaded installer matches its published SHA-256
# checksum before execution.
#
# Parameters:
#   $1 - Path to the downloaded installer.
#   $2 - Path to the checksum file.
#
# Returns:
#   0 when the checksum matches.
#   Terminates the script through fail() when verification fails.
#
verify_installer()
{
    installer_path="$1"
    checksum_path="$2"

    actual_hash=$(sha256sum "$installer_path")
    actual_hash=${actual_hash%% *}

    expected_line="${actual_hash}  ${INSTALLER_NAME}"

    if [ "$(cat "$checksum_path")" != "$expected_line" ]; then
        fail "Installer checksum mismatch"
    fi
}


# cleanup
#
# Removes the temporary staging directory created during installation.
#
# Parameters:
#   None.
#
# Returns:
#   0 when the directory is successfully removed.
#
# Side effects:
#   Removes the directory referenced by "stage_directory".
#
cleanup()
{
    rm -rf "$stage_directory"
}


# handle_signal
#
# Converts supported termination signals into a controlled script failure.
# The EXIT trap performs the temporary-file cleanup afterwards.
#
# Parameters:
#   None.
#
# Returns:
#   Does not return. Exits the script with status 1.
#
handle_signal()
{
    exit 1
}


# main
#
# Coordinates the complete bootstrap installation flow.
#
# Parameters:
#   $1 - Optional hbRails version. Uses the packaged default when omitted.
#   $2 - Optional "--local" argument.
#   $3 - Optional absolute local package directory.
#
# Returns:
#   0 when the verified Harbour installer completes successfully.
#   A non-zero status when any validation, download or installation step fails.
#
main()
{
    # Keep this literal synchronized with package_public.py.
    # The public packager replaces it with the packaged release version.
    version=${1:-0.1.0-dev.8.14}

    check_platform
    validate_version "$version"

    # Remove the optional version argument before forwarding the remaining
    # source-selection arguments to resolve_source().
    if [ "$#" -gt 0 ]; then
        shift
    fi

    resolve_source "$version" "$@"

    stage_directory=$(mktemp -d)

    trap cleanup EXIT
    trap handle_signal HUP INT TERM

    installer_path="${stage_directory}/${INSTALLER_NAME}"
    checksum_path="${stage_directory}/${CHECKSUM_NAME}"

    download_asset "$INSTALLER_NAME" "$installer_path"
    download_asset "$CHECKSUM_NAME" "$checksum_path"

    verify_installer "$installer_path" "$checksum_path"

    # A valid checksum alone cannot authorize a foreign executable.
    elf_prefix=$(od -An -N7 -tx1 "$installer_path" | tr -d ' \n')
    [ "$elf_prefix" = "7f454c46020101" ] || fail "Invalid Manager ELF"
    set -- $(od -An -j18 -N2 -tu1 "$installer_path")
    [ "$*" = "$elf_machine" ] || fail "Manager architecture mismatch"

    chmod 700 "$installer_path"

    "$installer_path" --install "$version" "$source_url"
}

main "$@"
