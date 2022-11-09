# Are we in prod ?

## Requirements

`zsh` as the default shell

## Installation and usage
- Git clone the repository
- You can configure the list of "risky" commands to be monitored in the source code inside the array `MONITORED_COMMANDS`
- `source ./areweinprod.sh`
- You can also add this command into your `~/.zshrc` to launch it automatically at terminal launch

## Why ?
Sometimes we can be a little airheaded and forget unclosed ssh tunnels to prod instances or maybe we don't check the current environment


I'll add more checks as times goes by !


If you have issues or propositions you can open an issue or send me a message !

