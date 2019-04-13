#Normal Distribution
#Mean is 33.2 C
#Std. Dev is 6.1 C
#20 <= Prob < 30
prob=pnorm(30, mean=33.2, sd=6.1)-pnorm(20, mean=33.2, sd=6.1)
print(prob)

#Normal Distribution


#Dice Rolling - LLN
iterator<-function(n){
	avg=integer(n)
	x=c(1:n)
	for (i in 1:n){
		res=integer(i)
		die=c(1:6)
		for (j in 1:i){
			res[j]=sample(die,1)
		}
		avg[i]=mean(res)
	}
	plot(x,avg,main="Trials vs Average Rolls")
	abline(h=3.5,col="red")
}

iterator(1000)