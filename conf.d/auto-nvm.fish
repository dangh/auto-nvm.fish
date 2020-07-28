function auto-nvm --on-variable PWD
  set --local nvm_file .nvmrc
  set --local node_version lts
  set --local last_version

  #install nvm if required
  if not type --quiet nvm
    fisher add jorgebucaran/fish-nvm
  end

  #load nvm and it's utility functions
  if test -z "$nvm_config"
    nvm --help >/dev/null
  end

  #load last version


  #use version from .nvmrc file
  #if .nvmrc does not exist, use the last version
  if set --local root (_nvm_find_up (pwd) $nvm_file)
    read node_version < "$root/$nvm_file"
  else if test -s "$nvm_config/version"
    read --local node_version < "$nvm_config/version"
  end
  set --local node_version (_nvm_resolve_version $node_version)
  set --local node_dir "$nvm_config/$node_version/bin"

  #install coresponding node version
  if not test -d "$node_dir"
    nvm use $node_version >/dev/null
  end

  #shadow over nvm's path
  set --global --export fish_user_paths $fish_user_paths
  set --local current_version (string sub --start 2 (node --version))
  if test "$fish_user_paths[1]" = "$nvm_config/$current_version/bin"
    set --export fish_user_paths[1] "$node_dir"
  else
    set --export fish_user_paths "$node_dir" $fish_user_paths
  end
end
