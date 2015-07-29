function addpath_iris

conf.root = pwd;
addpath(fullfile(conf.root));
pod_pkg_config('mosek');

end


function success=pod_pkg_config(podname)
  success=false;
  cmd = ['addpath_',podname];
  if exist(cmd,'file')
    disp([' Calling ',cmd]);
    try 
      eval(cmd);
      success=true;
    catch ex
      disp(getReport(ex,'extended'))
    end
  end
    
  if ~success && nargout<1
    error(['Cannot find required pod ',podname]);
  end
end