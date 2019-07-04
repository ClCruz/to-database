select ap.id_apresentacao, e.ds_evento, ap.ds_piso, ap.id_evento, ap.dt_apresentacao from CI_MIDDLEWAY..mw_apresentacao ap
inner join CI_MIDDLEWAY..mw_evento e on ap.id_evento=e.id_evento
where e.id_base=213 and ap.in_ativo=1 and ap.dt_apresentacao>=getdate() and ap.id_evento not in (32975)
order by ap.dt_apresentacao desc