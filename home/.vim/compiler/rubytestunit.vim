if !empty(glob('.zeus.sock'))
  CompilerSet makeprg=zeus\ test\ $*
elseif filereadable("Gemfile")
  CompilerSet makeprg=bundle\ exec\ ruby\ -Itest\ -Ilib\ $*
else
  CompilerSet makeprg=ruby\ -Itest\ -Ilib\ $*
endif

CompilerSet errorformat=\%W\ %\\+%\\d%\\+)\ Failure:,
                        \%C%m\ [%f:%l]:,
                        \%E\ %\\+%\\d%\\+)\ Error:,
                        \%C%m:,
                        \%C\ \ \ \ %f:%l:%.%#,
                        \%C%m,
                        \%Z\ %#,
                        \%-G%.%#
