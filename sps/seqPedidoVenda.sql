CREATE PROCEDURE dbo.seqPedidoVenda (@user VARCHAR(100) = NULL)

AS

INSERT INTO pedidoVenda ([user]) VALUES (@user)

SELECT SCOPE_IDENTITY() id