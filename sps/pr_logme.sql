ALTER PROCEDURE dbo.pr_logme (@uri VARCHAR(1000)
                              ,@file VARCHAR(1000)
                              ,@request VARCHAR(MAX)
                              ,@post VARCHAR(MAX)
                              ,@started bigint
                              ,@ended bigint
                              ,@seconds int
                              ,@isMobile BIT = 0
                              ,@isAndroid BIT = 0
                              ,@isIOS BIT = 0
                              ,@agent VARCHAR(1000)
                              ,@ip VARCHAR(1000)
                              ,@ip2 VARCHAR(1000)
                              ,@host VARCHAR(1000)
                              ,@HTTP_ORIGIN VARCHAR(1000) = NULL

                              ,@HTTP_REFERER VARCHAR(1000) = NULL) 16

AS

INSERT INTO CI_MIDDLEWAY..logrequest (uri, [file], request, post, [started],ended,seconds,isMobile,isAndroid,isIOS, agent, ip, ip2, host, http_origin, http_referer)
SELECT @uri, @file, @request, @post, @started, @ended,@seconds,@isMobile,@isAndroid,@isIOS,@agent,@ip,@ip2,@host, @HTTP_ORIGIN, @HTTP_REFERER