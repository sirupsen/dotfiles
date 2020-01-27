. ~/.bashrc

if [ -e /Users/$(whoami)/.nix-profile/etc/profile.d/nix.sh ]; then .  /Users/$(whoami)/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
if [[ $USER == "simoneskildsen" ]]; then
  source /opt/dev/dev.sh
fi
