#Check if file already downloaded and if not, download and save time saved
url <- "https://github.com/camillebt/RepData_PeerAssessment1/blob/master/activity.zip"
path <- getwd()
dataFile <- "dataFiles.zip"

if (!file.exists(dataFile)){
  download.file(url, file.path(path, dataFile))
}
if (!file.exists("activity.csv")){
  unzip(dataFile)
}
tstp <- date()