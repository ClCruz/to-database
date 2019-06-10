delete from santosrockfestival..tabPatrocinio where CodApresentacao=0
delete from santosrockfestival..tabLugSala where CodApresentacao=0
delete from santosrockfestival..tabLancamento where CodApresentacao=0
delete from santosrockfestival..tabapresentacao where codapresentacao=0
delete from CI_MIDDLEWAY..mw_apresentacao_bilhete where id_apresentacao=179442
delete from CI_MIDDLEWAY..mw_apresentacao where id_apresentacao=179442
select * from CI_MIDDLEWAY..mw_apresentacao where id_evento=33211
select * from CI_MIDDLEWAY..mw_evento where ds_evento like '%santos rock festival%'
select * from CI_MIDDLEWAY..mw_base where id_base=278