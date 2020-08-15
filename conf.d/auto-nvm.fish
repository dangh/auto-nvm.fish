function auto-nvm --on-variable PWD
  set --local nvm_file .nvmrc
  set --local node_version lts

  #load nvm and it's utility functions
  test -n "$nvm_config"; or nvm --help >/dev/null

  #read current version
  test -s "$nvm_config/version"; and read --local last_version < "$nvm_config/version"

  #use version from .nvmrc file
  #if .nvmrc does not exist, use the last version
  if set --local root (_nvm_find_up (pwd) $nvm_file)
    read node_version < "$root/$nvm_file"
  else if test -n "$last_version"
    set node_version "$last_version"
  end
  set --local node_version (_nvm_resolve_version $node_version)
  set --local node_dir "$nvm_config/$node_version/bin"

  #install coresponding node version
  #but do not change switch system-wide version
  if not test -d "$node_dir"
    nvm use $node_version >/dev/null
    test -n "$last_version"; and echo $last_version > "$nvm_config/version"
  end

  #shadow over nvm's path
  set --erase --global fish_user_paths
  set --global --export fish_user_paths $fish_user_paths
  for path in $fish_user_paths
    switch $path
      case "$nvm_config/*/bin"
        set --local i (contains --index "$path" $fish_user_paths)
        set --erase --global fish_user_paths[$i]
    end
  end
  set --export fish_user_paths "$node_dir" $fish_user_paths
end

function patch-nvm --description 'patch nvm to use global scope'
  #load nvm and it's utility functions
  test -n "$nvm_config"; or nvm --help >/dev/null

  #patch nvm use
  set --local to_replace 'set -U fish_user_paths "$nvm_config/$ver/bin" $fish_user_paths'
  string replace "$to_replace" "set -eg fish_user_paths; $to_replace; auto-nvm" (functions _nvm_use) | source
end

patch-nvm
