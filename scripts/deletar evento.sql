-- begin tran
-- commit
-- rollback
declare @id_evento INT
        ,@codPeca INT 

        
delete from CI_MIDDLEWAY..mw_apresentacao_bilhete where id_apresentacao in (select id_apresentacao from CI_MIDDLEWAY..mw_apresentacao where id_evento=@id_evento)
delete from CI_MIDDLEWAY..mw_apresentacao where id_evento=@id_evento
delete from CI_MIDDLEWAY..mw_evento where id_evento=@id_evento
delete from tabPatrocinio where CodApresentacao in (select CodApresentacao from tabApresentacao where CodPeca=@codPeca)
delete from tabValBilhete where CodPeca=@codPeca
delete from tabApresentacao where CodPeca=@codPeca
delete from tabPeca where CodPeca=@codPeca
