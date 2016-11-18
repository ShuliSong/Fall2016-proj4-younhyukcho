##modeling of count data using glm(poisson regression)
library(rhdf5)
library(pscl)
setwd("C:/Users/YounHyuk/Desktop/project4/Project4_data")

dir<-"C:/Users/YounHyuk/Desktop/project4/Project4_data/data/data"
dir_names<-list.files(dir,recursive=TRUE)

n<-length(dir_names)

mydata<-list()

for (i in 1:n) {
  
mydata[[i]]<-h5read(paste0(dir,"/",dir_names[i]),"/analysis")
mydata[[i]]$songs<-NULL

}

load("lyr.RData")

Y<-lyr[,-c(1,2,3,6:30)]

##creating indicator variable 1 if word i in song, 0 otherwise
##newY<-apply(Y, 2, function(x) {ifelse(x>0,1,0)})

#set.seed(1)
#ind<-sample(1:2350,1645)
#y_train<-Y[ind,]
#y_test<-Y[-ind,]

##45 features using mean, median and standard deviation of the features
feature<-matrix(0,2350,45)

for (i in 1:nrow(Y)) {
  for (j in 1:15){
    feature[i,(j-1)*3+1]<-mean(mydata[[i]][[j]])
    feature[i,(j-1)*3+2]<-median(mydata[[i]][[j]])
    feature[i,(j-1)*3+3]<-sd(mydata[[i]][[j]])
  }
}


##removing data with no values  e.g. song #715 does not have data for bar_confidence
Y<-Y[-unique(which(feature=="NaN",arr.ind=TRUE)[,1]),]
feature<-feature[-unique(which(feature=="NaN",arr.ind=TRUE)[,1]),]
##feature<-na.omit(feature)

set.seed(1)
ind<-sample(1:nrow(Y),1639)##1639
y_train<-Y[ind,]
y_test<-Y[-ind,]
train_feature<-feature[ind,]
test_feature<-feature[-ind,]


count_matrix<-matrix(0,4973,702)

##We considered subset of mean, median and standard deviation values
##found out that mean and median has too much collinearity with each other
##using only mean and standard deviation
for (i in 1:ncol(y_train)) {
  model<-cv.glmnet(train_feature,y_train[,i],family="poisson",alpha=1)
  count_matrix[i,]<-as.vector(round(predict(model,test_feature,type='response')))
}

##some convergence problem
##make 
ranks<-sapply(count_matrix,2,rank)


sort(y_test[1,],decreasing=T)[1:50]
a<-sort(count_matrix[,1],decreasing=T,index.return=T)$ix[1:50]
colnames(y_test)[a]

pred_rank_sum<-



###############################
##clustering
feature<-na.omit(feature)
feature<-scale(feature)
wss <- (nrow(feature)-1)*sum(apply(feature,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(feature, 
                                     centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",ylab="Within groups sum of squares")

fit <- kmeans(feature, 9) # 9 cluster solution
aggregate(feature,by=list(fit$cluster),FUN=mean)
data_clust <- data.frame(feature, fit$cluster)





