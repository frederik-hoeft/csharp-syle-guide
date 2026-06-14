# Installation

Run the install script from your solution directory (or pass an explicit path to your `.sln` / `.slnx` file).
The script downloads `.editorconfig`, `Directory.Build.props`, and `code-style.md` next to the solution file, overwriting any existing copies.

## Requirements

`wget` or `curl`, and `bash` 4+.

## One-liner

Run these commands from your **solution root** (the directory that contains the `.sln` / `.slnx` file).
The script will auto-detect the solution in the current working directory.

**wget**
```bash
wget -qO- https://raw.githubusercontent.com/frederik-hoeft/csharp-syle-guide/refs/heads/main/install.sh | bash
```

**curl**
```bash
curl -fsSL https://raw.githubusercontent.com/frederik-hoeft/csharp-syle-guide/refs/heads/main/install.sh | bash
```

## Local usage

```bash
# clone / download install.sh, then:
chmod +x install.sh
./install.sh                        # auto-detect .sln/.slnx in $PWD
./install.sh path/to/dir            # auto-detect in that directory
./install.sh path/to/MyApp.sln      # explicit solution file
```
