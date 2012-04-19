args	  	<- commandArgs(TRUE);
mapped    	<- list.files('.', pattern="*.sort");
file_loop 	<- length(mapped);
limit     	<- as.numeric(args[1]);
y_top	  	<- as.numeric(args[2]);
min_treshold 	<- as.numeric(args[3]);

for (file in 1:file_loop)
{
	temp <- strsplit(mapped[file], "ssam");
	cfile <- substr(temp[[1]][1], 0, nchar(temp[[1]][1])-1);
	print (cfile);
	
	chr <- read.delim(mapped[file], header=F);
	chr <- transform(chr, V2=log10(V2));
  
	total <- max(chr$V1);
	loops <- (total/limit) + 1;
	
	for (i in 1:loops)
	{
	   	# mapped
		start <- (i-1)*limit;
		stopp <- if((i*limit) > total) total else (i*limit);

		if (i == (loops/4))	    {	print("25% done");    }
		if (i == (loops/2))	    {  	print("50% done");    }
		if (i == ((loops/2)+(loops/4)))   {	print("75% done");    }
		
		if (max(subs$V2) > min_treshold )
		{	    
			# making image
			name  	<- paste("r_data/", cfile, "/deleties/", limit ,"_", i ,".jpg", sep="");
			subs 	<- subset(subset(chr, V1>start), V1<stopp);
			jpeg(name, width=1200, height=480);
			
			max_y <- if (max(subs$V2) > y_top) max(subs$V2) else y_top;	
	    		plot(subs, xlab="pos", ylab="size", ylim=c(0, max_y), pch=".", cex=3, col="blue");
	    		dev.off();
    		}
  	}
}
