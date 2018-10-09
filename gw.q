rdb:hopen 6000;
hdb:hopen 6010;
\p 5000

pending:([handle:0#0] fn:(); expect:0#0; res:());
/ table with:
/   handle:key with handle number
/   fn: function to aggerate results
/   res: returned results

callback:{[clHandle;result] 
  pending[clHandle;`res],:enlist result;
  pending[clHandle;`expect]-:1;
  -1 "recv for ",(string clHandle),"    ",(string count result)," rows";
  if[0=pending[clHandle;`expect];
    isError:0<sum pending[clHandle;`res][;0];
    result:pending[clHandle;`res][;1];
    if[isError; -30!(clHandle;isError;result[0])];
    r:pending[clHandle;`fn] result;
    -1 "reply for ",(string clHandle),"    ",(string count r)," rows";
    -30!(clHandle;isError;r); 
    delete from `pending where handle=clHandle;
  ]
  };

async_call:{[clHandle;query]
    neg[.z.w](`callback;clHandle;@[(0b;)value@;query;{(1b;x)}]);
  };

lastNOrders:{[clientIDs;dt;n]
    pending[.z.w;`fn]:{ungroup raze 0N!x};
    workers:$[not .z.d in dt; hdb; 1=count dt;rdb; hdb,rdb];
    pending[.z.w;`expect]:count workers;
    neg[workers]@\:(async_call;.z.w;(`lastNOrders;clientIDs;dt;n));
    -30!(::);
  };

/ .z.pg:{[query]
/     neg[hdb, rdb]@\:(async_call;.z.w;query);
/     -30!(::);
/   };

