#run_analysis.R file for courseproject
library(data.table)
library(reshape2)
#assign filenames to variables
trainingSetFilename<-"data\\UCI HAR Dataset\\train\\X_train.txt"
trainingLabelsFilename<-"data\\UCI HAR Dataset\\train\\y_train.txt"

testsetFilename<-"data\\UCI HAR Dataset\\test\\X_test.txt"
testLabelsFilename<-"data\\UCI HAR Dataset\\test\\y_test.txt"

featureFilename<-"data\\UCI HAR Dataset\\features.txt"
testsubjectFilename<-"data\\UCI HAR Dataset\\test\\subject_test.txt"
trainsubjectFilename<-"data\\UCI HAR Dataset\\train\\subject_train.txt"
activitiesFilename<-"data\\UCI HAR Dataset\\activity_labels.txt"


# 1. Merges the training and the test sets to create one data set

##read the data
trainingdata<-read.table(trainingSetFilename, sep="", header=FALSE)
trainingLabels<-read.table(trainingLabelsFilename, sep="", header=FALSE)

testdata<-read.table(testsetFilename, sep="", header=FALSE)
testLabels<-read.table(testLabelsFilename, sep="", header=FALSE)


#2. Extracts only the measurements on the mean and standard deviation 
#for each measurement.
##read the feature data
features<-read.table(featureFilename, sep="", header=FALSE)
##create filter for the data
featuresfilter<-grepl("mean|std", features[[2]])

#name the columns
names(trainingdata)<-features[[2]]
names(testdata)<-features[[2]]

##filter the data
trainingdata<-trainingdata[,featuresfilter]
testdata<-testdata[,featuresfilter]



#3. Uses descriptive activity names to name the activities in the data set
activitiesNames<-read.table(activitiesFilename, sep="", header=FALSE)
testLabels[,2]<-activitiesNames[testLabels[,1],2]
trainingLabels[,2]<-activitiesNames[trainingLabels[,1],2]


names(testLabels)<-c("activityID", "activityName")
names(trainingLabels)<-c("activityID", "activityName")

testsubjectFilename<-"data\\UCI HAR Dataset\\test\\subject_test.txt"
trainsubjectFilename<-"data\\UCI HAR Dataset\\train\\subject_train.txt"

testSubjects<-read.table(testsubjectFilename, sep="", header=FALSE)
trainSubjects<-read.table(trainsubjectFilename, sep="", header=FALSE)

names(testSubjects)<-"Subjects"
names(trainSubjects)<-"Subjects"

##merge the data


tmpTest<-cbind(as.data.table(testSubjects), testdata, testLabels)
tmpTrain<-cbind(as.data.table(trainSubjects), trainingdata, trainingLabels)

thedata<-rbind(tmpTest,tmpTrain)

#4. Appropriately labels the data set with descriptive variable names. 

meltedid = c("Subjects", "activityID", "activityName")
meltedvars = setdiff(colnames(thedata), meltedid)
melteddata     = melt(thedata, id = meltedid ,measure.vars = meltedvars)
                    
tidydataset   = dcast(melteddata, Subjects + activityName ~ variable, mean)
#write.table(tidydataset, file="tidydataset.txt", row.name=FALSE )
