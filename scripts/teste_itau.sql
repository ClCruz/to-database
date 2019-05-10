exec sp_executesql N'SELECT DISTINCT mp.cd_meio_pagamento, mp.ds_meio_pagamento, mp.nm_cartao_exibicao_site 
                  FROM mw_meio_pagamento mp
                  INNER JOIN MW_MEIO_PAGAMENTO_FORMA_PAGAMENTO mpfp ON mp.id_meio_pagamento=mpfp.id_meio_pagamento
                  INNER JOIN mw_base b ON mpfp.id_base=b.id_base
                  INNER JOIN mw_evento e ON b.id_base=e.id_base
                  INNER JOIN mw_apresentacao ap ON e.id_evento=ap.id_evento
                  INNER JOIN mw_reserva r ON r.id_apresentacao=ap.id_apresentacao
                  WHERE mp.in_ativo = 1  AND IN_TRANSACAO_PDV <> 1 
                  AND r.id_session = @P1
                  AND id_gateway NOT IN (SELECT id_gateway FROM mw_gateway WHERE in_exibe_usuario = 1 AND id_gateway != @P2)
                  AND (qt_hr_anteced <= 172 or qt_hr_anteced is null) and ((
                                nm_cartao_exibicao_site like ''%pagseguro%''
                                and exists (select top 1 1 from mw_reserva r inner join mw_apresentacao a on a.id_apresentacao = r.ID_APRESENTACAO inner join mw_evento e on e.id_evento = a.id_evento where r.id_session = @P3 and e.id_base in (186,44))
                            ) or nm_cartao_exibicao_site not like ''%pagseguro%'')
                      AND mp.id_meio_pagamento not in (
                        select id_meio_pagamento
                        from mw_reserva r
                        INNER JOIN mw_apresentacao a ON a.id_apresentacao = r.ID_APRESENTACAO
                        INNER JOIN mw_evento e ON e.id_evento = a.id_evento
                        inner JOIN mw_base_meio_pagamento b ON b.id_base = e.id_base
                            AND convert(DATE, getdate()) BETWEEN b.dt_inicio AND b.dt_fim
                        where r.id_session = @P4
                      )
                      order by ds_meio_pagamento',N'@P1 varchar(8000),@P2 int,@P3 varchar(8000),@P4 varchar(8000)','l01cv1a084d557ll6mdlghdup7',6,'l01cv1a084d557ll6mdlghdup7','l01cv1a084d557ll6mdlghdup7'

select * from CI_MIDDLEWAY..mw_reserva

delete from CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento where id_meio_pagamento=65 and id_base=213
select * from CI_MIDDLEWAY..mw_base where ds_nome_base_sql like '%localhost%'
                    --   select * from CI_MIDDLEWAY..mw_meio_pagamento where cd_meio_pagamento in ('885',911)
                    -- update CI_MIDDLEWAY..mw_meio_pagamento set in_transacao_pdv=1,ds_meio_pagamento='Itau - Cartão de Crédito',id_gateway=6 where id_meio_pagamento=65
                    --   --update CI_MIDDLEWAY..mw_meio_pagamento set in_transacao_pdv=1,ds_meio_pagamento='PDV-Cartão de Crédito',id_gateway=4 where id_meio_pagamento=65