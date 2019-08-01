eval "$(goenv init -)"
VERSION=$(goenv version | awk '{print $1}')
export PATH="${PATH}:/home/cmccabe/go/$VERSION/bin"
export PATH="$(/home/cmccabe/cmccabe-bin/path-fixer)"
echo -n "** setting PATH="
echo $PATH | sed 's/:/\n/g'
