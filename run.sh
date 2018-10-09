#!/bin/sh

q hdb.q &
q rdb.q &
q gw.q &

wait

