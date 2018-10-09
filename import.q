\c 25 400
\P 0

\l schema.q

orders:.schema.orders;

tmp:"tmp"

system "mkdir tmp || true"
system "zcat full_log.json.gz | split -l 9000000 - tmp/log_"

s_cols:exec c from (meta .schema.orders) where t="s", not c=`typ;
j_cols:exec c from (meta .schema.orders) where t="j";
unix_ts:"j"$1970.01.01D00:00:00;

ct1:{@[x;i;:;`$x[i:where 10=type each x]]};
ct2:{@[x;i;:;"j"$x[i:where -9=type each x]]};
/ ct3:{@[x;`date`time;:;(`date$p;`time$p:"p"$unix_ts+1000000*x`timestamp)]}
ct3:{@[x;`timestamp;:;"p"$unix_ts+1000000*x`timestamp]}

import:{[fn]
    s:read0 hsym `$tmp,"/",string fn;
    -1 string fn;
    -1 string count s;
    fs:fs where `client_id in/: key each fs:.j.k each s;
    {`orders upsert ct3@ct2@ct1@@[(x t), 1_ x;`typ;:;t: first key x]} each fs;
  };

/ import each key `:tmp;
/ `:1.dat set orders;
orders:get `:1.dat;
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


