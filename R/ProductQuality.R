
#' 查询产品质量
#'
#' @param token

#' @return 无返回值
#' @export
#'
#' @examples
#' ProductQuality_select()
ProductQuality_select<- function(erp_token) {

  sql=paste0("
SELECT
FCustomerName as 客户名称,
FMaterialNumber	as	物料编码	,
FViscosityTestMethods	as	粘度测试方法	,
FViscosityUnit	as	粘度单位	,
FViscosityCentralValue	as	粘度中心值	,
FViscosityOnTolerance	as	粘度上公差	,
FViscosityDownTolerance	as	粘度下公差	,
FSoftPointTestMethods	as	软化点测试方法	,
FSoftPointUnit	as	软化点单位	,
FSoftPointCentralValue	as	软化点中心值	,
FSoftPointOnTolerance	as	软化点上公差	,
FSoftPointDownTolerance	as	软化点下公差	,
FColorTestMethods	as	颜色测试方法	,
FColorUnit	as	颜色单位	,
FColorCentralValue	as	颜色中心值	,
FColorOnTolerance	as	颜色上公差	,
FColorDownTolerance	as	颜色下公差
FROM rds_t_ProductQuality")

  res=tsda::sql_select2(token = erp_token,sql = sql)
  return(res)
}


#' 清空产品质量
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' ProductQuality_truncate()
ProductQuality_truncate<- function(erp_token) {

  sql=paste0("
TRUNCATE TABLE rds_t_ProductQuality_input ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}


#' 删除产品质量为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' ProductQuality_inputdelete()
ProductQuality_inputdelete<- function(erp_token) {

  sql=paste0("

 delete from  rds_t_ProductQuality_input where FMaterialNumber='' or FMaterialNumber is null

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
#' ProductQuality_delete()
ProductQuality_delete<- function(erp_token) {

  sql=paste0("


 delete from  rds_t_ProductQuality where  FMaterialNumber in (select FMaterialNumber  from rds_t_ProductQuality_input)

             ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}


#' 删除产品质量为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' ProductQuality_insert()
ProductQuality_insert<- function(erp_token) {

  sql=paste0("

insert into rds_t_ProductQuality select distinct * from rds_t_ProductQuality_input



             ")

  res=tsda::sql_update2(token = erp_token,sql_str = sql )
  return(res)
}




