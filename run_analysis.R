URL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL,destfile="/Users/cindyliu/Desktop/Coursera/pimdata.zip")
unzip("/Users/cindyliu/Desktop/Coursera/pimdata.zip")

library(data.table)
library("reshape2")
path<-"/Users/cindyliu/Desktop/Coursera"

labels <- fread(file.path(path,"UCI HAR Dataset/activity_labels.txt")
                        , col.names = c("labels", "activity"))
features <- fread(file.path(path,"UCI HAR Dataset/features.txt")
                  , col.names= c("num", "feature"))
meansd <- grep("(mean|std)\\(\\)", features[, feature])
meansdrow <- features[meansd, feature]
meansdrow <- gsub('[()]', '', meansdrow)

trainXdata<- fread(file.path(path,"UCI HAR Dataset/train/X_train.txt"))[,meansd,with=FALSE]
setnames(trainXdata,colnames(trainXdata), meansdrow)
trainYdata<- fread(file.path(path,"UCI HAR Dataset/train/Y_train.txt")
                   ,col.names= "trainlabel")
trainSubjects <- fread(file.path(path,"UCI HAR Dataset/train/subject_train.txt")
                       , col.names = "trainsubject")
trainfinal<- cbind(trainXdata, trainYdata, trainSubjects)

testXdata<- fread(file.path(path,"UCI HAR Dataset/test/X_test.txt"))[, meansd,with=FALSE]
setnames(testXdata,colnames(testXdata), meansdrow)
testYdata<- fread(file.path(path,"UCI HAR Dataset/test/Y_test.txt")
                  ,col.names= "testlabel")
testSubjects <- fread(file.path(path,"UCI HAR Dataset/test/subject_test.txt")
                      , col.names = c("testsubject"))
testfinal<- cbind(testSubjects, testYdata,testXdata)

final<- rbind(testfinal,trainfinal,fill=TRUE)

final[["testlabel"]] <- factor(final[, testlabel]
                                 , levels = labels[["labels"]]
                                 , labels = labels[["activity"]])

final[["testsubject"]] <- as.factor(final[, testsubject])
final<- melt(data = final, id = c("testsubject", "testlabel"))
final <-dcast(data = final, testsubject + testlabel ~ variable, fun.aggregate = mean)

fwrite(x=final, file="tidydata.csv")
              