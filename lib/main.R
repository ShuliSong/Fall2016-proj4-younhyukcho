##similarity matrix-Collaborative Filtering
library(rhdf5)
library(lsa)
library(gtools)
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

train_feature<-matrix(0,2350,45)

for (i in 1:nrow(Y)) {
  for (j in 1:15){
    train_feature[i,(j-1)*3+1]<-mean(mydata[[i]][[j]])
    train_feature[i,(j-1)*3+2]<-median(mydata[[i]][[j]])
    train_feature[i,(j-1)*3+3]<-sd(mydata[[i]][[j]])
  }
}

##taking out songs with no feature data
Y<-Y[-unique(which(feature=="NaN",arr.ind=TRUE)[,1]),]
feature<-feature[-unique(which(feature=="NaN",arr.ind=TRUE)[,1]),]
y_train<-Y

##took out csv file 
dir_test<-"C:/Users/YounHyuk/Desktop/TestSongFile100/TestSongFile100"
dir_names_test<-list.files(dir_test)
dir_names_test<-mixedsort(dir_names_test)

test_data<-list()

for (i in 1:length(dir_names_test)) {
  
  test_data[[i]]<-h5read(paste0(dir_test,"/",dir_names_test[i]),"/analysis")
  test_data[[i]]$songs<-NULL
  
}

test_feature<-matrix(0,100,45)

for (i in 1:nrow(test_feature)) {
  for (j in 1:15){
    test_feature[i,(j-1)*3+1]<-mean(test_data[[i]][[j]])
    test_feature[i,(j-1)*3+2]<-median(test_data[[i]][[j]])
    test_feature[i,(j-1)*3+3]<-sd(test_data[[i]][[j]])
  }
}

##cosine disance
cos_dist<-cosine(cbind(t(train_feature),t(test_feature)))
cos_dist_upper<-cos_dist[1:(dim(train_feature)[1]),(dim(train_feature)[1]+1):(dim(train_feature)[1]+dim(test_feature)[1])]

##choosing 15 most similar songs from training data
rank_matrix<-matrix(0,nrow(test_feature),4973)
for (i in 1:nrow(test_feature)) {
  ##n_siml<-which(cos.dist.upper[,i]%in%sort(cos.dist.upper[,i],decreasing=T)[1:40])
  n_siml<-sort(cos_dist_upper[,i],decreasing=T,index.return=T,na.last=T,method="radix")$ix[1:15]
  rank_matrix[i,]<-rank(-colMeans(y_train[n_siml,]))
}





