eval "$(goenv init -)"
set -x
echo $PATH
VERSION=$(goenv version | awk '{print $1}')
export PATH="${PATH}:/home/cmccabe/go/$VERSION/bin"
export PARH="$(/home/cmccabe/cmccabe-bin/path-fixer)"
set +x
