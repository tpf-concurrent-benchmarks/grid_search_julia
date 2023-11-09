module Remotes
using Distributed

@everywhere begin

export do_work

function do_work(args)
	f, x = args
	sleep(2)
	return f(x)
end

end

end