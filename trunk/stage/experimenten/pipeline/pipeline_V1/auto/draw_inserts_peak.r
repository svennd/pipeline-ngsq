args	  <- commandArgs(TRUE);
mapped    <- list.files('.', pattern="*.mapped");
file_loop <- length(mapped);
limit     <- as.numeric(args[1]); # 10000
treshold  <- as.numeric(args[2]); # 5

for (file in 1:file_loop)
{

  temp <- strsplit(mapped[file], "ssam");
  cfile <- substr(temp[[1]][1], 0, nchar(temp[[1]][1])-1);
  print (cfile);

  chr  			<- read.delim(mapped[file], header=F);
  chr[is.na(chr)] 	<- 0;
  total 		<- nrow(chr);
  loops 		<- (total/limit) + 1;

	for (i in 1:loops)
	{
	    start <- (i-1)*limit;
	    stopp <- if((i*limit) > total) total else (i*limit);
		if (max(chr$V6[start:stopp]) > treshold)
	      	{
			if (max(chr$V7[start:stopp]) > treshold)
			{
			    # piek
			    name <- paste("r_data/", cfile, "/inserties/insert_l" , limit , "_p_", i ,".jpg", sep="");
			    jpeg(name, width=1200, height=480);
				    plot(chr$V1[start:stopp], chr$V6[start:stopp], xlab="pos", ylab="d(unmapped-mapped)", type="l", col="orange");
				    lines(chr$V1[start:stopp], chr$V7[start:stopp], type="l", col="green");
			    dev.off();
			    
			    # proof
			    name  <- paste("r_data/", cfile, "/inserties/proof_" , limit , "_ul_", i ,".jpg", sep="");
			    jpeg(name, width=1200, height=480);
				    plot(chr$V1[start:stopp], chr$V5[start:stopp], xlab="pos", ylab="lunmapped", type="l", col="orange");
				    lines(chr$V1[start:stopp], chr$V4[start:stopp], type="l", col="green");
				    lines(chr$V1[start:stopp], chr$V3[start:stopp], type="l", col="red");
				    lines(chr$V1[start:stopp], chr$V2[start:stopp], type="l", col="blue");
			    dev.off();
			}
	      	}
	}
}
