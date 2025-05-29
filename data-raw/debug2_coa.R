templateFile = "/home/hulilei/www/COA/M002_102_IMP.xlsx"

#templateFile = "/home/hulilei/www/JH_CheckNote_Template100.xlsx"

xlsx_file_name = "/home/hulilei/COA_XSCKD-100-20250523-0001_PEGATEX_ARTECOLA_S_A_.xlsx"
excel_file <- openxlsx::loadWorkbook(templateFile)

# cellData_head = "JH-2025042736"
#
# indexRow = 8
#
# indexCol = 3
#
# openxlsx::writeData(wb = excel_file, sheet = "Sheet1", x = cellData_head,
#                     startCol = indexCol, startRow = indexRow, colNames = FALSE)
openxlsx::saveWorkbook(excel_file, xlsx_file_name, overwrite = TRUE)


