
#' 查询RPAtask
#'
#' @param token

#' @return 无返回值
#' @export
#'
#' @examples
#' RPAtask_select()
RPAtask_select<- function(erp_token) {

  sql=paste0("
select ROW_NUMBER()over(order by fbillno,FCoaAttachment )as 序号,FBILLNO AS 单据编号,
FCoaAttachment AS 待上传附件
from rds_vw_coa_attachmentsUpload_task")

  res=tsda::sql_select2(token = erp_token,sql = sql)
  return(res)
}
