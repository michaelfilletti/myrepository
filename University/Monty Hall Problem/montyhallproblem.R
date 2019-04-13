#Monty Hall Problem

#Keeping your choice
montyhall1<-function(n){
	count=0
	for (i in 1:n){
		#Assigning a car to one door
		car=sample(3,1)
		
		#Selecting your door
		pick=1
		
		#If your pick matches your car
		if (pick==car){
			count=count+1
		}
	}
print(count/n)
}

#Changing your choice
montyhall2<-function(n){
	count=0
	for (i in 1:n){
		car=sample(3,1)
		pick=sample(3,1)
		v=c(1:3)
		monty=v[!v %in% c(car,pick)][1]
		newpick=v[!v %in% c(pick,monty)]
		if (newpick==car){
			count=count+1
		}
	}
print(count/n)
}

montyhall1(10000)
montyhall2(10000)