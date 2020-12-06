function auto-nvm --on-variable PWD
  set --local v
  set --local v_fallback lts

  #load nvm and it's utility functions
  type nvm >/dev/null || nvm --help >/dev/null

  #read version from nvm files
  for file in .nvmrc .node-version
    set file (_nvm_find_up $PWD $file) && read v <$file && break
  end

  #if there's no nvm files, use default version
  test -n "$v" || set v $nvm_default_version

  #if there's no default version, use fallback version
  test -n "$v" || set v $v_fallback

  #resolve v to specific version
  string match --entire --regex (_nvm_version_match $v) <$nvm_data/.index | read v alias

  #switch version if necessary
  test "$v" = "$nvm_current_version" || nvm install $v >/dev/null

  #print nvm message
  set --query auto_nvm_quiet || printf "Now using Node %s (npm %s) %s\n" (_nvm_node_info)
end
