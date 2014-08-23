rm(list=ls())
# Using scan() to read file. read.fwf was too slow.
a<-scan(file="./UCI HAR Dataset/train/X_train.txt", nlines=1)
colNa<-length(a)
a<-scan(file="./UCI HAR Dataset/train/X_train.txt")
rowNa=length(a)/colNa
a<-matrix(a, ncol=colNa, byrow=T, nrow=rowNa)
a<-as.data.frame(a)
#Train y added
a_y<-read.csv(file="./UCI HAR Dataset/train/y_train.txt",header=F)
a<-cbind(a,y=a_y$V1)
#Tran subject added
a_s<-read.csv(file="./UCI HAR Dataset/train/subject_train.txt",header=F)
a<-cbind(a,Subject=a_s$V1)

#Similar code for test set
b<-scan(file="./UCI HAR Dataset/test/X_test.txt", nlines=1)
colNb<-length(b)
b<-scan(file="./UCI HAR Dataset/test/X_test.txt")
rowNb=length(b)/colNb
b<-matrix(b, ncol=colNb, byrow=T, nrow=rowNb)
b<-as.data.frame(b)

b_y<-read.csv(file="./UCI HAR Dataset/test/y_test.txt",header=F)
b<-cbind(b,y=b_y$V1)
b_s<-read.csv(file="./UCI HAR Dataset/test/subject_test.txt",header=F)
b<-cbind(b,Subject=b_s$V1)

#Merges the training and the test sets to create one data set.
d<-data.frame(rbind(a,b),Source=rep( c("Train","Test"),c(rowNa,rowNb)  ) )
rm(list=c("a_s","a_y","b_y","b_s","a","b"))

#Features list, creating extra variable in format like "V1" to match d
f<-read.csv(file="./UCI HAR Dataset/features.txt",sep=" ",header=F)
names(f)<-c("ColNumb","Name")
f$Var<-paste("V",1:nrow(f),sep="")

#Extracts only the measurements on the mean and standard deviation for each measurement. 
d<-d[,c(f$Var[c(grep("[Mm]ean",f$Name),grep("[Ss]td",f$Name))],"y","Subject","Source")]

#Uses descriptive activity names to name the activities in the data set
#Appropriately labels the data set with descriptive variable names. 
indx<-match(names(d),f$Var)
names(d)[!is.na(indx)] <-as.character(f$Name[indx[!is.na(indx)] ])

#Activity labels instead of y code
l<-read.csv(file="./UCI HAR Dataset/activity_labels.txt",sep=" ",header=F)
names(l)<-c("y","Activity")

d<-merge(d,l,by="y")
d<-d[,-1]
rm("colNa","colNb","rowNa","rowNb","indx")

# Summary by Activity, Subject
d2<-with(d,aggregate(d, by=list(Activity,Subject),mean, na.rm=T))
d2<-d2[,-match(c("Subject","Source","Activity"),names(d2))]
#Renaming back grouping variables
names(d2)[1:2]<-c("Activity","Subject")

#Creating tidy dataset with the average of each variable for each activity and each subject. 
library( reshape2)
d3<-melt(d2,id=names(d2)[1:2],measure.vars=names(d2)[3:ncol(d2)])

#Please upload your data set as a txt file created with write.table() using row.name=FALSE 
write.table(d3, file="./tidy_summary_dataset.txt",sep="\t",row.name=F)
