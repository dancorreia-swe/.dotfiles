# G.dotfiles

Welcome to the repository for my dotfiles! This repository contains configuration files for various programs and tools that I use on a daily basis. By using a tool like `stow`, you can easily symlink these configuration files to your home directory, allowing you to quickly set up your development environment on any system.

### Getting Started

To get started, follow these simple steps:

1. **Clone the Repository**: Clone this repository to your local machine.

    ```bash
    git clone https://github.com/danielcorreia-dev/.dotfiles.git
    ```

2. **Install `stow`**: Ensure that `stow` is installed on your system. If not, you can typically install it through your package manager.

    - **On Debian/Ubuntu**:

        ```bash
        sudo apt-get install stow
        ```

    - **On macOS** (using Homebrew):

        ```bash
        brew install stow
        ```

3. **Navigate to the Repository**: Move into the cloned repository directory.

    ```bash
    cd .dotfiles
    ```

4. **Use `stow` to Manage Configurations**: Use `stow` to symlink the desired configurations to your home directory.

    ```bash
    stow <directory_name>
    ```

    Replace `<directory_name>` with the name of the directory containing the configurations you want to use. For example, if you want to symlink the `vim` configurations:

    ```bash
    stow vim
    ```

    Or if you wanna stow all configurations from this repository just do:

    ```bash
    stow .
    ```

5. **Enjoy your Configurations**: That's it! Your configuration files should now be symlinked to your home directory, and you can start using your preferred settings for various programs.

### Contributing

If you have any improvements or suggestions for my dotfiles, feel free to open an issue or submit a pull request. I'm always open to new ideas and optimizations

### License

This repository is licensed under the [MIT License](LICENSE), so feel free to fork, modify, and distribute the code as you see fit.
