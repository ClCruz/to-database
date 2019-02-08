-- pr_login_client_check 'gabriel.c.craveiro+070299@gmail.com'

ALTER PROCEDURE dbo.pr_login_client_check(@email VARCHAR(1000))

AS

SELECT 1 exist
FROM CI_MIDDLEWAY..mw_cliente cli
WHERE lower(cli.cd_email_login)=lower(@email)