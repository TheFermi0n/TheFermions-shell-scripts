# PlayCover Nightly Setup

This script allows for the seamless download and update of the PlayCover nightly app. It fetches the latest build from from [nightly.link](https://nightly.link/PlayCover/PlayCover/workflows/2.nightly_release/develop) and provides options to update, download, and check the version of the installed PlayCover nightly application.

## Installation and Usage

### Option 1: Run as Executable

1. Clone this repository:

   ```shell
   git clone https://github.com/TheFermi0n/playcover-nightly-setup.git
   ```

2. Move to the directory:

   ```shell
   cd playcover-nightly-setup
   ```

3. Make the script executable:

   ```shell
   chmod +x Playcover-setup.sh
   ```

4. Run the script directly;

   ```shell
   ./Playcover-setup.sh {--force} [-u|--update] [-d|--download] [-v|--version] [-h|--help]
   ```

### Option 2: Add Alias for Easy Execution

1. Clone this repository:

   ```shell
   git clone https://github.com/TheFermi0n/playcover-nightly-setup.git
   ```

2. Add an alias to your shell's configuration file (`~/.bashrc`, `~/.zshrc`, etc.):

   ```shell
   alias playcover_setup='zsh /path/to/Playcover-setup.sh'
   ```

   Replace `/path/to/Playcover-setup.sh` with the actual path to the script.

3. Source the configuration file or restart your terminal:

   ```shell
   source ~/.bashrc  # For Bash
   source ~/.zshrc   # For Zsh
   ```

4. Run the script using the created alias:

   ```shell
   playcover_setup {--force} [-u|--update] [-d|--download] [-v|--version] [-h|--help]
   ```

## Flags and Arguments

- `--force`: Force the script to fetch online data, overriding version checks.
- `-u`, `--update`: Perform download and installation.
- `-d`, `--download`: Perform only the download.
- `-v`, `--version`: Check the version of the installed PlayCover nightly application.
- `-h`, `--help`: Display the help message.

## Examples

- `./Playcover-setup.sh -u`: Perform download and installation.
- `playcover_setup -u`: Perform download and installation using the alias.
- `./Playcover-setup.sh -d`: Perform only the download.
- `playcover_setup -v`: Check the version of installed PlayCover.
- `./Playcover-setup.sh -h`: Display the help message.
- `playcover_setup --force -u`: Force recheck online data and then perform download and install.

## Links

- [PlayCover Repository](https://github.com/PlayCover/PlayCover) - Official PlayCover Repository
- [Github Repository](https://github.com/TheFermi0n/playcover-nightly-setup)
- Manually download the nightly build from [nightly.link](https://nightly.link/PlayCover/PlayCover/workflows/2.nightly_release/develop)

## Contributing

Feel free to contribute by creating issues or pull requests.

## License

This project is licensed under the GNU GPLv3 License - see the [LICENSE](LICENSE) file for details.
