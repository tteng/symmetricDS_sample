#! /bin/bash

cat insert_sample.sql.source > $@

while read table; do

  if [[ ! -z "$table" ]]; then

    SQL_CHANNEL="

    ---customize channel table ${table}
      insert into sym_channel
      (channel_id, processing_order, max_batch_size, enabled, description)
      values('${table}', 1, 100000, 1, '${table} data');
    "

    echo -e "$SQL_CHANNEL" >> $@

    SQL_TRIGGER_ROUTER="

    --customize sym trigger router table ${table}
      insert into sym_trigger_router
      (trigger_id,router_id,initial_load_order,last_update_time,create_time)
      values('${table}','corp_2_store', 100, current_timestamp, current_timestamp);
    "

    echo -e "$SQL_TRIGGER_ROUTER" >> $@

    SQL_SYM_TRIGGER="

    --customize sym trigger table ${table}
      insert into sym_trigger
      (trigger_id,source_table_name,channel_id,last_update_time,create_time)
      values('${table}','${table}','${table}',current_timestamp,current_timestamp);
    "

    echo -e "$SQL_SYM_TRIGGER" >> $@
  
  fi

done <tables.properties
