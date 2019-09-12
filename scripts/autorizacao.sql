select * from CI_MIDDLEWAY..to_admin_authorization

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'ev-viewer', 'event viewer', 'event viewer'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'ev-add', 'event add/update', 'event add/update'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'room-viewer', 'room viewer', 'room viewer'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'room-add', 'room add/update', 'room add/update'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'room-viewer', 'room viewer', 'room viewer'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'room-add', 'room add/update', 'room add/update'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'user-viewer', 'user viewer', 'user viewer'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'user-add', 'user add/update', 'user add/update'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'user-add-auth', 'user add/update auth', 'user add/update auth'




INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'producer-viewer', 'producer viewer', 'producer viewer'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'producer-add', 'producer add/update', 'producer add/update'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'genre-viewer', 'genre viewer', 'genre viewer'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'genre-add', 'genre add/update', 'genre add/update'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'place-viewer', 'Local - Visualização', 'Visualização de local'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'place-add', 'Local - Inclusão/Alteração', 'Inclusão e alteração de local'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'place-link', 'Local - Vincular', 'Vincular o local'



INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'presentation-viewer', 'Data da apresentação do evento - Visualização', 'Visualização da data da apresentação de um evento'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'presentation-add', 'Data da apresentação do evento - Inclusão/Alteração', 'Inclusão e alteração da data de apresentação de um evento'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'partner-viewer', 'Parceiros - Visualização', 'Visualização do parceiro'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'partner-add', 'Parceiros - Inclusão/Alteração', 'Inclusão e alteração do parceiro'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'partner-wl', 'Parceiros - Criação whitelabel', 'Criação do whitelabel'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'partner-regen', 'Parceiros - Recriar APIKEY', 'Recriar APIKEY'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'developer', 'Permissão apenas para equipe de desenvolvimento', 'Permissão apenas para equipe de desenvolvimento'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'ticketoffice-login', 'Bilheteria - Permissão de utilização', 'Permissão para utilizar a bilheteria'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'to-cashregister-close', 'Bilheteria - Fechar caixa', 'Permissão para fechar caixa'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'to-cashregister-closeother', 'Bilheteria - Fechar caixa - Outro', 'Permissão para fechar caixa de outro operador'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'partner-staticpage', 'Parceiros - Páginas Estáticas', 'Permissão para alterar o conteudo das paginas estaticas'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'ad-viewer', 'Propaganda - Visualização', 'Permissão para visualição das propagandas'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description])
SELECT 'ad-add', 'Propaganda - Inclusão/Alteração', 'Inclusão e alteração de propagandas'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'tickettype-viewer', 'Bilhete - Visualização', 'Permissão para visualição dos tipos de bilhetes','Bilhete'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'tickettype-add', 'Bilhete - Inclusão/Alteração', 'Inclusão e alteração dos tipos de bilhetes','Bilhete'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'report-viewer', 'Menu relatórios', 'Menu relatórios','Relatório'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'report-accounting', 'Borderô', 'Borderô','Relatório'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'report-partnersale', 'Venda para parceiro', 'Venda para parceiro','Relatório'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'report-quotasale', 'Venda para cota', 'Venda para cota','Relatório'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'user-add-partner', 'Permissões Parceiros - Inclusão/Alteração', 'Inclusão e alteração de permissão em parceiros'



INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'quotapartner-viewer', 'Parceiro de cota - Visualização', 'Permissão para visualição dos parceiros de cota','Cota'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'quotapartner-add', 'Parceiro de cota - Inclusão/Alteração', 'Inclusão e alteração dos parceiros de cota','Cota'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'dashboard-home-viewer', 'Dashboard Home - Visualização', 'Permissão para visualição do dashboard da home','Dashboard'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'dashboard-adm-viewer', 'Dashboard Admin - Visualização', 'Permissão para visualição do dashboard de admin','Dashboard'



INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'ad-emailtemplate-add', 'Template de e-mail para marketing - Inclusão/Alteração', 'Criação de template de e-mail para marketing','Propaganda'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'ev-externaluri', 'Adicionar e visualizar URL externa', 'Permissão para visualizar e alterar a URL externa','Evento'




INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'typeofpt-viewer', 'Tipo do Tipo de Pagamento - Visualização', 'Permissão para visualição dos tipos do pagamento','Tipo de Pagamento'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'typeofpt-add', 'Tipo do Tipo de Pagamento - Inclusão/Alteração', 'Inclusão e alteração dos tipos de pagamentos','Tipo de Pagamento'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'city-viewer', 'Cidade - Visualização', 'Permissão para visualição da cidade','Local'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'city-add', 'Cidade - Inclusão/Alteração', 'Inclusão e alteração da cidades','Local'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'paymenttype-viewer', 'Tipo de Pagamento - Visualização', 'Permissão para visualição dos tipos do pagamento','Tipo de Pagamento'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'paymenttype-add', 'Tipo de Pagamento - Inclusão/Alteração', 'Inclusão e alteração dos tipos de pagamentos','Tipo de Pagamento'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'accountingdebittype-viewer', 'Tipo de Débito - Borderô - Visualização', 'Permissão para visualição dos tipos de debito de borderô','Borderô'
INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'accountingdebittype-add', 'Tipo de Débito - Borderô - Inclusão/Alteração', 'Inclusão e alteração dos tipos de debito de borderô','Borderô'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'ev-accountingdebittype-add', 'Evento - Tipo de débito no bordero - Inclusão/Exclusão', 'Inclusão e exclusão dos tipos de debito de borderô no evento','Evento'

select * from CI_MIDDLEWAY..to_admin_authorization
order by [group], [name]

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'report-binpromotion', 'Venda para promoção BIN', 'Venda para promoção BIN','Relatório'


INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'partner-paymenttype', 'Tipo de pagamento para o parceiro - Inclusão/Alteração', 'Inclusão e alteração do tipo de pagamento no parceiro','Parceiro'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'report-binpromotion-reduced', 'Venda para promoção BIN - Resumida', 'Venda para promoção BIN - Resumida','Relatório'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'shoppingfail-viewer', 'Compras com falhas', 'Compras com falhas','Buscas'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'search-viewer', 'Acesso ao menu de buscas', 'Acesso ao menu de buscas','Buscas'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'webpurchase-viewer', 'Lista de compras web', 'Acesso a lista de compras efetuadas na web','Buscas'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'webpurchase-gateway', 'Lista de compras web - URI Gateway', 'Acesso a URL do gateway com relação a compra','Buscas'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'webpurchase-detail', 'Lista de compras web - Detalhes', 'Acesso ao detalhes da compra','Buscas'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'webpurchase-print', 'Compra Web - Detalhe - Imprimir', 'Acesso a imprimir o ticket da compra','Buscas'

INSERT INTO CI_MIDDLEWAY..to_admin_authorization (code, [name], [description],[group])
SELECT 'webpurchase-refund', 'Lista de compras web - Estorno', 'Acesso para realizar o estorno da compra','Buscas'


select * from CI_MIDDLEWAY..to_admin_authorization where [group]='Relatório'