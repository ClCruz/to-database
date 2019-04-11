begin tran
-- commit
-- rollback

delete from CI_MIDDLEWAY..mw_apresentacao_bilhete where id_apresentacao in (select id_apresentacao from CI_MIDDLEWAY..mw_apresentacao where id_evento=33009)
delete from CI_MIDDLEWAY..mw_apresentacao where id_evento=33009
delete from CI_MIDDLEWAY..mw_evento where id_evento=33009
delete from tabPatrocinio where CodApresentacao in (select CodApresentacao from tabApresentacao where CodPeca=31)
delete from tabValBilhete where CodPeca=31
delete from tabApresentacao where CodPeca=31
delete from tabPeca where CodPeca=31
