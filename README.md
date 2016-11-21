# Project: Words 4 Music

### [Project Description](doc/Project4_desc.md)

![image](http://cdn.newsapi.com.au/image/v1/f7131c018870330120dbe4b73bb7695c?width=650)

Term: Fall 2016

+ [Data link](https://courseworks2.columbia.edu/courses/11849/files/folder/Project_Files?preview=763391)-(**courseworks login required**)
+ [Data description](doc/readme.html)
+ Contributor's name: YounHyuk Cho
+ Projec title: Lyric recommendation system using collaborative filtering
+ Project summary: In this project, I tried to build recommendation system using two methods: 1. Poisson regression to directly predict number of counts for each words. 2. Collaborative System based on similarity matrix. First method I tried was Poisson regression using mean, median and standard deviation of 15 features included in our data. The result obtained using poisson regression (also tried quassi poisson, negative binomial, penalized poisson regression, zero-inflated poisson) did not seemed to be very realiable because of convergence issue. Because coefficients of the model did not converge, the estimated count for some words were unrealistically high(e.g about 2e+18) and the prediction of the ranks did not seemed to very accurate as well. Second method was using collaborative learning method using cosine distance(also tried euclidean but cosine distance seemed to be giving better result when I compared their respective predictive rank sum) as the measure of similarity between the training and testing set. Using larger number of most similar set gave better predictive rank some but I used the 15 most similar values because using too large of a number might cancel some of the unique characterisitics of particular song.I computed average of the counts from the training data set and used those counts as our predictive counts and ranked them accordingly. For both methods I extracted mean, median, and standard deviation of the 15 features provided in our data set. Files-[PoissonRegression.r-poisson regression], [Similarity.r-collaborative Filtering], [main.r-applied collaborative filtering on our test data set of 100 new songs] [Reference on collaborative filter(See under foler doc or click on the link. Section 9.3](http://infolab.stanford.edu/~ullman/mmds/ch9.pdf)
	
Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── lib/
├── data/
├── doc/
├── figs/
└── output/
```

Please see each subfolder for a README file.
