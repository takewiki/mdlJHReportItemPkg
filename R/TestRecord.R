
#' 查询检测记录
#'
#' @param token

#' @return 无返回值
#' @export
#'
#' @examples
#' TestRecord_select()
TestRecord_select<- function(erp_token) {

  sql=paste0("SELECT FDate	as	日期	,
FProductName	as	品名	,
FVersionNumber	as	版本号	,
FBatchNumber	as	罐号	,
Flot	as	批号	,
FViscosityReMeasure	as	粘度	,
FviscosityDetection	as	复测粘度	,
FtemperatureCheck	as	检测温度	,
FSpecialViscosity	as	特殊温度粘度	,
FSpecialTemperature	as	特殊检测温度	,
FSoftPoint	as	软化点	,
Fcolor	as	颜色	,
FTransparency	as	透明度	,
FIsFluorescence	as	是否去荧光	,
FMaterialLoader	as	投料员	,
FInstrumentNumber	as	仪器编号	,
FProductCategories	as	产品分类	,
FTestTank	as	试验罐	,
FRemark	as	备注	,
FMaterialNumber	as	物料编码	,
FRotor	as	转子
FROM rds_t_TestRecord")

  res=tsda::sql_select2(token = erp_token,sql = sql)
  return(res)
}


#' 清空检测记录
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' TestRecord_truncate()
TestRecord_truncate<- function(erp_token) {

  sql=paste0("
TRUNCATE TABLE rds_t_TestRecord_input ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}


#' 删除检测记录为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' TestRecord_inputdelete()
TestRecord_inputdelete<- function(erp_token) {

  sql=paste0("


 delete from  rds_t_TestRecord_input where Flot='' or Flot is null

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
#' TestRecord_delete()
TestRecord_delete<- function(erp_token) {

  sql=paste0("


 delete from  rds_t_TestRecord where Flot in (select Flot  from rds_t_TestRecord_input)

             ")

  res=tsda::sql_delete2(token = erp_token,sql_str = sql )
  return(res)
}



#' 删除检测记录为空
#'
#' @param erp_token

#' @return 无返回值
#' @export
#'
#' @examples
#' TestRecord_insert()
TestRecord_insert<- function(erp_token) {

  sql=paste0("

insert into rds_t_TestRecord select distinct * from rds_t_TestRecord_input



             ")

  res=tsda::sql_update2(token = erp_token,sql_str = sql )
  return(res)
}




#' 按日期查询COA记录
#'
#' @param token
#' @param FDate

#' @return 无返回值
#' @export
#'
#' @examples
#' COA_selectByDate()
COA_selectByDate<- function(erp_token,FDate) {

  sql=paste0("exec rds_proc_ReportItem_DeliveryNotice_listByDate '",FDate,"'   ")

  res=tsda::sql_select2(token = erp_token,sql = sql)
  return(res)
}

#' 按月查询COA记录
#'
#' @param token
#' @param FDate

#' @return 无返回值
#' @export
#'
#' @examples
#' COA_selectByMonth()
COA_selectByMonth<- function(erp_token,FDate) {

  sql=paste0("exec rds_proc_ReportItem_DeliveryNotice_listByMonth '",FDate,"'   ")

  res=tsda::sql_select2(token = erp_token,sql = sql)
  return(res)
}


