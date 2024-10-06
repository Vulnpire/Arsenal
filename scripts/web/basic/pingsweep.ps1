for /L %i in (1 1 254) do ping 172.16.5.%i -n 1 -w 100 | find "Reply"
1..254 | % {"172.16.5.$($_): $(Test-Connection -count 1 -comp 172.15.5.$($_) -quiet)"}