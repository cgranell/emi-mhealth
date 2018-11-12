install.packages("DataExplorer")


library(emidata)
library(DataExplorer)

DataExplorer::create_report(as.data.frame(papers))
