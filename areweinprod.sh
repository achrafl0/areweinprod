RED='\033[0;31m'
GREEN='\033[1;32m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'


should_validate="n"
quit="y"
cmd=""
MONITORED_COMMANDS=("pnpm db:migrate" "sns deploy" "pnpm ci:deploy")

function prompt(){
  echo "\e[41m\e[97mDANGER:\e[0m Are you sure you want to run this command ?"
  echo "\e[32m[ANY] = Continue \e[0m| \e[31m[Ctrl+c] = Cancel \e[0m"
  read -sk key
  quit="n"
}

function isSSHTunnelActive(){
  if lsof -i -n | grep -qi ssh; then
    # TODO : Add a skip to check if the SSH connexion is to a prod environnement
    echo "${YELLOW}WARNING : You currently have SSH connexions active , please check the opened connexions by running : \n${NC}"
    echo "\t lsof -i -n | grep ssh"
    should_validate="y"
  else
    echo "${GREEN}Ok ! No currently active SSH connexions found !${NC}"
  fi
}

function isCurrentEnvProd(){

  if [ -f ./.env ]; then

    if cat .env | grep -qi prod; then
      echo "${RED}DANGER: Your current .env is referencing the prod environment. ${NC}"
      should_validate="y"
    fi

    if cat .env | grep -qi dev; then
      echo "${YELLOW}Moderate Warning: Your current .env is referencing the dev environment ${NC}"
      should_validate="y"
    fi

  else
    echo "${GREEN}Ok ! No .env in CWD ${NC}"
  fi

}

function isMonitoredCommand(){
   for t in ${MONITORED_COMMANDS[@]}; do
      if [[ "$cmd" =~ .*"$t".* ]]; then
          isCurrentEnvProd;
          isSSHTunnelActive;
          if [ $should_validate != "n" ]; then
            prompt;
          fi
      fi
   done
}

pre_validation() {
  quit="y"
  should_validate="n"
  [[ $# -eq 0 ]] && return
  cmd=$1
  isMonitoredCommand;
}

post_validation() {
  [[ -z $cmd ]] && return # If there's no cmd, return. Else...
  if [[ "$quit" == "n" ]] && [["$should_validate" == "y"]]; then
    echo "${RED} You ran ${cmd} in what seems to be a prod environment. Double check your workflow and that there are no side effects"
  fi
  quit="y"
  should_validate="n"
}

autoload -U add-zsh-hook                  # Load the zsh hook module
add-zsh-hook preexec pre_validation       # Adds the pre hook
add-zsh-hook precmd post_validation        # Adds the pos hook
