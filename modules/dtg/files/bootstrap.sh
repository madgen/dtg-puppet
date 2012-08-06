#!/bin/sh

# Abort if something goes wrong
set -e

# Install puppet
echo "Installing puppet-common and git-core"
apt-get -y install puppet-common git-core

# From mfpl-puppet/modules/mayfirst/files/freepuppet/frepuppet-init
# prep a server to be free of a puppet master
# re-run this command to clear out your local git
# repo (allowing you to re-push after git commit --amend)

echo "Setting up git repositories"
# remove /etc/puppet as installed by puppet
rm -rf /etc/puppet

mkdir /etc/puppet
cd /etc/puppet
git init --shared=group

# create bare repo that admins will push to
admin_bare_repo="/etc/puppet-bare"
[ -d "$admin_bare_repo" ] && rm -rf "$admin_bare_repo"
mkdir "$admin_bare_repo"
cd "$admin_bare_repo"
git init --bare --shared=group

# create post-update hook to pull in changes to the real puppet repo
target="$admin_bare_repo/hooks/post-update"
printf "echo ---- Pulling changes into /etc/puppet -----\n\n" > "$target"
printf "cd /etc/puppet\n" >> "$target"
printf "unset GIT_DIR\n" >> "$target"
printf "git pull --recurse-submodules=yes bare  master\n" >> "$target"
printf "git submodule update\n\n" >> "$target"
printf "echo ---- Applying new recipes ----\n\n" >> "$target"
printf "puppet apply --verbose --modulepath modules manifests/site.pp" >> "$target"

chmod 775 hooks/post-update

# add  as a remote to real puppet repo
cd /etc/puppet
git remote add bare "$admin_bare_repo"

# Pull the current contents of the repository
git pull --recurse-submodules=yes git://github.com/ucam-cl-dtg/dtg-puppet.git
git submodule init
git submodule update

# Pull in the current contents
git push --set-upstream bare master
