h:hopen 5000;

q:"h(`lastNOrders;964486 2233991 2233991;2018.07.06,.z.d;2)"
-1 "rdb+hdb request: ",q;
full:value q;
full

q:"h(`lastNOrders;964486 2233991 2233991;2018.07.06;2)"
-1 "hdb request: ",q;
hdb:value q;
hdb

q:"h(`lastNOrders;964486 2233991 2233991;.z.d;2)"
-1 "rdb request: ",q;
rdb:value q;
rdb

