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
           ('E2C CIA ENTRETENIMENTO ESPORTES TECNOLOGIA NEGÓCIOS LTDA'
           ,'28427697000109'
           ,'E2C CIA ENTRETENIMENTO ESPORTES TECNOLOGIA NEGÓCIOS LTDA'
           ,'leonel.costa@ticketoffice.com.br'
           ,'11'
           ,'111111'
           ,'11'
           ,'11111'
           ,'001'
           ,'3554'
           ,'8'
           ,'24161'
           ,'0'
           ,'CC'
           ,@id_produtor
           ,1
		   ,'re_cjqh35gsd04w46460f9nx9mz4'
           ,1
           ,'monthly'
           ,0)

	SELECT @@IDENTITY AS id

	SET NOCOUNT OFF
