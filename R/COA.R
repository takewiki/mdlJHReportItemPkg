#' 判断记录是否存在-------
#'
#' @param erpToken ERP口令
#' @param FBillNo  单据编号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' coa_IsNew()
coa_IsNew <- function(erpToken = 'C0426D23-1927-4314-8736-A74B2EF7A039', FBillNo = "XSCKD-102-20250521-0004") {
  sql = paste0("select F_RDS_COA_TEMPLATENUMBER  from rds_erp_coa_vw_sal_outStock_task
where FBillNo = '",FBillNo,"'
order by FDATE")
  print(sql)
  data = tsda::sql_select2(token = erpToken,sql = sql)
  ncount = nrow(data)
  if (ncount) {
    res = TRUE
  }else{
    res = FALSE
  }
  return(res)

}

#' 通过销售出现单获取COA模板号
#'
#' @param erpToken ERP口令
#' @param FBillNo 单据编号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' coa_GetTemplateNumber()
coa_GetTemplateNumber <- function(erpToken = 'C0426D23-1927-4314-8736-A74B2EF7A039', FBillNo = "XSCKD-102-20250521-0004") {
  sql = paste0("select F_RDS_COA_TEMPLATENUMBER  from rds_erp_coa_vw_sal_outStock_task
where FBillNo = '",FBillNo,"'
order by FDATE")
  data = tsda::sql_select2(token = erpToken,sql = sql)
  ncount = nrow(data)
  if (ncount) {
    res = data$F_RDS_COA_TEMPLATENUMBER[1]
    if (res == ''|res == ' '){
      res = NULL
    }
  }else{
    res = NULL
  }
  return(res)

}

#' 获取单据清单
#'
#' @param erpToken ERP 口令
#'
#' @return 返回值
#' @export
#'
#' @examples
#' coa_TaskToSync()
coa_SyncAll <- function(erpToken = 'C0426D23-1927-4314-8736-A74B2EF7A039',outputDir = getwd(), delete_localFiles = 1) {
  sql = paste0("select FBillNo  from rds_erp_coa_vw_sal_outStock_task")
  data = tsda::sql_select2(token = erpToken,sql = sql)
  ncount = nrow(data)
  if(ncount){
    for (i in 1:ncount) {
      FBillNo = data$FBillNo[i]
      coa_pdf(erpToken = erpToken,FBillNo = FBillNo,outputDir = outputDir,delete_localFiles = delete_localFiles)

    }
  }

}
#' 获取客户名称
#'
#' @param erpToken ERP口令
#' @param FBillNo 单据编号
#'
#' @return 返回值
#' @export
#'
#' @examples
#' coa_GetCustomerName()
coa_GetCustomerName <- function(erpToken = 'C0426D23-1927-4314-8736-A74B2EF7A039', FBillNo = "XSCKD-102-20250521-0004") {
  sql = paste0("select FCustomerName  from rds_erp_coa_vw_sal_outStock_task
where FBillNo = '",FBillNo,"'
order by FDATE")
  data = tsda::sql_select2(token = erpToken,sql = sql)
  ncount = nrow(data)
  if (ncount) {
    res = data$FCustomerName[1]
    res = gsub(" ","_",res)
    res = gsub("\\.","_",res)
    res = gsub(",","_",res)
    res = gsub("\\(","_",res)
    res = gsub("\\)","_",res)
    if (res == ''){
      res = NULL
    }
  }else{
    res = NULL
  }
  return(res)

}


#' 返回元数据信息
#'
#' @param erpToken ERP口令
#' @param FTemplateNumber 模板号
#' @param FTableType 数据类型
#'
#' @return 返回值
#' @export
#'
#' @examples
#' coa_meta()
coa_meta <- function(erpToken = 'C0426D23-1927-4314-8736-A74B2EF7A039',
                     FTemplateNumber ='M001_100_IMP' ,
                     FTableType ='billHead') {
  sql = paste0("select FName_ERP_en,FTableName,FCells from [rds_t_ReportConfiguration]
where   FTemplateNumber ='",FTemplateNumber,"' and FTableType ='",FTableType,"'")
  data = tsda::sql_select2(token = erpToken,sql = sql)
  return(data)

}
#' 将excel列转
#'
#' @param col_str 列名
#'
#' @return 返回值
#'
#' @examples
#' excel_col_to_num()
excel_col_to_num <- function(col_str) {
  col_str <- toupper(col_str)
  chars <- strsplit(col_str, "")[[1]]
  sum <- 0
  for (char in chars) {
    sum <- sum * 26 + which(LETTERS == char)
  }
  return(sum)
}

# 将Excel坐标转换为行列数字
#' 将数据左边进行处理
#'
#' @param coord 提供坐标
#'
#' @return 返回值
#' @export
#'
#' @examples
#' excel_coord_to_numeric()
excel_coord_to_numeric <- function(coord) {
  col_str <- gsub("[^A-Za-z]", "", coord)
  row_num <- as.integer(gsub("[^0-9]", "", coord))
  col_num <- excel_col_to_num(col_str)
  return(c(col = col_num, row = row_num))
}

#' 将销售出库单数据写入EXCEL并上传到OSS对象存储
#'
#' @param erpToken ERP口令
#' @param outputDir 输出地址
#' @param delete_localFiles 是否删除本地文件
#' @param FBillNo 单据编号
#'
#' @return 返回值
#' @import openxlsx
#' @export
#'
#' @examples
#' coa_pdf()
coa_pdf <-function (erpToken = 'C0426D23-1927-4314-8736-A74B2EF7A039', FBillNo = "XSCKD-100-20250523-0001",
          outputDir = getwd(), delete_localFiles = 1)
{
  flag_new = coa_IsNew(erpToken = erpToken,FBillNo=FBillNo)
  print(flag_new)
  print(1)
  if(flag_new){
    #全新的数据，做进一步处理
    #获取模板号
    template_coa = coa_GetTemplateNumber(erpToken = erpToken,FBillNo = FBillNo)
    if(is.null(template_coa)){
      print(paste0("销售出库单",FBillNo,"模板号为空，请及时维护"))
    }else{
      print(2)
      #进一步处理
      meta_head = coa_meta(erpToken = erpToken ,FTemplateNumber = template_coa,FTableType = 'billHead')
      ncount_meta_head = nrow(meta_head)
      fields_head = paste0(meta_head$FName_ERP_en,collapse = " , ")
      table_head = meta_head$FTableName[1]
      sql_head = paste0("select  ",fields_head,"   from  ",table_head," where FBillNo  = '",FBillNo,"' ")
      data_head =  tsda::sql_select2(token = erpToken,sql = sql_head)
      ncount_head = nrow(data_head)

      meta_entry = coa_meta(erpToken = erpToken ,FTemplateNumber = template_coa,FTableType = 'billEntry')
      ncount_meta_entry = nrow(meta_entry)
      fields_entry = paste0(meta_entry$FName_ERP_en,collapse = " , ")
      table_entry = meta_entry$FTableName[1]
      sql_entry = paste0("select  ",fields_entry,"   from  ",table_entry," where FBillNo  = '",FBillNo,"' ")
      data_entry =  tsda::sql_select2(token = erpToken,sql = sql_entry)
      ncount_entry = nrow(data_entry)
      if(ncount_head){
        print(3)
        #表头存在数据
        if(ncount_entry){
          #表体存在数据，进行相应的数据处理
          #获取完整的模板文件
          templateFile = paste0(outputDir, "/www/COA/",template_coa, ".xlsx")
          print(templateFile)
          excel_file <- openxlsx::loadWorkbook(templateFile)
          #写入表头数据
          for ( i in 1:ncount_meta_head) {
             #针对数据处理处理
            field_head = meta_head$FName_ERP_en[i]
            cell_head  = meta_head$FCells[i]
            if (field_head == 'F_RDS_COA_IssueDate'| field_head =='F_RDS_COA_ShipDate'){
              #针对日期字段进行处理，去掉时间部分
              cellData_head = tsdo::left(as.character(data_head[1,field_head]),10)
            }else{
               cellData_head = as.character(data_head[1,field_head])
            }


            print(cellData_head)
            cellIndex_head =excel_coord_to_numeric(cell_head)
            indexCol = cellIndex_head['col']
            indexRow = cellIndex_head['row']
            print(indexCol)
            print(indexRow)
            print('*******************debug*******************************')
            print(paste0("cellData:",cellData_head,"row:",indexRow,"col:",indexCol))
            openxlsx::writeData(wb = excel_file, sheet = "Sheet1", x = cellData_head,
                                       startCol = indexCol, startRow = indexRow, colNames = FALSE)

          }


          print(4)
          #处理表体数据
          for (j in 1:ncount_meta_entry) {
            fields_entry = meta_entry$FName_ERP_en[j]
            cell_entry = meta_entry$FCells[j]
            cellIndex_entry = excel_coord_to_numeric(cell_entry)
            for (k in 1:ncount_entry) {
              cellData_entry = data_entry[k ,fields_entry]

              print(cellData_entry)
              cellIndex_entry = excel_coord_to_numeric(cell_entry)
              openxlsx::writeData(wb = excel_file, sheet = "Sheet1", x = cellData_entry,
                                  startCol = cellIndex_entry['col'], startRow = cellIndex_entry['row'] + k -1, colNames = FALSE)
            }


          }


          #处理文件名生成EXCEL
          print(5)
          FCumstoerName = coa_GetCustomerName(erpToken = erpToken,FBillNo = FBillNo)
          outputFile = paste0("COA_",FBillNo, "_", FCumstoerName,".xlsx")
          pdf_base_name = paste0("COA_",FBillNo, "_", FCumstoerName,".pdf")
          xlsx_file_name = paste0(outputDir, "/", outputFile)
          print(xlsx_file_name)
          pdf_full_name = paste0(outputDir, "/", pdf_base_name)
          saveWorkbook(excel_file, xlsx_file_name, overwrite = TRUE)
          #生成PDF
          cmd = paste0("libreoffice --headless --convert-to pdf --outdir ",
                       outputDir, "  ", xlsx_file_name)
          Sys.setenv(LD_LIBRARY_PATH = paste("/usr/lib/libreoffice/program",
                                             Sys.getenv("LD_LIBRARY_PATH"), sep = ":"))
          system(cmd)
          #上传文件到OSS
          #start line
          dms_token = "AB8B9239-24C7-4599-99A9-69E09FEAEF01"
          oss_token = "A56C6025-A189-49A1-BE38-813BFAF52EF5"
          type = "jhcoa"
          #上传excel
          Url_excel = mdlOssr::rdOssFile_upload(dmsToken = dms_token,
                                              ossToken = oss_token, type = type, baseName = outputFile,
                                              fullName = xlsx_file_name)

          Url_pdf = mdlOssr::rdOssFile_upload(dmsToken = dms_token,
                                              ossToken = oss_token, type = type, baseName = pdf_base_name,
                                              fullName = pdf_full_name)
          #print(fileUrl)
          sql_oss = paste0("update a set   F_QH_QualityReport =1,F_RDS_RPA=1,F_NLJ_COA_XLSX ='",Url_excel,"',F_NLJ_COA_PDF='",Url_pdf,"'
                  from t_sal_outStock a
                  where FBILLNO ='",FBillNo,"'")
          tsda::sql_update2(token = erpToken, sql_str = sql_oss)
          if (delete_localFiles) {
            if (file.exists(xlsx_file_name)) {
              file.remove(xlsx_file_name)
            }
            if (file.exists(pdf_full_name)) {
              file.remove(pdf_full_name)
            }
          }
          #end line




        }

      }





    }


  }else{
    #任务不在COA任务中，不需要进行处理
  }

}




#       writeData(wb = excel_file, sheet = "Sheet1", x = data,
#                 startCol = 1, startRow = 10, colNames = FALSE)
#       writeData(wb = excel_file, "Sheet1", FCustName,
#                 startCol = 2, startRow = 6)
#       writeData(wb = excel_file, "Sheet1", FCustName,
#                 startCol = 10, startRow = 29)
#       writeData(wb = excel_file, "Sheet1", FStartDate,
#                 startCol = 5, startRow = 7)
#       writeData(wb = excel_file, "Sheet1", FEndDate, startCol = 7,
#                 startRow = 7)
#       for (sheetName in fix_sheetNames) {
#         removeWorksheet(wb = excel_file, sheetName)
#       }
#     }
#     if (row_count > header_row_count & row_count <= page_row_count) {
#       openxlsx::cloneWorksheet(wb = excel_file, "Sheet1",
#                                page_name)
#       writeData(wb = excel_file, sheet = "Sheet1", x = data,
#                 startCol = 1, startRow = 10, colNames = FALSE)
#       writeData(wb = excel_file, "Sheet1", FCustName,
#                 startCol = 2, startRow = 6)
#       writeData(wb = excel_file, "Sheet1", FStartDate,
#                 startCol = 5, startRow = 7)
#       writeData(wb = excel_file, "Sheet1", FEndDate, startCol = 7,
#                 startRow = 7)
#       writeData(wb = excel_file, "Sheet1", "第1页,共2页",
#                 startCol = 12, startRow = 1)
#       openxlsx::cloneWorksheet(wb = excel_file, "Sheet2",
#                                tailer_name)
#       writeData(wb = excel_file, "Sheet2", FCustName,
#                 startCol = 2, startRow = 6)
#       writeData(wb = excel_file, "Sheet2", FStartDate,
#                 startCol = 5, startRow = 7)
#       writeData(wb = excel_file, "Sheet2", FEndDate, startCol = 7,
#                 startRow = 7)
#       writeData(wb = excel_file, "Sheet2", "第2页,共2页",
#                 startCol = 12, startRow = 1)
#       writeData(wb = excel_file, "Sheet2", FCustName,
#                 startCol = 10, startRow = 12)
#       for (sheetName in fix_sheetNames) {
#         removeWorksheet(wb = excel_file, sheetName)
#       }
#     }
#     if (row_count > page_row_count) {
#       page_info = tsdo::paging_setting(row_count, page_row_count)
#       page_count = nrow(page_info)
#       total_sheet_count = page_count + 1
#       for (page_index in 1:page_count) {
#         page_sheet_name = paste0("Sheet", page_index)
#         openxlsx::cloneWorksheet(wb = excel_file, page_sheet_name,
#                                  page_name)
#         FStart = page_info$FStart[page_index]
#         FEnd = page_info$FEnd[page_index]
#         each_page_data = data[FStart:FEnd, ]
#         writeData(wb = excel_file, sheet = page_sheet_name,
#                   x = each_page_data, startCol = 1, startRow = 10,
#                   colNames = FALSE)
#         writeData(wb = excel_file, page_sheet_name,
#                   FCustName, startCol = 2, startRow = 6)
#         writeData(wb = excel_file, page_sheet_name,
#                   FStartDate, startCol = 5, startRow = 7)
#         writeData(wb = excel_file, page_sheet_name,
#                   FEndDate, startCol = 7, startRow = 7)
#         rooter = paste0("第", page_index, "页,共",
#                         total_sheet_count, "页")
#         writeData(wb = excel_file, page_sheet_name,
#                   rooter, startCol = 12, startRow = 1)
#       }
#       tailer_sheet_name = paste0("Sheet", total_sheet_count)
#       tailer_rooter_name = paste0("第", total_sheet_count,
#                                   "页,共", total_sheet_count, "页")
#       openxlsx::cloneWorksheet(wb = excel_file, tailer_sheet_name,
#                                tailer_name)
#       writeData(wb = excel_file, tailer_sheet_name, FCustName,
#                 startCol = 2, startRow = 6)
#       writeData(wb = excel_file, tailer_sheet_name, FStartDate,
#                 startCol = 5, startRow = 7)
#       writeData(wb = excel_file, tailer_sheet_name, FEndDate,
#                 startCol = 7, startRow = 7)
#       writeData(wb = excel_file, tailer_sheet_name, tailer_rooter_name,
#                 startCol = 12, startRow = 1)
#       writeData(wb = excel_file, tailer_sheet_name, FCustName,
#                 startCol = 10, startRow = 12)
#       for (sheetName in fix_sheetNames) {
#         removeWorksheet(wb = excel_file, sheetName)
#       }
#     }
#     FCustName2 = gsub(" ", "_", FCustName)
#     outputFile = paste0(FCustName2, "_", FStartDate, "_",
#                         FEndDate, "_", FOrgName, "_客户往来对账单.xlsx")
#     pdf_base_name = paste0(FCustName2, "_", FStartDate,
#                            "_", FEndDate, "_", FOrgName, "_客户往来对账单.pdf")
#     xlsx_file_name = paste0(outputDir, "/", outputFile)
#     pdf_full_name = paste0(outputDir, "/", pdf_base_name)
#     saveWorkbook(excel_file, xlsx_file_name, overwrite = TRUE)
#     cmd = paste0("libreoffice --headless --convert-to pdf --outdir ",
#                  outputDir, "  ", xlsx_file_name)
#     Sys.setenv(LD_LIBRARY_PATH = paste("/usr/lib/libreoffice/program",
#                                        Sys.getenv("LD_LIBRARY_PATH"), sep = ":"))
#     system(cmd)
#     dms_token = "AB8B9239-24C7-4599-99A9-69E09FEAEF01"
#     oss_token = "A56C6025-A189-49A1-BE38-813BFAF52EF5"
#     type = "jhchecknote"
#     fileUrl = mdlOssr::rdOssFile_upload(dmsToken = dms_token,
#                                         ossToken = oss_token, type = type, baseName = pdf_base_name,
#                                         fullName = pdf_full_name)
#     print(fileUrl)
#     sql_oss = paste0("update a set a.FIsPrint=1, a.FOssUrl='",
#                      fileUrl, "' ,FPdfFileName ='", pdf_base_name, "'  from rds_t_checkNote_task a\nwhere FStartDate ='",
#                      FStartDate, "' and FEndDate='", FEndDate, "' and FCustName='",
#                      FCustName, "'\nand FOrgNumber='", FOrgNumber, "'")
#     tsda::sql_update2(token = token, sql_str = sql_oss)
#     if (delete_localFiles) {
#       if (file.exists(xlsx_file_name)) {
#         file.remove(xlsx_file_name)
#       }
#       if (file.exists(pdf_full_name)) {
#         file.remove(pdf_full_name)
#       }
#     }
#   }
#   else {
#     row_count = nrow(data)
#     templateFile = paste0(outputDir, "/www/JH_CheckNote_Template",
#                           FOrgNumber, ".xlsx")
#     FOrgName = jhdms_org_getNameByNumber(token = token,
#                                          FOrgNumber = FOrgNumber)
#     print(templateFile)
#     excel_file <- openxlsx::loadWorkbook(templateFile)
#     if (row_count <= header_row_count) {
#       openxlsx::cloneWorksheet(wb = excel_file, "Sheet1",
#                                header_name)
#       writeData(wb = excel_file, "Sheet1", FCustName,
#                 startCol = 2, startRow = 6)
#       writeData(wb = excel_file, "Sheet1", FCustName,
#                 startCol = 10, startRow = 29)
#       writeData(wb = excel_file, "Sheet1", FStartDate,
#                 startCol = 5, startRow = 7)
#       writeData(wb = excel_file, "Sheet1", FEndDate, startCol = 7,
#                 startRow = 7)
#       for (sheetName in fix_sheetNames) {
#         removeWorksheet(wb = excel_file, sheetName)
#       }
#     }
#     FCustName2 = gsub(" ", "_", FCustName)
#     outputFile = paste0(FCustName2, "_", FStartDate, "_",
#                         FEndDate, "_", FOrgName, "_客户往来对账单.xlsx")
#     pdf_base_name = paste0(FCustName2, "_", FStartDate,
#                            "_", FEndDate, "_", FOrgName, "_客户往来对账单.pdf")
#     xlsx_file_name = paste0(outputDir, "/", outputFile)
#     pdf_full_name = paste0(outputDir, "/", pdf_base_name)
#     saveWorkbook(excel_file, xlsx_file_name, overwrite = TRUE)
#     cmd = paste0("libreoffice --headless --convert-to pdf --outdir ",
#                  outputDir, "  ", xlsx_file_name)
#     Sys.setenv(LD_LIBRARY_PATH = paste("/usr/lib/libreoffice/program",
#                                        Sys.getenv("LD_LIBRARY_PATH"), sep = ":"))
#     system(cmd)
#     dms_token = "AB8B9239-24C7-4599-99A9-69E09FEAEF01"
#     oss_token = "A56C6025-A189-49A1-BE38-813BFAF52EF5"
#     type = "jhchecknote"
#     fileUrl = mdlOssr::rdOssFile_upload(dmsToken = dms_token,
#                                         ossToken = oss_token, type = type, baseName = pdf_base_name,
#                                         fullName = pdf_full_name)
#     print(fileUrl)
#     sql_oss = paste0("update a set a.FIsPrint=1, a.FOssUrl='",
#                      fileUrl, "' ,FPdfFileName ='", pdf_base_name, "'  from rds_t_checkNote_task a\nwhere FStartDate ='",
#                      FStartDate, "' and FEndDate='", FEndDate, "' and FCustName='",
#                      FCustName, "'\nand FOrgNumber='", FOrgNumber, "'")
#     tsda::sql_update2(token = token, sql_str = sql_oss)
#     if (delete_localFiles) {
#       if (file.exists(xlsx_file_name)) {
#         file.remove(xlsx_file_name)
#       }
#       if (file.exists(pdf_full_name)) {
#         file.remove(pdf_full_name)
#       }
#     }
#   }
# }
