function nvm-activate
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
  string match --entire --regex (_nvm_version_match $v) <$nvm_data/.index | read v __

  #do nothing if version is not changed
  test "$v" = "$nvm_current_version" && return

  #install if necessary
  _nvm_list | string match --entire --regex (_nvm_version_match $v) | read v_installed __
  if test -n "$v_installed"
    nvm use $v_installed >/dev/null
  else
    nvm install $v >/dev/null
  end

  #print nvm message
  status is-interactive && ! set --query auto_nvm_quiet && printf "Now using Node %s (npm %s) %s\n" (_nvm_node_info)
end

if status is-interactive
  function nvm-autoload --on-event fish_prompt
    function nvm-autoload --on-variable PWD
      nvm-activate
    end && nvm-autoload
  end
else
  function nvm-autoload --on-variable PWD
    nvm-activate
  end && nvm-autoload
end
