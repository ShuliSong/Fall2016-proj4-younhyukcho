#########similarity######
library(rhdf5)
library(lsa)
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

feature<-matrix(0,2350,45)

for (i in 1:nrow(Y)) {
  for (j in 1:15){
    feature[i,(j-1)*3+1]<-mean(mydata[[i]][[j]])
    feature[i,(j-1)*3+2]<-median(mydata[[i]][[j]])
    feature[i,(j-1)*3+3]<-sd(mydata[[i]][[j]])
  }
}

##taking out songs with no feature data
Y<-Y[-unique(which(feature=="NaN",arr.ind=TRUE)[,1]),]
feature<-feature[-unique(which(feature=="NaN",arr.ind=TRUE)[,1]),]

set.seed(1)
ind<-sample(1:nrow(Y),1639)
y_train<-Y[ind,]
y_test<-Y[-ind,]
train_feature<-feature[ind,]
test_feature<-feature[-ind,]

##cosine disance
cos_dist<-cosine(cbind(t(train_feature),t(test_feature)))
cos_dist_upper<-cos_dist[1:(dim(train_feature)[1]),(dim(train_feature)[1]+1):(dim(train_feature)[1]+dim(test_feature)[1])]

##choosing 15 most similar songs from training data
##don't want to choose too many similar songs becasue choosing large number will cancel
##out some of the characteristics of the song
rank_matrix<-matrix(0,nrow(y_test),4973)
for (i in 1:nrow(y_test)) {
  ##n_siml<-which(cos.dist.upper[,i]%in%sort(cos.dist.upper[,i],decreasing=T)[1:40])
  n_siml<-sort(cos_dist_upper[,i],decreasing=T,index.return=T,na.last=T,method="radix")$ix[1:15]
  rank_matrix[i,]<-rank(-colMeans(y_train[n_siml,]))
}
rank_test<-t(apply(-y_test,1,rank))


##using spearman's rank correlation to measure association between the two ranks
rho<-vector()
for (i in 1:nrow(y_test)) {
  cova<-cov(rank_matrix[i,],rank_test[i,])
  rho[i]<-cova/(sd(rank_matrix[i,])*sd(rank_test[i,]))
}
mean(rho)


##euclidean distance
euc_dist<-as.matrix(dist(rbind(train_feature,test_feature),method="euclidean"))
euc_dist_upp<-euc_dist[1:(dim(train_feature)[1]),(dim(train_feature)[1]+1):(dim(train_feature)[1]+dim(test_feature)[1])]


rank_euc_matrix<-matrix(0,nrow(y_test),4973)
for (i in 1:nrow(y_test)) {
  n_euc_siml<-which(euc_dist_upp[,i]%in%sort(euc_dist_upp[,i],decreasing=T)[1:15])
  #n_bin_siml<-sort(bin_dis_upp[,i],decreasing=T,index.return=T,na.last=T,method="radix")$ix[1:50]
  rank_euc_matrix[i,]<-rank(-colMeans(y_train[n_euc_siml,]))
}

rho_bin<-vector()
for (i in 1:nrow(y_test)) {
  cova_bin<-cov(rank_bin_matrix[i,],rank_test[i,])
  rho_bin[i]<-cova_bin/(sd(rank_bin_matrix[i,])*sd(rank_test[i,]))
}
mean(rho_bin)

##binary seems to be better method than the cosine 


##calculating predictive rank sum using cosine distance
rank_sum<-vector()

for (i in 1:nrow(y_test)) {
K<-ncol(Y)
m<-length(which(y_test[i,]>0))
mean_rank<-mean(rank_matrix[i,])
rank_sum[i]<-(1/m)*(1/mean_rank)*(sum(rank_matrix[i,which(y_test[i,]>0)]))
}

##predictive rank sum using euclidean distance for similarities
rank_euc_sum<-vector()

for (i in 1:nrow(y_test)) {
  K<-ncol(Y)
  m<-length(which(y_test[i,]>0))
  mean_rank<-mean(rank_euc_matrix[i,])
  rank_euc_sum[i]<-(1/m)*(1/mean_rank)*(sum(rank_euc_matrix[i,which(y_test[i,]>0)]))
}



##calculating real rank sum
rank_test_sum<-vector()

for (i in 1:nrow(y_test)) {
  K<-ncol(Y)
  m<-length(which(y_test[i,]>0))
  mean_rank<-mean(rank_matrix[i,])
  rank_test_sum[i]<-(1/m)*(1/mean_rank)*(sum(rank_test[i,which(y_test[i,]>0)]))
}

##again similarity matrix using binary seems to be the better option