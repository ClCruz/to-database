ALTER PROCEDURE [dbo].[pr_recipient_e2c]
	@id_produtor INT
AS
	SET NOCOUNT ON

	INSERT INTO [dbo].[mw_recebedor]
           ([ds_razao_social]
           ,[cd_cpf_cnpj]
           ,[ds_nome]
           ,[cd_email]
           ,[ds_ddd_telefone]
           ,[ds_telefone]
           ,[ds_ddd_celular]
           ,[ds_celular]
           ,[cd_banco]
           ,[cd_agencia]
           ,[dv_agencia]
           ,[cd_conta_bancaria]
           ,[dv_conta_bancaria]
           ,[cd_tipo_conta]
           ,[id_produtor]
           ,[in_ativo]
		   ,[recipient_id]
           ,transfer_day
           ,transfer_interval
           ,transfer_enabled)
     VALUES
           ('BILHETERIA.COM'
           ,'07.741.441/0001-93'
           ,'BILHETERIA.COM'
           ,'clcruz@clcruz.com.br'
           ,'11'
           ,'111111'
           ,'11'
           ,'11111'
           ,'237'
           ,'2062'
           ,'0'
           ,'19778'
           ,'5'
           ,'CC'
           ,@id_produtor
           ,1
		   ,'re_ck7534cfe2zn8ur60coq35zh1'
           ,1
           ,'monthly'
           ,0)

	SELECT @@IDENTITY AS id

	SET NOCOUNT OFF
