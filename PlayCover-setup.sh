#!/bin/zsh

# Directory for variable values and last execution time
CONFIG_DIR="$HOME/.config/playcover-update"
CACHE_FILE="$CONFIG_DIR/playcover_cache.txt"
TIME_FILE="$CONFIG_DIR/playcover_last_exec_time.txt"

# Initialize force flag
FORCE_UPDATE=0

# Function to retrieve variable values from cache or fetch new values based on last execution time
function get_variable_values {
  local last_exec_time=0
  local current_time=$(date +%s)

  if [ -f "$TIME_FILE" ]; then
    last_exec_time=$(<"$TIME_FILE")
  fi

  # Calculate time difference (24 hours = 86400 seconds)
  local time_diff=$((current_time - last_exec_time))
  local one_day_diff=86400

  if [[ $FORCE_UPDATE -eq 1 || $time_diff -ge $one_day_diff || ! -f "$CACHE_FILE" ]]; then
    fetch_variable_values
  else
    source "$CACHE_FILE"
  fi
}

# Function to fetch variable values
function fetch_variable_values {
  echo "Fetching variable values..."
  # Fetch values and store them in variables
  NIGHTLY_LINK=https://nightly.link/PlayCover/PlayCover/workflows/2.nightly_release/develop
  RESOLVED_LINK=$(curl -s -L -o /dev/null -w '%{url_effective}.zip' "$NIGHTLY_LINK")
  LATEST_NIGHTLY_BUILD_NUMBER=$(basename "$RESOLVED_LINK" | awk -F'_' '{print $NF}' | cut -d'.' -f1)
  INSTALLED_BUILD_NUMBER=$(defaults read /Applications/PlayCover.app/Contents/Info.plist CFBundleVersion)
  BUNDLE_NAME=$(defaults read /Applications/PlayCover.app/Contents/Info.plist CFBundleName)
  INSTALLED_VERSION=$(defaults read /Applications/PlayCover.app/Contents/Info.plist CFBundleShortVersionString)
  DOWNLOAD_DIR=$HOME/Downloads/
  FILENAME=$(basename "$RESOLVED_LINK")

  # Store values in cache file
  {
    echo "NIGHTLY_LINK=$NIGHTLY_LINK"
    echo "RESOLVED_LINK=$RESOLVED_LINK"
    echo "LATEST_NIGHTLY_BUILD_NUMBER=$LATEST_NIGHTLY_BUILD_NUMBER"
    echo "INSTALLED_BUILD_NUMBER=$INSTALLED_BUILD_NUMBER"
    echo "BUNDLE_NAME=$BUNDLE_NAME"
    echo "INSTALLED_VERSION=$INSTALLED_VERSION"
    echo "DOWNLOAD_DIR=$DOWNLOAD_DIR"
    echo "FILENAME=$FILENAME"
  } >"$CACHE_FILE"

  # Update last execution time if not forced
  if [ $FORCE_UPDATE -ne 1 ]; then
    echo "$(date +%s)" >"$TIME_FILE"
  fi
}

# Function to check and create the config directory if it doesn't exist
function create_config_dir {
  if [ ! -d "$CONFIG_DIR" ]; then
    mkdir -p "$CONFIG_DIR"
  fi
}

# Function to display error messages
function display_error {
  echo "Error: $1" >&2
}

# Get variable values and create config directory if needed
create_config_dir
get_variable_values

# Function to display installed app version details
function version_checker {
  echo
  echo "Installed PlayCover details:"
  echo "  App name: $BUNDLE_NAME"
  echo "  Version: $INSTALLED_VERSION (Installed)"
  echo "  Nightly build number: $INSTALLED_BUILD_NUMBER"
  echo "  Manually download the latest app: $RESOLVED_LINK"

  if [ "$INSTALLED_BUILD_NUMBER" -lt "$LATEST_NIGHTLY_BUILD_NUMBER" ]; then
    echo
    echo "Your installed build number is $INSTALLED_BUILD_NUMBER."
    echo "The latest available build number is $LATEST_NIGHTLY_BUILD_NUMBER."
  else
    echo
    echo "Your installed build ($INSTALLED_BUILD_NUMBER) is up-to-date."
    exit 0
  fi
}

# Function to download the latest PlayCover nightly zip file
function download {
  DOWNLOAD_DIR="$HOME/Downloads/"
  FILENAME="$(basename "$RESOLVED_LINK")"
  FILE_PATH="$DOWNLOAD_DIR$FILENAME"

  echo "Downloading the latest PlayCover zip..."

  if [ -n "$RESOLVED_LINK" ]; then
    if [ -f "$FILE_PATH" ]; then
      echo "File already exists. Skipping download."
    else
      echo "Downloading build $LATEST_NIGHTLY_BUILD_NUMBER of PlayCover nightly to $FILE_PATH"
      curl -o "$FILE_PATH" -L "$RESOLVED_LINK"
      echo "File downloaded successfully."
    fi
  else
    echo "Failed to resolve the direct download link. Please check the URL or try again later."
  fi
  install
}

# Function to install the downloaded ZIP file
function install {
  echo "Installing the downloaded file..."
  local ZIP_FILE="$FILE_PATH"

  if [ -f "$ZIP_FILE" ]; then
    unzip -o -q "$ZIP_FILE" -d "$DOWNLOAD_DIR"

    local DMG_FILE="$DOWNLOAD_DIR$(basename "$RESOLVED_LINK" .zip)"

    if [ -f "$DMG_FILE" ]; then
      echo "Mounting $DMG_FILE..."
      hdiutil attach -quiet -verify "$DMG_FILE"

      if [ -d "/Volumes/PlayCover/PlayCover.app" ]; then
        echo "Installing the app..."
        cp -R "/Volumes/PlayCover/PlayCover.app" "/Applications/"

        echo "Detaching $DMG_FILE..."
        hdiutil detach -quiet "/Volumes/PlayCover"
        echo "App updated successfully to $LATEST_NIGHTLY_BUILD_NUMBER build of PlayCover nightly!"

        # Prompt user to remove the downloaded DMG file after installation
        echo "Do you want to remove the downloaded file from the Downloads folder? (y/n): "
        read remove_dmg
        if [[ $remove_dmg == "y" || $remove_dmg == "Y" ]]; then
          rm "$DMG_FILE" # Remove the downloaded file after installation
          echo "Removed the file from Downloads folder.."
        else
          echo "The file was not removed..."
          echo "You can find it in $DMG_FILE"
        fi
      else
        echo "Error: PlayCover.app not found in the mounted disk image."
      fi
    else
      echo "Error: No .dmg file found in the downloaded archive."
    fi
  else
    echo "Error: Downloaded file not found. Please ensure the download was successful."
  fi
}

# Function to update the PlayCover app if necessary
function update {
  version_checker

  echo "Do you want to update the app? (y/n): "
  read -r update_app

  if [[ $update_app == "y" || $update_app == "Y" ]]; then
    download
    install
  else
    echo "Update canceled. Exiting."
  fi
  exit 0
}

# Function to display help information
function help_info {
  echo
  echo -e "DESCRIPTION:"
  echo "A script to download and update the PlayCover nightly app."
  echo
  echo "Links:"
  echo "  Github: https://github.com/TheFermi0n/playcover-nightly-setup"
  echo "  Manual download: https://nightly.link/PlayCover/PlayCover/workflows/2.nightly_release/develop"
  usage_info
}

# Function to display usage information
function usage_info {
  echo
  echo "Usage: playcover_setup {--force} [-u|--update] [-d|--download] [-v|--version] [-h|--help]"
  echo
  echo "Flag:"
  echo "      --force        Force the script to fetch the online data (overrides checks for version mismatch)"
  echo
  echo
  echo "Arguments:"
  echo "  -u, --update       Perform download and installation"
  echo "  -d, --download     Perform only download"
  echo "  -v, --version      Check version of installed PlayCover nightly application"
  echo "  -h, --help         Display this help message"
  echo
  echo "Example:"
  echo "  playcover_setup -u              # Perform download and installation"
  echo "  playcover_setup -d              # Perform only download"
  echo "  playcover_setup -v              # Check version of installed PlayCover"
  echo "  playcover_setup -h              # Display this help message"
  echo "  playcover_setup --force -u      # Force recheck online data and then Perform download and install"
  echo "  playcover_setup --force -v      # Force recheck online data and then Perform version check"
}

# Function to perform actions based on option
function perform_action {
  local option=$1

  case "$option" in
  -u | --update) update ;;
  -d | --download) download ;;
  -v | --version) version_checker ;;
  -h | --help)
    help_info
    exit 0
    ;;
  *)
    echo "Invalid option: $1. Read the help section below."
    usage_info
    exit 1
    ;;
  esac
}

# Check if no arguments/options are provided
if [ $# -eq 0 ]; then
  display_error "No options provided. Please specify an option. See usage below."
  usage_info
  exit 1
fi

# Process force option first and set the FORCE_UPDATE flag if present
for arg in "$@"; do
  if [[ "$arg" == "--force" ]]; then
    FORCE_UPDATE=1
    fetch_variable_values
    shift
    break
  fi
done

# If force is set, execute the corresponding action and reset FORCE_UPDATE flag
if [ $FORCE_UPDATE -eq 1 ]; then
  perform_action "$1"
  exit 0
fi

# Loop through remaining options and execute corresponding functions
while [[ "$#" -gt 0 ]]; do
  perform_action "$1"
  shift
done
