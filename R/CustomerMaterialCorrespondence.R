
#' 查询客户物料对应
#'
#' @param token

#' @return 无返回值
#' @export
#'
#' @examples
#' CustomerMaterialCorrespondence_select()
CustomerMaterialCorrespondence_select<- function(erp_token) {

  sql=paste0("

SELECT FCustomerNumber	AS	客户编码	,
FCustomerName	AS	客户名称	,
FProductNumber	AS	产品编码	,
FProductName	AS	产品名称	,
FIsNeeded_JMJT	AS	是否需要JM或JT	,
FPrefix	AS	前缀	,
FSuffix	AS	后缀	,
FOtherSituations	AS	其他情况	,
FMaterialFullName	AS	物料全称	,
FMaterialName	AS	物料名称	,
FMaterialNumber	AS	物料编码	,
FProductItemNumber	AS	产品品号	,
FCustomerNo	AS	客户编码2
 FROM rds_t_CustomerMaterialCorrespondence
")

  res=tsda::sql_select2(token = erp_token,sql = sql)
  return(res)
}


#' 清空客户物料对应
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' CustomerMaterialCorrespondence_truncate()
CustomerMaterialCorrespondence_truncate<- function(erp_token) {

  sql=paste0("
TRUNCATE TABLE rds_t_CustomerMaterialCorrespondence_input ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}


#' 删除客户物料对应为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' CustomerMaterialCorrespondence_inputdelete()
CustomerMaterialCorrespondence_inputdelete<- function(erp_token) {

  sql=paste0("
  delete b FROM rds_t_CustomerMaterialCorrespondence A
 INNER JOIN rds_t_CustomerMaterialCorrespondence_INPUT b
 ON A.FCustomerNumber=B.FCustomerNumber AND A.FProductNumber=B.FProductNumber
 where b.FCustomerNumber='' or b.FProductNumber='' or ( A.FCustomerNumber=B.FCustomerNumber AND A.FProductNumber=B.FProductNumber)

             ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}


#' 删除客户物料对应为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' CustomerMaterialCorrespondence_insert()
CustomerMaterialCorrespondence_insert<- function(erp_token) {

  sql=paste0("

insert into rds_t_CustomerMaterialCorrespondence select distinct * from rds_t_CustomerMaterialCorrespondence_input



             ")

  res=tsda::sql_update2(token = erp_token,sql_str = sql )
  return(res)
}




