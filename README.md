### Description of the R code for the programming exercise "Data Cleaning"
### Downloading datasets
My first attempts to download X_train.txt into R with read.csv were unsuccessful due to variable number of spaces between records.  Since the file appeared to be in fixed width format and it contains only numbers read.fwf function looked like a good choice. While read.fwf did worked when I tried to read the first 5 lines, but it was incredibly slow. Consequently, I employed scan(). First, only one line was read to determine the number of numeric records per line. 
a<-scan(file="./UCI HAR Dataset/train/X_train.txt", nlines=1)
colNa<-length(a)

Then, the whole file was read and transformed into a matrix and, then, into a dataframe.
a<-scan(file="./UCI HAR Dataset/train/X_train.txt")
rowNa=length(a)/colNa
a<-matrix(a, ncol=colNa, byrow=T, nrow=rowNa)
a<-as.data.frame(a)

Files y_train.txt and subject_train.txt were opened using read.csv and attached to the dataset with cbind() command.

Train y added
a_y<-read.csv(file="./UCI HAR Dataset/train/y_train.txt",header=F)
a<-cbind(a,y=a_y$V1)
Subject column added
a_s<-read.csv(file="./UCI HAR Dataset/train/subject_train.txt",header=F)
a<-cbind(a,Subject=a_s$V1)

Identical code was used to generate the test dataset.
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

### Merging Training and Test Datasets
After manual check that the number of columns was the same, the datasets were concatenated with using rbind. I also introduced a new variable “Source” to keep track where the data came from the Training or Test datasets.
d<-data.frame(rbind(a,b),Source=rep( c("Train","Test"),c(rowNa,rowNb)  ) )

### Extracts only the measurements on the mean and standard deviation for each measurement. 
First, I downloaded file feature.txt and created extra variable in format like "V1" to match that in the merged dataset.
f<-read.csv(file="./UCI HAR Dataset/features.txt",sep=" ",header=F)
names(f)<-c("ColNumb","Name")
f$Var<-paste("V",1:nrow(f),sep="")
Measurements were extracted containing mean or std in the name.  "y", "Subject", "Source" were also retained.
d<-d[,c(f$Var[c(grep("[Mm]ean",f$Name),grep("[Ss]td",f$Name))],"y","Subject","Source")]

### Use descriptive activity names to name the activities in the data set
Since the merged dataset, at this point, has only a subset of original variables (mean and std), to find correct labels matching V-names had to be used. 
indx<-match(names(d),f$Var)
names(d)[!is.na(indx)] <-as.character(f$Name[indx[!is.na(indx)] ])

Now it is time to substitute y numeric code by Activity labels.
l<-read.csv(file="./UCI HAR Dataset/activity_labels.txt",sep=" ",header=F)
names(l)<-c("y","Activity")
d<-merge(d,l,by="y")
“y” variable, itself, is no longer needed.
d<-d[,-1]

### Summary by Activity, Subject
aggregate() function allows convenient summarization of every variable by Activity and Subject. 
d2<-with(d,aggregate(d, by=list(Activity,Subject),mean, na.rm=T))
Deleting non-informative columns and explicitly naming group variables. 
d2<-d2[,-match(c("Subject","Source","Activity"),names(d2))]
names(d2)[1:2]<-c("Activity","Subject")

### Creating tidy dataset with the average of each variable for each activity and each subject.  
The last thing to do for the task is to transform wide dataset d2 into tidy one. Thanks, to the lectures, melt() function can be used from reshape2 package; since it is not base R, few books mention it .   

library( reshape2)
d3<-melt(d2,id=names(d2)[1:2],measure.vars=names(d2)[3:ncol(d2)])

#Upload your data set as a txt file created with write.table() using row.name=FALSE 
write.table(d3, file="./tidy_summary_dataset.txt",sep="\t",row.name=F)
