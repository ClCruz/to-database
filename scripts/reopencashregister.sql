-- SELECT * FROM CI_MIDDLEWAY..ticketoffice_cashregister
-- select * from CI_MIDDLEWAY..ticketoffice_cashregister_moviment where codVenda='U64EBOCBAO'
-- select * from CI_MIDDLEWAY..ticketoffice_cashregister_moviment order by created
-- --update CI_MIDDLEWAY..ticketoffice_cashregister_moviment set codForPagto=53 where codVenda='U6TBECCBBO'--'U64EBOCBAO'

UPDATE d
SET d.closed = GETDATE()
        ,d.isopen=1
        ,d.id_ticketoffice_user_closed=NULL
        ,d.justification_closed = NULL
FROM CI_MIDDLEWAY..ticketoffice_cashregister d
WHERE d.id='c59f097e-cc57-4e62-a9c7-c555c7ecb44a'


UPDATE d
SET d.id_ticketoffice_cashregister=NULL
    ,d.isopen=1
FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment d
WHERE d.id_ticketoffice_user='f2177e5e-f727-4906-948d-4eea9b9bbd0e'
    AND d.isopen=0
    AND d.id_base=213

DELETE FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment WHERE [type]='diff' AND id_ticketoffice_user='f2177e5e-f727-4906-948d-4eea9b9bbd0e'

-- select * from CI_MIDDLEWAY..ticketoffice_cashregister_moviment order by created
-- delete from CI_MIDDLEWAY..ticketoffice_cashregister_moviment where [type]='diff'
-- delete from CI_MIDDLEWAY..ticketoffice_cashregister
-- select * from CI_MIDDLEWAY..ticketoffice_cashregister
-- update CI_MIDDLEWAY..ticketoffice_cashregister_moviment set codForPagto=53, id_ticketoffice_cashregister_closed='50b51717-dd26-44ea-8cac-6fe3ab9456d5', isopen=0 where codVenda='S64AFGCOGO'
-- update CI_MIDDLEWAY..ticketoffice_cashregister_moviment set codForPagto=53, id_ticketoffice_cashregister=null, isopen=1 where isopen=0
-- update CI_MIDDLEWAY..ticketoffice_cashregister set closed=null, isopen=1, id_ticketoffice_user_closed=null, justification_closed=null where id='357a7ed7-0451-4976-88a8-98b0caa47f4b'
-- select * from ci_localhost..tabForPagamento


-- select * from CI_MIDDLEWAY..ticketoffice_cashregister_moviment where [type]='diff'