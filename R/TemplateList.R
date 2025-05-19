
#' 查询模板清单
#'
#' @param token

#' @return 无返回值
#' @export
#'
#' @examples
#' TemplateList_select()
TemplateList_select<- function(erp_token) {

  sql=paste0("
select FTemplateNumber as 模板编号,FTemplateName as 模板名称,FMaxEntrySeq as COA表体最大行数
from rds_t_TemplateList")

  res=tsda::sql_select2(token = erp_token,sql = sql)
  return(res)
}


#' 清空模板清单
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' TemplateList_truncate()
TemplateList_truncate<- function(erp_token) {

  sql=paste0("
TRUNCATE TABLE rds_t_TemplateList_input ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}


#' 删除模板清单为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' TemplateList_inputdelete()
TemplateList_inputdelete<- function(erp_token) {

  sql=paste0("


 delete from  rds_t_TemplateList_input where FTemplateNumber='' or FTemplateNumber is null
             ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}

#' 覆盖前删除
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' TemplateList_delete()
TemplateList_delete<- function(erp_token) {

  sql=paste0("


 delete from  rds_t_TemplateList where  FTemplateNumber in (select FTemplateNumber  from rds_t_TemplateList_input)
             ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}



#' 删除模板清单为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' TemplateList_insert()
TemplateList_insert<- function(erp_token) {

  sql=paste0("

insert into rds_t_TemplateList select distinct * from rds_t_TemplateList_input



             ")

  res=tsda::sql_update2(token = erp_token,sql_str = sql )
  return(res)
}




