#! /bin/bash

# Credit: Original version found here: https://github.com/jeffaco/dotfiles/blob/master/nix/bootstrap.sh

# Set up soft links from files to their destination (in home directory)

# Note: /bin/bash is required for ~/.* expansion in loop below

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own

# Only ever want to do this the first time
function copy_vim_files_to_root(){
	cp -r ./.vim/backups/ ~/.vim/backups
	cp -r ./.vim/colors ~/.vim/colors
	cp -r ./.vim/syntax/ ~/.vim/syntax
	cp -r ./.vim/swaps/ ~/.vim/swaps
	cp -r ./.vim/undo/ ~/.vim/undo
}



case $0 in
    /*|~*)
        SCRIPT_INDIRECT="`dirname $0`"
        ;;
    *)
        PWD="`pwd`"
        SCRIPT_INDIRECT="`dirname $PWD/$0`"
        ;;
esac

BASEDIR="`(cd \"$SCRIPT_INDIRECT\"; pwd -P)`"

# SCRIPT_INDIRECT becomes /Users/henock/projects/dotfiles/.

# Only deploy the files I have understood.
for i in "$SCRIPT_INDIRECT"{bash_profile,bashrc,bash_prompt,exports,aliases,functions,gitconfig,vimrc,gvimrc,curlrc,gitignore_global,inputrc}; do
    [ ! -f $i ] && continue
	FILEDIR=`dirname $i`
	FILE=`basename $i`
	BASEFILE=$HOME/$FILE

	if [ -f $BASEFILE -o -h $BASEFILE ]; then
		echo "Replacing file: $BASEFILE"
		rm $BASEFILE
	else
		echo "Creating link: $BASEFILE"
	fi

	ln -s $i $BASEFILE
done

if [ ! -e ~/.vim/swaps/ ]; then
    echo ".vim folder not set up yet find ~/.vim looks like so"
    find ~/.vim
	read -p "Do you want me to copy over .vim/<folders>  (backups|colors|swaps|syntax|undo) into ~ (y/n) " -n 1;
	echo "";
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		copy_vim_files_to_root;
	fi;
fi

# Make a pass deleting stale links, if any
echo "Deleting stale links"
for i in ~/.*; do
    [ ! -L $i ] && continue

    # We have a link: Is it stale? If so, delete it ...
    if [ ! -f $i ]; then
        echo "Deleting stale link: $i"
        rm $i
    fi
done