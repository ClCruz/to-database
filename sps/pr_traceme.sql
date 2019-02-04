ALTER PROCEDURE dbo.pr_traceme (@id_purchase VARCHAR(100),@uri VARCHAR(1000),@file VARCHAR(1000)
                              ,@request VARCHAR(MAX),@post VARCHAR(MAX),@agent VARCHAR(1000)
                              ,@ip VARCHAR(1000),@ip2 VARCHAR(1000),@host VARCHAR(1000)
                              ,@HTTP_ORIGIN VARCHAR(1000) = NULL,@HTTP_REFERER VARCHAR(1000) = NULL
                              ,@title VARCHAR(8000), @values VARCHAR(MAX),@isforeign BIT)

AS

INSERT INTO CI_MIDDLEWAY.[dbo].[purchase_trace]
           ([id_purchase],[uri],[file]
           ,[request],[post],[agent]
           ,[ip],[ip2],[host]
           ,[http_origin],[http_referer]
           ,[title],[values],[isforeign])
SELECT @id_purchase, @uri, @file
        , @request, @post, @agent
        , @ip, @ip2, @host
        , @HTTP_ORIGIN, @HTTP_REFERER
        , @title, @values, @isforeign
