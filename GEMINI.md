# Project Overview

This is a personal blog built with [Hugo](https://gohugo.io/), a static site generator. The blog is themed with [hugo-theme-stack](https://github.com/CaiJimmy/hugo-theme-stack) and uses [Nix](https://nixos.org/) for dependency management. The blog's content is written in Markdown and can be found in the `content` directory.

# Building and Running

The project uses `just` as a command runner. The available commands are defined in the `justfile`.

*   **`just serve`**: This command starts the Hugo development server, which will watch for changes and automatically reload the site.
*   **`just run`**: This is an alias for `just serve`.

To build the site for production, you can run the following command:

```bash
hugo
```

This will generate the static site in the `public` directory.

# Development Conventions

The project uses Nix to manage its dependencies. The dependencies are defined in the `flake.nix` file. To activate the development environment, you can run the following command:

```bash
nix develop
```

This will install all the necessary dependencies, including Hugo, Dart Sass, and other tools.

The project uses `treefmt` and `alejandra` for code formatting. You can format the code by running the following command:

```bash
treefmt
```
