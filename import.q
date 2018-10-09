\c 25 400
\P 0

\l schema.q

orders:.schema.orders;

tmp:"tmp";

system "mkdir ",tmp," || true";
-1 "split json into ",tmp," folder (could be long)";
/ system "zcat full-log.json.gz | split -l 9000000 - tmp/log_";

unix_ts:"j"$1970.01.01D00:00:00;

convertSym:{@[x;i;:;`$x[i:where 10=type each x]]};
convertJ:{@[x;i;:;"j"$x[i:where -9=type each x]]};
convertTS:{@[x;`timestamp;:;"p"$unix_ts+1000000*x`timestamp]}

convertType:{convertTS@convertJ@convertSym x};

import:{[fn]
    s:read0 hsym `$tmp,"/",string fn;
    -1 "process ",(string fn),"    rows: ",string count s;
    fs:fs where `client_id in/: key each fs:.j.k each s;
    {`orders upsert convertType@@[(x t), 1_ x;`typ;:;t: first key x]} each fs;
  };

import each key `:tmp;
/ `:1.dat set orders;
/ orders:get `:1.dat;
-1 "collect gc";
.Q.gc[];
update date:`date$timestamp, time:`time$timestamp from `orders;

system "mkdir hist || true";

save_hdb:{
    res:update `p#client_id from `client_id`time xasc select from orders where date=x;
    res:delete date from res;
    (`$(string .Q.par[`:hist;x;`orders]),"/") set .Q.en[`:hist] res;
    -1 "hdb ",(string x)," saved";
  };

save_rdb:{
     res:update `g#client_id from `client_id`time xasc select from orders where date=x;
     res:delete date from res;
     `:rdb.dat set res;
    -1 "rdb ",(string x)," saved";
  };

save_hdb each -1_ asc exec distinct date from orders;
save_rdb last asc exec distinct date from orders;

\\

