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

#########similarity######

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
ind<-sample(1:nrow(Y),1639)##1639
y_train<-Y[ind,]
y_test<-Y[-ind,]
train_feature<-feature[ind,]
test_feature<-feature[-ind,]

##cosine disance
cos_dist<-cosine(cbind(t(train_feature),t(test_feature)))
cos_dist_upper<-cos_dist[1:(dim(train_feature)[1]),(dim(train_feature)[1]+1):(dim(train_feature)[1]+dim(test_feature)[1])]

rank_matrix<-matrix(0,nrow(y_test),4973)
for (i in 1:nrow(y_test)) {
  n_siml<-which(cos.dist.upper[,i]%in%sort(cos.dist.upper[,i],decreasing=T)[1:100])
  #nsim<-sort(cos.dist.upper[,1],decreasing=T,index.return=T,na.last=T)$ix[1:50]
  rank_matrix[i,]<-rank(colMeans(y_train[n_siml,]))
}
rank_test<-t(apply(y_test,1,rank))


##using spearman's rank correlation to measure association between the two ranks
rho<-vector()
for (i in 1:nrow(y_test)) {
  cova<-cov(rank_matrix[i,],rank_test[i,])
  rho[i]<-cova/(sd(rank_matrix[i,])*sd(rank_test[i,]))
}
mean(rho)


##binary distance
binary_dist<-as.matrix(dist(rbind(train_feature,test_feature),method="binary"))
bin_dist_upp<-binary_dist[1:(dim(train_feature)[1]),(dim(train_feature)[1]+1):(dim(train_feature)[1]+dim(test_feature)[1])]


rank_bin_matrix<-matrix(0,nrow(y_test),4973)
for (i in 1:nrow(y_test)) {
  n_bin_siml<-which(bin_dist_upp[,i]%in%sort(bin_dist_upp[,i],decreasing=T)[1:100])
  #nsim<-sort(cos.dist.upper[,1],decreasing=T,index.return=T,na.last=T)$ix[1:50]
  rank_bin_matrix[i,]<-rank(colMeans(y_train[n_bin_siml,]))
}

rho_bin<-vector()
for (i in 1:nrow(y_test)) {
  cova_bin<-cov(rank_bin_matrix[i,],rank_test[i,])
  rho_bin[i]<-cova_bin/(sd(rank_bin_matrix[i,])*sd(rank_test[i,]))
}
mean(rho_bin)

##binary seems to be better method than the cosine 
##calculating predictive rank sum
rank_sum<-vector()

for (i in 1:nrow(y_test)) {
K<-ncol(Y)
m<-length(which(y_test[i,]>0))
mean_rank<-mean(rank_bin_matrix[i,])
rank_sum[i]<-(1/m)*(1/mean_rank)*(sum(rank_bin_matrix[i,which(y_test[i,]>0)]))
}
