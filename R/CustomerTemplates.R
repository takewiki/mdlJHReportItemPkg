
#' 查询客户对应模板表
#'
#' @param token

#' @return 无返回值
#' @export
#'
#' @examples
#' CustomerTemplates_select()
CustomerTemplates_select<- function(erp_token) {

  sql=paste0("SELECT FSeq	as	序号	,
FTemplateNumber	as	模板号	,
FOrgName	as	公司名称	,
FCustomerNumber	as	客户编码	,
FCustomerName	as	客户名称	,
FSaleDepartment	as	销售部门	,
FTemplateName	as	COA模板	,
FRemark	as	备注
FROM rds_t_CustomerTemplates")

  res=tsda::sql_select2(token = erp_token,sql = sql)
  return(res)
}


#' 清空客户对应模板表
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' CustomerTemplates_truncate()
CustomerTemplates_truncate<- function(erp_token) {

  sql=paste0("
TRUNCATE TABLE rds_t_CustomerTemplates_input ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}


#' 删除客户对应模板表为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' CustomerTemplates_inputdelete()
CustomerTemplates_inputdelete<- function(erp_token) {

  sql=paste0("


 delete from  rds_t_CustomerTemplates_input where FCustomerNumber='' or FCustomerNumber is null
 or FOrgName='' or FOrgName is null   or a.FSaleDepartment='' or a.FSaleDepartment is null


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
#' CustomerTemplates_delete()
CustomerTemplates_delete<- function(erp_token) {

  sql=paste0("
 delete a from  rds_t_CustomerTemplates A INNER JOIN rds_t_CustomerTemplates_input B
 ON  a.FCustomerNumber=b.FCustomerNumber and a.FOrgName=b.FOrgName and a.FSaleDepartment =b.FSaleDepartment
 where  a.FCustomerNumber=b.FCustomerNumber and a.FOrgName=b.FOrgName and a.FSaleDepartment =b.FSaleDepartment

             ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}



#' 删除客户对应模板表为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' CustomerTemplates_insert()
CustomerTemplates_insert<- function(erp_token) {

  sql=paste0("

insert into rds_t_CustomerTemplates select distinct * from rds_t_CustomerTemplates_input



             ")

  res=tsda::sql_update2(token = erp_token,sql_str = sql )
  return(res)
}




