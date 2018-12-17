ALTER PROCEDURE dbo.pr_logout_admin_successfully(@login VARCHAR(1000))

AS

UPDATE CI_MIDDLEWAY..producer SET tokenValidUntil=DATEADD(DAY, -1, GETDATE()) WHERE lower(login)=lower(@login)